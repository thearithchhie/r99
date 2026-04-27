# Features Guide

## Login

The app starts on a login screen.

Current behavior:

- Requires username
- Requires password
- Uses a local UI gate only
- Does not yet call a backend authentication service

Code:

- `lib/main.dart`
- `lib/src/core/view/auth/login_page.dart`

## Printer Feature

### What it does

- Requests Bluetooth permissions
- Scans for supported printers
- Connects to a selected printer
- Builds a printable card preview
- Captures the preview as an image
- Prints the image to a 58mm ESC/POS printer

### Main files

- View: `lib/src/printer_page.dart`
- Logic: `lib/src/controllers/printer_page_controller_mixin.dart`
- Template view: `lib/src/widgets/print_template_card.dart`
- Template form: `lib/src/widgets/print_template_editor.dart`

### Current UX behavior

- Blocks the screen while printer scanning is in progress
- Hides printer status and discovered device list after successful connection
- Supports disconnect from the app bar action

## OCR Feature

### What it does

- Pick image from gallery
- Take photo with camera
- Preview selected image
- Extract text from image
- Show extracted text in a scrollable area
- Allow text selection with `SelectableText`
- Copy extracted text to clipboard
- Show loading overlay during OCR
- Show errors for empty selection or OCR failure

### Main files

- View: `lib/src/core/view/ocr/text_scanner_page.dart`
- Logic: `lib/src/core/view/ocr/controller_mixin.dart`

### OCR engine

The OCR feature uses `flutter_tesseract_ocr` with:

- `khm+eng`

This is important because the earlier ML Kit approach did not support Khmer text recognition correctly for this app.

### OCR assets

The OCR feature depends on:

- `assets/tessdata/khm.traineddata`
- `assets/tessdata/eng.traineddata`
- `assets/tessdata_config.json`

If these files are missing or not declared in `pubspec.yaml`, OCR will fail.
