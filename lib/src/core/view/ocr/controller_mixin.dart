import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:r99/src/core/view/delivery_import/delivery_import_page.dart';
import 'package:r99/src/core/view/invoice/invoice_list_page.dart';
import 'package:r99/src/core/view/ocr/text_scanner_page.dart';
import 'package:r99/src/printer_page.dart';
import 'package:r99/src/widgets/app_menu_drawer.dart';
import 'package:signals_flutter/signals_flutter.dart';

mixin TextScannerPageControllerMixin on State<TextScannerPage> {
  final ImagePicker imagePicker = ImagePicker();

  final selectedImage = signal<XFile?>(null);
  final extractedText = signal<String>('');
  final errorMessage = signal<String?>(null);
  final isProcessing = signal<bool>(false);

  bool get isWindowsDesktop => Platform.isWindows;

  Future<void> pickImage(ImageSource source) async {
    if (isWindowsDesktop) {
      errorMessage.value =
          'Text Scanner is not available on Windows yet. The current OCR package in this app only supports Android and iOS.';
      return;
    }

    try {
      final XFile? image = await imagePicker.pickImage(source: source);
      if (image == null) {
        errorMessage.value = 'No image selected.';
        return;
      }

      selectedImage.value = image;
      extractedText.value = '';
      errorMessage.value = null;
      isProcessing.value = true;

      final recognizedText = await FlutterTesseractOcr.extractText(
        image.path,
        language: 'khm+eng',
        args: {'psm': '6', 'preserve_interword_spaces': '1'},
      );

      if (!mounted) return;

      extractedText.value = recognizedText.trim();
      if (extractedText.value.isEmpty) {
        errorMessage.value = 'No text found in the selected image.';
      }
    } catch (error) {
      if (!mounted) return;
      errorMessage.value =
          'Unable to read text. Please check permissions and try again.\n$error';
    } finally {
      if (mounted) {
        isProcessing.value = false;
      }
    }
  }

  void onSelectDestination(AppMenuDestination destination) {
    Navigator.of(context).pop();
    switch (destination) {
      case AppMenuDestination.textScanner:
        return;
      case AppMenuDestination.printer:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PrinterPage()),
        );
      case AppMenuDestination.invoices:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InvoiceListPage()),
        );
      case AppMenuDestination.deliveries:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DeliveryImportPage()),
        );
    }
  }

  Future<void> copyExtractedText() async {
    if (extractedText.value.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No extracted text to copy')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: extractedText.value));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Extracted text copied')));
  }

  @override
  void dispose() {
    selectedImage.dispose();
    extractedText.dispose();
    errorMessage.dispose();
    isProcessing.dispose();
    super.dispose();
  }
}
