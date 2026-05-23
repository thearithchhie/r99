# Flutter Native Code Diagram

This diagram shows how native macOS code is injected into the Flutter app in this project.

Relevant files:

- [macos_native_printer_service.dart](/Users/thearith/project/business/r99/lib/src/core/printer/macos_native_printer_service.dart)
- [printer_page_controller_mixin.dart](/Users/thearith/project/business/r99/lib/src/controllers/printer_page_controller_mixin.dart)
- [MainFlutterWindow.swift](/Users/thearith/project/business/r99/macos/Runner/MainFlutterWindow.swift)
- [AppDelegate.swift](/Users/thearith/project/business/r99/macos/Runner/AppDelegate.swift)

## Injection Points

Native code enters this Flutter app in these locations:

- Flutter decision layer:
  [printer_page_controller_mixin.dart](/Users/thearith/project/business/r99/lib/src/controllers/printer_page_controller_mixin.dart)
- Dart platform bridge:
  [macos_native_printer_service.dart](/Users/thearith/project/business/r99/lib/src/core/printer/macos_native_printer_service.dart)
- macOS registration:
  [MainFlutterWindow.swift](/Users/thearith/project/business/r99/macos/Runner/MainFlutterWindow.swift)
- native Swift implementation:
  [AppDelegate.swift](/Users/thearith/project/business/r99/macos/Runner/AppDelegate.swift)

## High-Level Flow

```mermaid
flowchart TD
    A["Flutter UI / Printer Page"] --> B["PrinterPageControllerMixin"]
    B --> C["MacOSNativePrinterService"]
    C --> D["MethodChannel<br/>r99/macos_native_printer"]
    D --> E["MacOSNativePrinterBridge.register(...)"]
    E --> F["MacOSNativePrinterBridge.handle(...)"]
    F --> G["Native macOS APIs"]
    G --> H["NSPrinter / NSPrintOperation / NativeTemplatePrintView"]
    H --> I["Result back to Flutter"]
    I --> B
    B --> A
```

## Registration Flow

When the macOS window starts, Flutter plugins are registered first, then the custom printer bridge is registered.

```mermaid
flowchart LR
    A["MainFlutterWindow.awakeFromNib()"] --> B["RegisterGeneratedPlugins(...)"]
    B --> C["MacOSNativePrinterBridge.register(with: flutterViewController)"]
    C --> D["FlutterMethodChannel created"]
    D --> E["Method handler attached"]
```

## Print Request Flow

This is the path used when the app prints through the native macOS printer queue.

```mermaid
sequenceDiagram
    participant UI as Flutter UI
    participant CTRL as PrinterPageControllerMixin
    participant DART as MacOSNativePrinterService
    participant CH as MethodChannel
    participant SWIFT as MacOSNativePrinterBridge
    participant MODEL as MacOSPrintTemplate
    participant PRINT as NSPrintOperation

    UI->>CTRL: Tap Print
    CTRL->>DART: printTemplate(printerName, data)
    DART->>CH: invokeMethod("printTemplate", args)
    CH->>SWIFT: handle(call, result)
    SWIFT->>MODEL: parse template map
    MODEL-->>SWIFT: typed template
    SWIFT->>PRINT: create NativeTemplatePrintView + run print
    PRINT-->>SWIFT: success / failure
    SWIFT-->>CH: result(nil) or FlutterError
    CH-->>DART: Future completes
    DART-->>CTRL: success / exception
    CTRL-->>UI: update state / message
```

## Printer List Flow

This is the path used when Flutter asks macOS for installed printer names.

```mermaid
flowchart TD
    A["Flutter scan action"] --> B["MacOSNativePrinterService.listPrinters()"]
    B --> C["invokeMethod('listPrinters')"]
    C --> D["MacOSNativePrinterBridge.handle(...)"]
    D --> E["NSPrinter.printerNames.sorted()"]
    E --> F["List<String> back to Dart"]
    F --> G["Controller builds printer options"]
```

## Data Model Flow

Flutter sends structured label data to Swift as a map. Swift turns it into a typed native model before printing.

```mermaid
flowchart LR
    A["PrintTemplateData (Dart)"] --> B["toMacOSPrintMap()"]
    B --> C["Map<String, dynamic>"]
    C --> D["MethodChannel arguments"]
    D --> E["MacOSPrintTemplate(map:)"]
    E --> F["Typed Swift model"]
    F --> G["NativeTemplatePrintView draws label"]
```

## Why This Structure Helps

- Flutter stays responsible for app state and business flow.
- Swift stays responsible for macOS-only APIs.
- The `MethodChannel` is the boundary between cross-platform code and native code.
- The bridge is easier to debug because each layer has one clear role.

## Quick Mental Model

You can think of the system like this:

1. Flutter decides `what` to do.
2. The Dart service sends the request.
3. The Swift bridge decides `how` to do it on macOS.
4. Native AppKit printing performs the final OS-level work.
