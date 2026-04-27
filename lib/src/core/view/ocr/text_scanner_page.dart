import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:r99/src/core/view/ocr/controller_mixin.dart';
import 'package:r99/src/utilities/app_colors.dart';
import 'package:r99/src/widgets/app_menu_drawer.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TextScannerPage extends StatefulWidget {
  const TextScannerPage({super.key});

  @override
  State<TextScannerPage> createState() => _TextScannerPageState();
}

class _TextScannerPageState extends State<TextScannerPage>
    with TextScannerPageControllerMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppMenuDrawer(
        currentDestination: AppMenuDestination.textScanner,
        onSelectDestination: onSelectDestination,
      ),
      appBar: AppBar(title: const Text('Text Scanner')),
      body: Watch((context) {
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Extract text from an image',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose an image from the gallery or capture a new one with the camera.',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isProcessing.value
                            ? null
                            : () => pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Upload Image'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isProcessing.value
                            ? null
                            : () => pickImage(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Take Photo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Image Preview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 220),
                          decoration: BoxDecoration(
                            color: AppColor.surfacePreview,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColor.borderLighter),
                          ),
                          child: selectedImage.value == null
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('No image selected'),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.file(
                                    File(selectedImage.value!.path),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Extracted Text',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: isProcessing.value
                                  ? null
                                  : copyExtractedText,
                              icon: const Icon(Icons.copy_outlined, size: 18),
                              label: const Text('Copy'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 260,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColor.pureWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColor.borderLighter),
                          ),
                          child: errorMessage.value != null
                              ? SingleChildScrollView(
                                  child: SelectableText(
                                    errorMessage.value!,
                                    style: const TextStyle(
                                      color: AppColor.errorText,
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: SelectableText(
                                    extractedText.value.isEmpty
                                        ? 'Recognized text will appear here.'
                                        : extractedText.value,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isProcessing.value) ...[
              const ModalBarrier(
                dismissible: false,
                color: AppColor.overlayScrim,
              ),
              const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Extracting text...'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
