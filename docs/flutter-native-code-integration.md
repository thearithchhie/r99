# Flutter Native Code Integration

This project uses a native macOS bridge to let Flutter talk to platform code for printer discovery and printing.

The same pattern can be reused for any native feature:

- printer
- camera
- file system
- Bluetooth
- native SDK integration

## Goal

Flutter code cannot directly call AppKit or other Swift-only APIs.

To use native APIs, we create a `MethodChannel`:

1. Flutter sends a method call
2. Swift receives it
3. Swift runs native code
4. Swift returns the result back to Flutter

In this project:

- Dart side: [macos_native_printer_service.dart](/Users/thearith/project/business/r99/lib/src/core/printer/macos_native_printer_service.dart)
- macOS registration: [MainFlutterWindow.swift](/Users/thearith/project/business/r99/macos/Runner/MainFlutterWindow.swift)
- Swift native bridge: [AppDelegate.swift](/Users/thearith/project/business/r99/macos/Runner/AppDelegate.swift)

## Where To Inject Native Code

In this project, native code is injected at three clear layers:

1. Dart call site
   Location: [printer_page_controller_mixin.dart](/Users/thearith/project/business/r99/lib/src/controllers/printer_page_controller_mixin.dart)
   This is where Flutter decides when to call the native feature.

2. Dart platform service
   Location: [macos_native_printer_service.dart](/Users/thearith/project/business/r99/lib/src/core/printer/macos_native_printer_service.dart)
   This is where Flutter talks to the `MethodChannel`.

3. macOS registration and Swift implementation
   Locations:
   [MainFlutterWindow.swift](/Users/thearith/project/business/r99/macos/Runner/MainFlutterWindow.swift)
   [AppDelegate.swift](/Users/thearith/project/business/r99/macos/Runner/AppDelegate.swift)
   This is where the native bridge is registered and where AppKit/macOS code actually runs.

If you add another native feature later, use the same pattern:

- `lib/src/.../feature_native_service.dart`
- `macos/Runner/MainFlutterWindow.swift` for registration
- `macos/Runner/...swift` for the real native implementation

## Architecture

The flow looks like this:

```text
Flutter UI / Controller
  -> MacOSNativePrinterService
  -> MethodChannel("r99/macos_native_printer")
  -> MacOSNativePrinterBridge
  -> native Swift code
  -> result back to Flutter
```

## Step 1: Create a Dart service

Make one Dart service responsible for all native calls for a feature.

Example from this project:

```dart
static const MethodChannel _channel = MethodChannel(
  'r99/macos_native_printer',
);
```

This lives in [macos_native_printer_service.dart](/Users/thearith/project/business/r99/lib/src/core/printer/macos_native_printer_service.dart).

Then expose simple methods:

- `listPrinters()`
- `printTemplate(...)`

Example:

```dart
static Future<List<String>> listPrinters() async {
  final result = await _channel.invokeMethod<List<Object?>>('listPrinters');
  if (result == null) {
    return const [];
  }

  return result.whereType<String>().toList();
}
```

## Step 2: Register the native bridge on macOS

The native Swift side must register the channel after Flutter starts.

In this project, registration happens in [MainFlutterWindow.swift](/Users/thearith/project/business/r99/macos/Runner/MainFlutterWindow.swift):

```swift
RegisterGeneratedPlugins(registry: flutterViewController)
MacOSNativePrinterBridge.register(with: flutterViewController)
```

That line is what connects Flutter to our custom Swift code.

Without this registration, Flutter will throw:

`MissingPluginException`

## Step 3: Create a Swift bridge class

Create one Swift class that owns:

- channel name
- registration
- method routing
- native implementation

Example from this project:

```swift
final class MacOSNativePrinterBridge: NSObject {
  static let channelName = "r99/macos_native_printer"
}
```

The registration method creates the channel:

```swift
let channel = FlutterMethodChannel(
  name: channelName,
  binaryMessenger: flutterViewController.engine.binaryMessenger
)
```

## Step 4: Handle method calls in Swift

Inside the Swift bridge, route incoming Flutter calls by method name:

```swift
switch call.method {
case "listPrinters":
  ...
case "printTemplate":
  ...
default:
  result(FlutterMethodNotImplemented)
}
```

