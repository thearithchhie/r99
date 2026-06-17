# How to Add a New Flavor

Quick reference for the exact prompt to give Claude when adding a new flavor.

---

## iOS only

```
Add a new iOS flavor called "<name>"
```

Claude will:
- Create `<name>.xcscheme` in `ios/Runner.xcodeproj/xcshareddata/xcschemes/`
- Add `Debug-<name>`, `Release-<name>`, `Profile-<name>` to `project.pbxproj` (27 entries across 3 targets)
- Add `"<Name>" => :debug/release` mappings to `ios/Podfile` project block

---

## Android only

```
Add a new Android flavor called "<name>"
```

Claude will:
- Add `create("<name>")` block inside `productFlavors` in `android/app/build.gradle.kts`
- Set `applicationIdSuffix`, `versionNameSuffix`, `dimension` etc.

---

## Both iOS and Android

```
Add a new flavor called "<name>" for both iOS and Android
```

Claude will do everything from both sections above.

---

## Complete flavor (recommended)

```
Add a complete new flavor called "<name>" for both iOS and Android,
with its own main_<name>.dart entry point and VS Code launch config
```

Claude will also create:
- `lib/main_<name>.dart` entry point
- Entry in `.vscode/launch.json`

---

## With custom options (be specific upfront)

```
Add a complete new flavor called "<name>" for both iOS and Android,
with its own main_<name>.dart entry point and VS Code launch config,
bundle ID suffix ".<name>", app name "R99 <Name>"
```

Options you can specify:

| Option | Example |
|--------|---------|
| Bundle ID suffix | `.local`, `.staging` |
| App display name | `"R99 Local"`, `"R99 Staging"` |
| Version name suffix | `-local`, `-stg` |
| API base URL | `https://dev-api.example.com` |
| Feature flags | `enableLogging: true` |

---

## Current flavors in this project

| Flavor | Entry point | Purpose |
|--------|------------|---------|
| `development` | `lib/main_development.dart` | Local development |
| `staging` | `lib/main_staging.dart` | Staging / QA environment |
| `production` | `lib/main_production.dart` | App Store release |

---

## Related Docs

- [ios-flavors-and-xcode-build-system.md](./ios-flavors-and-xcode-build-system.md) — deep explanation of how iOS flavors work
- [android-gradle-and-flavors.md](./android-gradle-and-flavors.md) — deep explanation of how Android flavors work
- [vscode-launch-config.md](./vscode-launch-config.md) — how VS Code launch.json maps to flutter run commands
