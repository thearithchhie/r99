# Project Overview

## Summary

R99 is a Flutter mobile app with two main user-facing features:

1. Printer workflow for scanning, connecting, and printing a shipping card to ESC/POS printers.
2. OCR workflow for picking or capturing an image and extracting text from it.

The app currently opens with a login screen, then routes users into the main feature area after a basic username and password check.

## Main Screens

### Login

- File: `lib/src/core/view/auth/login_page.dart`
- Purpose: gate access to the app before entering the feature area

### Printer Page

- File: `lib/src/printer_page.dart`
- Purpose: manage Bluetooth printer connection and print the preview card

### Text Scanner Page

- File: `lib/src/core/view/ocr/text_scanner_page.dart`
- Purpose: upload or capture an image, run OCR, display extracted text, and allow copy/select text

## State Management

The app uses `signals_flutter` for reactive UI state.

Examples:

- Printer state is handled in `lib/src/controllers/printer_page_controller_mixin.dart`
- OCR state is handled in `lib/src/core/view/ocr/controller_mixin.dart`

The pages are mostly view code, while the mixins hold logic, async work, and signal values.

## Navigation Structure

The app uses a shared drawer menu from `lib/src/widgets/app_menu_drawer.dart`.

Current destinations:

- Printer
- Text Scanner

The drawer also contains placeholders for future features such as Orders and Settings.

## Important Dependencies

- `unified_esc_pos_printer`: printer discovery, connect, and print support
- `permission_handler`: runtime permissions
- `signals_flutter`: reactive state
- `image_picker`: gallery and camera image selection
- `flutter_tesseract_ocr`: OCR with Khmer and English language data

## Assets

- Khmer font: `assets/fonts/Siemreap-Regular.ttf`
- Login logo: `assets/logo/logo.jpg`
- OCR tessdata config: `assets/tessdata_config.json`
- OCR trained data: `assets/tessdata/eng.traineddata`, `assets/tessdata/khm.traineddata`
