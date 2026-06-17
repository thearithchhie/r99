# iOS Flavors & Xcode Build System

How Flutter flavors work on iOS, what files are involved, and how they all connect together.

---

## Table of Contents

1. [The Problem We Solved](#the-problem-we-solved)
2. [What is an Xcode Scheme (.xcscheme)](#what-is-an-xcode-scheme-xcscheme)
3. [What is LaunchAction buildConfiguration](#what-is-launchaction-buildconfiguration)
4. [What is project.pbxproj](#what-is-projectpbxproj)
5. [What is XCBuildConfiguration](#what-is-xcbuildconfiguration)
6. [What is XCConfigurationList](#what-is-xconfigurationlist)
7. [What is xcconfig](#what-is-xcconfig)
8. [How Everything Connects](#how-everything-connects)
9. [What We Changed and Why](#what-we-changed-and-why)
10. [The SwiftyTesseract arm64 Problem](#the-swiftytesseract-arm64-problem)

---

## The Problem We Solved

When you run:

```bash
flutter run --flavor development -t lib/main_development.dart
```

Flutter needs to find three things on the iOS side, in order:

1. A **scheme** named `development` inside `Runner.xcodeproj`
2. A **build configuration** named `Debug-development` inside `project.pbxproj`
3. **CocoaPods** configured to know about `Debug-development`

All three were missing. Each missing piece produced a different error. We fixed them one by one.

---

## What is an Xcode Scheme (.xcscheme)

### Location

```
ios/
└── Runner.xcodeproj/
    └── xcshareddata/
        └── xcschemes/
            ├── Runner.xcscheme        ← original, no flavor
            ├── development.xcscheme   ← we created
            ├── staging.xcscheme       ← we created
            └── production.xcscheme    ← we created
```

`xcshareddata` means **shared across the whole team**. These files should be committed to git so every developer and CI machine gets the same schemes automatically.

### What a scheme is

A scheme is a **named build recipe**. It tells Xcode what to do for each action:

| Action | Flutter command | What it controls |
|--------|----------------|-----------------|
| Build | (internal) | Which targets to compile |
| Run / Launch | `flutter run` | Which config to use for debug |
| Test | `flutter test` | Which config to use for tests |
| Profile | `flutter run --profile` | Which config to use for profiling |
| Archive | `flutter build ipa` | Which config to use for release |

### What a .xcscheme file looks like

It is a plain XML file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1510" version="1.3">

   <BuildAction ...>
      <!-- which targets to build -->
   </BuildAction>

   <TestAction buildConfiguration="Debug" ...>
      <!-- used by: flutter test -->
   </TestAction>

   <LaunchAction buildConfiguration="Debug" ...>
      <!-- used by: flutter run -->
   </LaunchAction>

   <ProfileAction buildConfiguration="Profile" ...>
      <!-- used by: flutter run --profile -->
   </ProfileAction>

   <ArchiveAction buildConfiguration="Release" ...>
      <!-- used by: flutter build ipa -->
   </ArchiveAction>

</Scheme>
```

### Why Flutter needs a scheme per flavor

When you pass `--flavor development`, Flutter looks for a file named exactly:

```
Runner.xcodeproj/xcshareddata/xcschemes/development.xcscheme
```

If the file does not exist, Flutter throws:

```
Unable to get scheme file for development.
```

The scheme name must match the flavor name exactly (case-sensitive, lowercase).

---

## What is LaunchAction buildConfiguration

Inside each `.xcscheme`, the `LaunchAction` block controls what happens when you run the app in debug mode:

```xml
<LaunchAction
   buildConfiguration = "Debug"
   selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
   selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
   ...>
```

The key attribute is `buildConfiguration = "Debug"`.

### How Flutter uses this value

Flutter does not use the value directly. It takes the value and **appends the flavor name** with a hyphen:

```
buildConfiguration value  +  "-"  +  flavor name
        "Debug"           +  "-"  +  "development"
                 =  "Debug-development"
```

So Flutter will look for a build configuration named `Debug-development` in `project.pbxproj`.

### The full mapping

| Action | Scheme value | Flutter appends | Final config name |
|--------|-------------|-----------------|-------------------|
| Run | `Debug` | `-development` | `Debug-development` |
| Profile | `Profile` | `-development` | `Profile-development` |
| Archive | `Release` | `-development` | `Release-development` |

This is why we needed to create all three variants (`Debug-`, `Release-`, `Profile-`) for each flavor in `project.pbxproj`.

---

## What is project.pbxproj

### Location

```
ios/Runner.xcodeproj/project.pbxproj
```

This is the **most important file in iOS development**. It is the single source of truth for your entire Xcode project — every file, every target, every build setting, every configuration.

### Format

`.pbxproj` stands for **Project Builder Xcode Project**. It uses Apple's old NeXTSTEP property list format — not JSON, not XML, but a custom serialized object graph:

```
// !$*UTF8*$!
{
    archiveVersion = 1;
    objectVersion = 56;
    objects = {

        /* Everything in your project is in here */
        /* Each object has a 24-character UUID as its key */

        97C146ED1CF9000F007C117D /* Runner */ = {
            isa = PBXNativeTarget;
            ...
        };

    };
    rootObject = 83CBB9F71A601CBA00E9B192;
}
```

### The UUID system

Every single object — every file, every target, every configuration — has a unique 24-character hexadecimal ID:

```
97C146ED1CF9000F007C117D
AA0002012FDE548800F9BBB0   ← the ones we created start with AA
331C8088294A63A400263BE5
```

Objects reference each other by UUID. The file never stores names directly in references — always UUIDs. The comment after the UUID (e.g., `/* Debug */`) is just a human-readable hint added by Xcode; it has no effect.

### The major sections inside objects

```
/* PBXBuildFile */             every file that gets compiled into a target
/* PBXFileReference */         every file that exists in the project navigator
/* PBXFrameworksBuildPhase */  frameworks and libraries to link
/* PBXGroup */                 folder structure shown in Xcode navigator
/* PBXNativeTarget */          targets (Runner, RunnerTests)
/* PBXProject */               top-level project object
/* PBXResourcesBuildPhase */   assets, storyboards, Info.plist
/* PBXShellScriptBuildPhase */ Run Script build phases
/* PBXSourcesBuildPhase */     .swift and .m files to compile
/* XCBuildConfiguration */     ← WE EDITED THIS (Debug, Release, Debug-development...)
/* XCConfigurationList */      ← WE EDITED THIS (groups configs per target)
/* XCLocalSwiftPackageReference */ Swift Package Manager references
```

---

## What is XCBuildConfiguration

This section holds every build configuration as a separate object. Each configuration is a named collection of build settings.

### Example — the original Debug configuration

```
97C147031CF9000F007C117D /* Debug */ = {
    isa = XCBuildConfiguration;
    buildSettings = {
        DEBUG_INFORMATION_FORMAT = dwarf;
        ENABLE_TESTABILITY = YES;
        GCC_OPTIMIZATION_LEVEL = 0;
        GCC_PREPROCESSOR_DEFINITIONS = (
            "DEBUG=1",
            "$(inherited)",
        );
        IPHONEOS_DEPLOYMENT_TARGET = 13.0;
        MTL_ENABLE_DEBUG_INFO = YES;
        ONLY_ACTIVE_ARCH = YES;
        SDKROOT = iphoneos;
        TARGETED_DEVICE_FAMILY = "1,2";
    };
    name = Debug;
};
```

### Debug vs Release settings compared

| Setting | Debug | Release | What it means |
|---------|-------|---------|---------------|
| `GCC_OPTIMIZATION_LEVEL` | `0` | `s` | 0 = no optimization (fast to compile, easy to debug). s = optimize for size |
| `DEBUG_INFORMATION_FORMAT` | `dwarf` | `dwarf-with-dsym` | dwarf = debug symbols inline. dsym = separate symbol file (needed for crash reporting) |
| `GCC_PREPROCESSOR_DEFINITIONS` | `DEBUG=1` | _(absent)_ | Lets you write `#if DEBUG` in code |
| `MTL_ENABLE_DEBUG_INFO` | `YES` | `NO` | Metal GPU debugging on/off |
| `ONLY_ACTIVE_ARCH` | `YES` | `NO` | YES = build only for the connected device arch (faster). NO = build for all archs (needed for distribution) |
| `SWIFT_OPTIMIZATION_LEVEL` | `-Onone` | `-O` | -Onone = no Swift optimization (debuggable). -O = full optimization (fast app) |
| `ENABLE_TESTABILITY` | `YES` | _(absent)_ | Allows unit tests to access internal types |

### There are TWO levels of configurations

**Project-level** (applies to all targets as defaults):
```
97C147031CF9000F007C117D /* Debug */ = {
    isa = XCBuildConfiguration;
    buildSettings = {
        /* broad compiler settings, deployment target, etc. */
    };
    name = Debug;
};
```

**Target-level** (applies to one specific target, overrides project-level):
```
97C147061CF9000F007C117D /* Debug */ = {
    isa = XCBuildConfiguration;
    baseConfigurationReference = 9740EEB21CF90195004384FC /* Debug.xcconfig */;
    buildSettings = {
        /* app-specific settings: bundle ID, team, etc. */
        PRODUCT_BUNDLE_IDENTIFIER = com.tk.r99store.r99.r99;
        DEVELOPMENT_TEAM = LTL445J2SV;
        SWIFT_VERSION = 5.0;
    };
    name = Debug;
};
```

Notice `baseConfigurationReference` — the target-level config can point to an `.xcconfig` file which provides even more settings. Project-level configs do not have this.

### What we added

We created 27 new `XCBuildConfiguration` objects — 9 per target × 3 targets:

```
9 configurations × 3 targets = 27 new objects

Configurations:
  Debug-development, Release-development, Profile-development
  Debug-staging,     Release-staging,     Profile-staging
  Debug-production,  Release-production,  Profile-production

Targets:
  PBXProject "Runner"          (project-level defaults)
  PBXNativeTarget "Runner"     (the app)
  PBXNativeTarget "RunnerTests" (the tests)
```

Each new configuration is a copy of the matching base config (`Debug-development` copies `Debug`, `Release-development` copies `Release`, etc.) with only the `name` field changed.

---

## What is XCConfigurationList

This section groups configurations together and assigns them to a target. There is one `XCConfigurationList` per target.

### Structure

```
97C147051CF9000F007C117D /* Build configuration list for PBXNativeTarget "Runner" */ = {
    isa = XCConfigurationList;
    buildConfigurations = (
        97C147061CF9000F007C117D /* Debug */,
        97C147071CF9000F007C117D /* Release */,
        249021D4217E4FDB00AE95B9 /* Profile */,
        AA0002012FDE548800F9BBB0 /* Debug-development */,     ← we added
        AA0002022FDE548800F9BBB0 /* Release-development */,   ← we added
        AA0002032FDE548800F9BBB0 /* Profile-development */,   ← we added
        AA0002042FDE548800F9BBB0 /* Debug-staging */,         ← we added
        ...
    );
    defaultConfigurationName = Release;
};
```

### The three lists in this project

| List UUID | Belongs to | Purpose |
|-----------|-----------|---------|
| `97C146E91CF9000F007C117D` | PBXProject "Runner" | Project-level config defaults |
| `97C147051CF9000F007C117D` | PBXNativeTarget "Runner" | The actual app target |
| `331C8087294A63A400263BE5` | PBXNativeTarget "RunnerTests" | The test target |

We added our 27 new configurations to all three lists.

---

## What is xcconfig

`.xcconfig` files are plain text files that define build settings as key-value pairs. They are included by `XCBuildConfiguration` objects via `baseConfigurationReference`.

### Our xcconfig files

```
ios/Flutter/
├── Debug.xcconfig      ← used by all Debug-based configurations
└── Release.xcconfig    ← used by all Release and Profile configurations
```

### What Debug.xcconfig contains

```xcconfig
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
#include "Generated.xcconfig"
FLUTTER_ENABLE_SWIFT_PACKAGE_MANAGER=false
EXCLUDED_ARCHS[sdk=iphonesimulator*]=arm64
```

Line by line:

| Line | What it does |
|------|-------------|
| `#include? "Pods-Runner.debug.xcconfig"` | Pulls in all CocoaPods settings. The `?` means "include if it exists, skip if not" |
| `#include "Generated.xcconfig"` | Pulls in Flutter engine paths, version numbers, dart defines |
| `FLUTTER_ENABLE_SWIFT_PACKAGE_MANAGER=false` | Disables Flutter's experimental SPM integration (prevents scheme name conflicts with packages like app_links) |
| `EXCLUDED_ARCHS[sdk=iphonesimulator*]=arm64` | Forces simulator builds to use x86_64 (Rosetta 2) because SwiftyTesseract does not have arm64 simulator slices |

### Settings inheritance order

Settings are resolved from lowest to highest priority. Higher priority wins:

```
1. Xcode defaults                          (lowest priority)
2. Project-level XCBuildConfiguration
3. Target-level XCBuildConfiguration
4. baseConfigurationReference (.xcconfig)
5. Individual build setting in target      (highest priority)
```

Because xcconfig is at level 4, it can override project-level defaults but can be overridden by explicit target settings.

---

## How Everything Connects

Here is the full chain from `flutter run --flavor development` to a compiled app:

```
flutter run --flavor development -t lib/main_development.dart
       │
       │  Step 1: find the scheme
       ▼
development.xcscheme
  └── LaunchAction buildConfiguration="Debug"
       │
       │  Step 2: Flutter appends flavor name
       │  "Debug" + "-" + "development" = "Debug-development"
       ▼
project.pbxproj
  └── XCConfigurationList for Runner target
      └── AA0002012FDE548800F9BBB0 /* Debug-development */
            isa = XCBuildConfiguration
            baseConfigurationReference → Debug.xcconfig
            buildSettings = {
                PRODUCT_BUNDLE_IDENTIFIER = com.tk.r99store.r99.r99;
                DEVELOPMENT_TEAM = LTL445J2SV;
                ...
            }
       │
       │  Step 3: load xcconfig chain
       ▼
Debug.xcconfig
  ├── FLUTTER_ENABLE_SWIFT_PACKAGE_MANAGER=false
  ├── EXCLUDED_ARCHS[sdk=iphonesimulator*]=arm64
  ├── #include Generated.xcconfig
  │     └── FLUTTER_ROOT, FLUTTER_BUILD_NAME, DART_DEFINES, ...
  └── #include? Pods-Runner.debug.xcconfig
        └── FRAMEWORK_SEARCH_PATHS, OTHER_LDFLAGS, ... (CocoaPods)
       │
       │  Step 4: Xcode compiles with all resolved settings
       ▼
Runner.app (built for x86_64-apple-ios-simulator)
```

---

## What We Changed and Why

### Summary of all files modified

| File | What we did | Why |
|------|-------------|-----|
| `xcschemes/development.xcscheme` | Created new file | Flutter needs a scheme named after the flavor |
| `xcschemes/staging.xcscheme` | Created new file | Same, for staging flavor |
| `xcschemes/production.xcscheme` | Created new file | Same, for production flavor |
| `project.pbxproj` | Added 27 new XCBuildConfiguration objects + updated 3 XCConfigurationLists | Flutter expects `Debug-development` etc. to exist |
| `ios/Flutter/Debug.xcconfig` | Added 2 lines | Disable SPM (scheme conflict) + arm64 simulator exclusion |
| `ios/Flutter/Release.xcconfig` | Added 1 line | Disable SPM for release/profile builds |
| `ios/Podfile` | Added new configs to `project` block + arm64 exclusion in post_install | CocoaPods must know about new configs to build pods correctly |

---

## The SwiftyTesseract arm64 Problem

### Background

This project uses `flutter_tesseract_ocr` for OCR scanning. It depends on a pod called `SwiftyTesseract` (version 3.1.3, pinned to a specific git commit). SwiftyTesseract wraps the Tesseract OCR engine as a prebuilt C++ library (`libtesseract`).

### The problem

Apple transitioned to Apple Silicon (M1/M2/M3) in 2020. The iOS Simulator on Apple Silicon Macs runs natively as `arm64-apple-ios-simulator`. However, the prebuilt `libtesseract` inside SwiftyTesseract 3.1.3 only has slices for:

- `arm64-apple-iphoneos` (real device)
- `x86_64-apple-ios-simulator` (Intel Mac simulator)

It is **missing** `arm64-apple-ios-simulator` (Apple Silicon Mac simulator).

### The error

```
Swift Compiler Error: Could not find module 'SwiftyTesseract'
for target 'arm64-apple-ios-simulator'; found: x86_64-apple-ios-simulator
```

Swift found the framework but it only has the wrong simulator architecture.

### The fix — Rosetta 2 workaround

We force all simulator builds to use `x86_64` by excluding `arm64` from simulator SDK builds:

**In `ios/Flutter/Debug.xcconfig`** (affects Runner app target):
```xcconfig
EXCLUDED_ARCHS[sdk=iphonesimulator*]=arm64
```

**In `ios/Podfile` post_install** (affects all pod targets):
```ruby
config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
```

On Apple Silicon Macs, **Rosetta 2** automatically translates x86_64 simulator apps to arm64 at runtime. The performance difference is minimal for development purposes.

### Why this only affects simulator

Real device builds are not affected. `EXCLUDED_ARCHS[sdk=iphonesimulator*]` only applies when the target SDK is `iphonesimulator`. Device builds use `iphoneos` SDK which already has arm64 support in SwiftyTesseract.

### Long-term fix

Update `flutter_tesseract_ocr` to a newer version that uses a SwiftyTesseract build with `arm64-apple-ios-simulator` slices. Once that is done, the `EXCLUDED_ARCHS` lines can be removed.

---

## Related Docs

- [android-gradle-and-flavors.md](./android-gradle-and-flavors.md) — how flavors work on the Android side (equivalent concepts)
- [vscode-launch-config.md](./vscode-launch-config.md) — how VS Code launch.json maps to flutter run commands
- [build-and-release.md](./build-and-release.md) — building per flavor for App Store release