This is already implemented in [AppDelegate.swift](/Users/thearith/project/business/r99/macos/Runner/AppDelegate.swift).

## Step 5: Validate incoming arguments

Always parse arguments carefully before using them.

Example:

```swift
guard
  let args = call.arguments as? [String: Any],
  let printerName = args["printerName"] as? String,
  let templateMap = args["template"] as? [String: Any]
else {
  result(
    FlutterError(
      code: "bad_args",
      message: "Missing printerName or template",
      details: nil
    )
  )
  return
}
```

This avoids crashes and gives Flutter a proper error.

## Step 6: Convert Flutter data into a native model

Do not pass raw maps everywhere inside Swift.

Instead:

1. receive a Dart map
2. parse it once
3. convert it into a typed Swift model

This project uses:

```swift
struct MacOSPrintTemplate
```

That model is defined in [AppDelegate.swift](/Users/thearith/project/business/r99/macos/Runner/AppDelegate.swift) and is built from:

```swift
let template = try MacOSPrintTemplate(map: templateMap)
```

This keeps the native side safer and easier to maintain.

## Step 7: Run native platform code

After the data is parsed, run the real native feature.

In this project:

- `NSPrinter.printerNames.sorted()` lists installed macOS printers
- `NSPrintOperation` performs printing
- `NativeTemplatePrintView` draws the printable label layout

This is the point where Flutter stops and Swift takes over.

## Step 8: Return success or error to Flutter

Use `result(...)` correctly:

- `result(nil)` for success with no payload
- `result(value)` for success with data
- `result(FlutterError(...))` for controlled failure

Example:

```swift
result(nil)
```

and

```swift
result(
  FlutterError(
    code: "print_failed",
    message: error.localizedDescription,
    details: nil
  )
)
```

On the Dart side, these surface as normal async success/failure.

## Step 9: Use the service from Flutter UI or controllers

Do not call `MethodChannel` directly from widgets.

Use the service class from controllers or state logic.

In this project, printer logic lives in:

- [printer_page_controller_mixin.dart](/Users/thearith/project/business/r99/lib/src/controllers/printer_page_controller_mixin.dart)

That controller decides:

- when to scan
- when to connect
- when to print
- whether to use the native macOS path or the other printer manager path

## Step 10: Keep platform-specific logic isolated

A good rule:

- Dart service knows channel names
- Swift bridge knows native APIs
- Flutter UI does not know native details

That separation makes debugging much easier.

## Practical pattern

When adding a new native feature, follow this checklist:

1. Create a Dart service with one `MethodChannel`
2. Register the Swift bridge in `MainFlutterWindow.swift`
3. Create a native Swift bridge class
4. Add `switch call.method` routing
5. Validate arguments with `guard`
6. Convert data into a Swift model
7. Run native platform APIs
8. Return success or `FlutterError`
9. Call the Dart service from controller/state logic

## Common problems

### `MissingPluginException`

Usually means the bridge was not registered.

Check:

- [MainFlutterWindow.swift](/Users/thearith/project/business/r99/macos/Runner/MainFlutterWindow.swift)

### Build errors in Swift

Usually caused by:

- missing braces
- wrong argument types
- AppKit/CoreGraphics type mismatch
- copied code that uses unavailable macOS APIs

### Flutter receives no result

Usually means the Swift method forgot to call `result(...)`.

Every path in the handler should return something.

### Assets not loading in native code

If Swift needs Flutter asset files, it must read them from the app bundle.

This project resolves Flutter asset paths from:

- `Bundle.main.resourceURL`
- `App.framework/Resources/flutter_assets`

That logic is also inside [AppDelegate.swift](/Users/thearith/project/business/r99/macos/Runner/AppDelegate.swift).

## When to use native code

Use native code when Flutter alone is not enough:

- system printer APIs
- platform-only SDKs
- advanced Bluetooth features
- device-level file or media APIs
- OS-specific UI or services

Do not move logic native unless it needs to be native.

Keep business logic in Dart whenever possible.

## Summary

The native integration pattern in this project is:

- Flutter service sends method calls
- Swift bridge receives them
- Swift runs the platform feature
- result returns to Flutter

That is the cleanest way to inject native code into Flutter while keeping the app maintainable.
