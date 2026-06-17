# Android Gradle and Product Flavors

## What Is Gradle?

Gradle is a build automation system. Android uses it to transform source code,
resources, dependencies, and configuration into an installable application.

For this Flutter project, the build flow is:

```text
VS Code or terminal command
        |
        v
Flutter CLI
        |
        v
Android Gradle project
        |
        v
Compile Android code and package Flutter output
        |
        v
APK or Android App Bundle
```

Flutter compiles the Dart application and manages Flutter assets. Gradle handles
the Android-specific work, including:

- Compiling Kotlin and Java code.
- Processing `AndroidManifest.xml`.
- Packaging icons, resources, and native libraries.
- Resolving Android dependencies and Flutter plugins.
- Selecting debug, profile, or release configuration.
- Selecting an environment product flavor.
- Signing the application.
- Producing an APK or Android App Bundle.

Gradle is not exclusive to Flutter. It is a general build system commonly used
by Android, Kotlin, and Java projects.

## Important Gradle Files

### `android/app/build.gradle.kts`

This is the build configuration for the Android application module. It defines
the application ID, Android SDK versions, Java version, build types, and product
flavors.

Most app-specific Android configuration belongs in this file.

### `android/build.gradle.kts`

This is the root Android project configuration. It contains configuration
shared by Android modules, such as repositories and build directories.

### `android/settings.gradle.kts`

This file tells Gradle which modules and build plugins are part of the Android
project.

### `android/gradlew`

This is the Gradle Wrapper executable for macOS and Linux. It runs the Gradle
version selected by the project, so developers do not need to install a
matching Gradle version globally.

For example:

```sh
cd android
./gradlew tasks
```

### What Does `.kts` Mean?

The `.kts` extension means Kotlin Script. Therefore,
`build.gradle.kts` is a Gradle configuration file written with Kotlin syntax.

Older Android projects may use `build.gradle`, which uses Groovy syntax.

## Current App Configuration

The important parts of `android/app/build.gradle.kts` are explained below.

### Plugins

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
```

- `com.android.application` enables Android application build support.
- `kotlin-android` enables Kotlin compilation for Android.
- `dev.flutter.flutter-gradle-plugin` connects Flutter's build process to
  Gradle.

The Flutter plugin must be applied after the Android and Kotlin plugins.

### Android Configuration

```kotlin
android {
    namespace = "com.tk.r99store.r99.r99"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
}
```

- `namespace` identifies generated Android code and resources.
- `compileSdk` selects the Android SDK used to compile the app.
- `ndkVersion` selects the Native Development Kit version used by native
  dependencies.

The compile SDK does not define the oldest supported device. That is controlled
by `minSdk`.

### Java and Kotlin Compatibility

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlinOptions {
    jvmTarget = JavaVersion.VERSION_17.toString()
}
```

These settings compile Java and Kotlin code for Java 17 compatibility. Keeping
the Java and Kotlin targets aligned prevents bytecode compatibility errors.

### Default Application Configuration

```kotlin
defaultConfig {
    applicationId = "com.tk.r99store.r99.r99"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}
```

- `applicationId` is the unique Android identity of the installed app.
- `minSdk` is the oldest Android API level the app supports.
- `targetSdk` is the Android API level whose behavior the app targets.
- `versionCode` is the internal integer used for application upgrades.
- `versionName` is the user-visible release version.

`applicationId` and `namespace` can be the same, but they have different
purposes. The application ID identifies the installed app, while the namespace
organizes generated Android code.

## Product Flavors

A product flavor is a named variation of the Android application. Flavors are
useful when one codebase must support different environments, servers, branding,
or application IDs.

This project defines one flavor dimension:

```kotlin
flavorDimensions += "environment"
```

A flavor dimension is a category of flavors. Here, every flavor represents an
application environment, so the dimension is named `environment`.

The flavors are:

```kotlin
productFlavors {
    create("development") {
        dimension = "environment"
    }
    create("staging") {
        dimension = "environment"
    }
    create("production") {
        dimension = "environment"
    }
    create("local") {
        dimension = "environment"
    }
}
```

Each `create(...)` call registers a flavor with Gradle. Each flavor belongs to
the `environment` dimension.

After these flavors are registered, Gradle can create build variants such as:

