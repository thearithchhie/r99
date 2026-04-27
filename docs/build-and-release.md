# Build and Release

## Common Commands

From the project root:

```sh
make get
make clean
make macos
make android_release
make ar
```

## Android Release Build

Two Make targets are available:

```sh
make android_release
make ar
```

Both run:

```sh
flutter build apk --release
```

Expected output:

- `build/app/outputs/flutter-apk/app-release.apk`

## Notes About Current Release Builds

- Material icons may be tree-shaken during release builds. This is normal.
- The `flutter_tesseract_ocr` plugin may print Android deprecation warnings during build.
- Those warnings do not currently block APK generation.

## iOS Notes

The project includes camera and photo library usage descriptions in:

- `ios/Runner/Info.plist`

The iOS Podfile was also adjusted for the OCR dependency deployment target:

- `ios/Podfile`

If iOS dependencies change again, run:

```sh
flutter pub get
cd ios && pod install
```

## Verification

After dependency or feature changes, a good minimal verification flow is:

```sh
flutter pub get
flutter analyze
make ar
```
