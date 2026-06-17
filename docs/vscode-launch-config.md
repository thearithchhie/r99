# VS Code Launch Configuration (`launch.json`)

## What is `launch.json`?

`launch.json` is a VS Code debugger configuration file. It tells VS Code how to run and debug your app — what program to launch, with what arguments, in what directory, and using what debugger.

Without it, you'd have to type the full `flutter run` command manually every time. With it, you just pick a config from a dropdown and press F5.

---

## File Location

```
business/              ← VS Code workspace root (folder you opened)
  .vscode/
    launch.json        ← VS Code reads this automatically
  r99/                 ← Flutter project
```

VS Code looks for `.vscode/launch.json` in the folder you opened, not the project subfolder.

---

## Our `launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "cwd": "r99",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_development.dart",
      "args": ["--flavor", "development"]
    },
    {
      "name": "Staging",
      "cwd": "r99",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging.dart",
      "args": ["--flavor", "staging"]
    },
    {
      "name": "Production",
      "cwd": "r99",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_production.dart",
      "args": ["--flavor", "production"]
    }
  ]
}
```

---

## Field-by-Field Explanation

### `version`
```json
"version": "0.2.0"
```
The launch.json schema version. Always `0.2.0` for VS Code — do not change this.

---

### `name`
```json
"name": "Development"
```
The label shown in the **Run & Debug** dropdown (top-left panel, or the status bar at the bottom of VS Code). You click this to choose which environment to run.

---

### `cwd`
```json
"cwd": "r99"
```
**Current Working Directory** — the folder VS Code treats as the project root when running commands.

Because our `launch.json` lives in `business/.vscode/` (one level above the Flutter project), we need this to tell VS Code "the Flutter project is inside the `r99` subfolder." Without it, VS Code looks for `pubspec.yaml` in `business/` and fails.

---

### `request`
```json
"request": "launch"
```
Either `"launch"` or `"attach"`.

- `"launch"` — VS Code starts the app from scratch (normal development).
- `"attach"` — VS Code connects to an app that is already running.

See the [Attach section](#request-attach) below for details.

---

### `type`
```json
"type": "dart"
```
Tells VS Code which debugger extension handles this config. `"dart"` means the Dart & Flutter extension. Other examples: `"node"`, `"python"`, `"go"`.

---

### `program`
```json
"program": "lib/main_development.dart"
```
The entry point Dart file. Flutter starts execution from `main()` in this file. The path is relative to `cwd`, so the full path is `r99/lib/main_development.dart`.

Each flavor has its own `main_*.dart` so you can set different values (API URLs, feature flags, etc.) per environment before the app starts:

```dart
// main_development.dart
void main() {
  AppConfig.setup(baseUrl: "https://dev-api.example.com");
  runApp(App());
}

// main_production.dart
void main() {
  AppConfig.setup(baseUrl: "https://api.example.com");
  runApp(App());
}
```

This keeps environment differences at the entry point — no `if` checks scattered through app code.

---

### `args`
```json
"args": ["--flavor", "development"]
```
Extra CLI arguments passed to `flutter run`. `--flavor development` tells Flutter (and Gradle on Android / Xcode on iOS) which product flavor to build.

The flavor name here must **exactly match** what is defined in:
- Android: `productFlavors { create("development") }` in `android/app/build.gradle.kts`
- iOS: Scheme names in Xcode

Mismatch example — this was our original bug:
```json
"args": ["--flavor", "Runner"]   // ❌ "Runner" doesn't exist in build.gradle.kts
"args": ["--flavor", "development"]  // ✅ matches productFlavors
```

---

## How It Maps to a Terminal Command

When you press F5 on "Development", VS Code effectively runs:

```bash
cd r99
flutter run --flavor development -t lib/main_development.dart
```

---

## `request: "attach"`

`attach` means your app is already running and you connect the debugger to it after the fact.

### When to use it

| Situation | Why attach |
|---|---|
| App is in a specific state you'd lose on restart | Preserves in-memory state, navigation stack |
| Started the app with custom flags not in launch config | e.g. `--profile`, `--dart-define` combos |
| App started by a script or another process | VS Code didn't launch it |
| Debugging on a remote device | Connect over network |

### How it works

Start the app manually in the terminal first:
```bash
flutter run --flavor development -t lib/main_development.dart
```

Flutter prints a VM Service URL:
```
An Observatory debugger and profiler on Android is available at:
http://127.0.0.1:52385/xxxxxxxxxxxx=/
```

Then add an attach config in `launch.json`:
```json
{
  "name": "Attach (manual URL)",
  "request": "attach",
  "type": "dart",
  "vmServiceUri": "http://127.0.0.1:52385/xxxxxxxxxxxx=/"
}
```

Or let the Dart extension auto-discover any running Flutter process:
```json
{
  "name": "Attach (auto-discover)",
  "request": "attach",
  "type": "dart"
}
```

### `launch` vs `attach` summary

| | `launch` | `attach` |
|---|---|---|
| Who starts the app | VS Code | You (manually) |
| App state on connect | Fresh start | Preserved |
| Needs `program` field | Yes | No |
| Needs `vmServiceUri` | No | Sometimes |
| Typical usage | Daily development | Debug live/running app |

In practice, use `launch` 90% of the time. Use `attach` when you need the app in a specific state, started with custom flags, or running on a remote device.

---

## Related

- [android-gradle-and-flavors.md](./android-gradle-and-flavors.md) — how flavors are defined on the Android side
- [build-and-release.md](./build-and-release.md) — building per flavor for release