```text
developmentDebug
developmentProfile
developmentRelease
stagingDebug
productionRelease
localDebug
```

A build variant is the combination of:

```text
product flavor + build type
```

For example:

```text
development + debug = developmentDebug
production + release = productionRelease
```

Without the `development` product flavor, this command fails:

```sh
flutter run --flavor development
```

Flutter asks Gradle to build a development variant, but Gradle cannot create the
task if the flavor has not been declared.

## Build Types

The standard Flutter/Android build types are:

- `debug`: Development build with debugging and hot reload support.
- `profile`: Performance measurement build.
- `release`: Optimized build intended for distribution.

The project currently configures release signing like this:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

This allows release builds to run using the debug signing key. It is convenient
for local testing, but a production store release should use a private release
keystore instead.

## Flutter Flavor and Dart Entry Point

Android product flavors and Dart entry points solve different problems.

The Android flavor selects the native Android build variant:

```sh
--flavor development
```

The target selects the Dart file that starts the Flutter application:

```sh
--target lib/main_development.dart
```

They are normally used together:

```sh
flutter run \
  --flavor development \
  --target lib/main_development.dart
```

The Android part creates `developmentDebug`. The Dart part starts the app from
`main_development.dart`, where `FlavorConfig` selects the development
environment.

The names should remain aligned:

| Environment | Android flavor | Dart entry point |
| --- | --- | --- |
| Development | `development` | `lib/main_development.dart` |
| Staging | `staging` | `lib/main_staging.dart` |
| Production | `production` | `lib/main_production.dart` |
| Local | `local` | A local Dart entry point when added |

An Android flavor does not automatically choose a Dart entry point. Both values
must be supplied by the launch configuration or build command.

## VS Code Launch Example

```json
{
  "name": "SIT",
  "cwd": "r99",
  "request": "launch",
  "type": "dart",
  "program": "lib/main_development.dart",
  "flutterMode": "debug",
  "args": [
    "--flavor",
    "development",
    "--target",
    "lib/main_development.dart"
  ]
}
```

This configuration requests:

1. The Android `development` flavor.
2. The Android `debug` build type.
3. The Dart entry point at `lib/main_development.dart`.

The resulting Android variant is `developmentDebug`.

The launch name `SIT` is only a label shown by VS Code. It does not control the
actual environment. The `--flavor` and `--target` values control the build.

## Common Commands

Run the development flavor:

```sh
flutter run \
  --flavor development \
  --target lib/main_development.dart
```

Build a development APK:

```sh
flutter build apk \
  --debug \
  --flavor development \
  --target lib/main_development.dart
```

Build a production release APK:

```sh
flutter build apk \
  --release \
  --flavor production \
  --target lib/main_production.dart
```

List available Gradle tasks:

```sh
cd android
./gradlew tasks --all
```

When flavors are configured correctly, the task list includes names such as:

```text
assembleDevelopment
assembleDevelopmentDebug
assembleStaging
assembleProduction
assembleLocal
```

## Common Errors

### Gradle Does Not Define a Suitable Task

Example:

```text
Gradle project does not define a task suitable for the requested build.
You cannot use the --flavor option.
```

Cause:

The Flutter command requests a flavor that is not defined in
`android/app/build.gradle.kts`.

Fix:

Add the flavor under `productFlavors`, or remove `--flavor` when native flavors
are not needed.

### Flavor Name Does Not Match

Flavor names must match exactly. If Gradle defines `development`, the command
must use:

```sh
--flavor development
```

Using `dev`, `sit`, or `Development` refers to a different name.

### Correct Flavor but Wrong Dart Environment

This command is technically possible:

```sh
flutter run \
  --flavor production \
  --target lib/main_development.dart
```

However, it mixes a production Android variant with the development Dart
configuration. Keep the Android flavor and Dart entry point aligned.

## Summary

Gradle is the Android build engine underneath Flutter. Flutter compiles the Dart
application, while Gradle assembles the complete Android application.

In this project:

- `build.gradle.kts` configures the Android app.
- A flavor defines an environment-specific Android variant.
- A build type defines debug, profile, or release behavior.
- A build variant combines one flavor with one build type.
- `--flavor` selects the Android variant.
- `--target` selects the Dart application entry point.

