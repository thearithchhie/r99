import 'package:flutter/material.dart';
import 'package:r99/src/core/database/models/delivery_record.dart';
import 'package:r99/src/core/view/delivery_import/controller_mixin.dart';
import 'package:r99/src/utilities/app_colors.dart';
import 'package:r99/src/widgets/app_menu_drawer.dart';
import 'package:r99/src/widgets/print_template_card.dart';
import 'package:signals_flutter/signals_flutter.dart';

class DeliveryImportPage extends StatefulWidget {
  const DeliveryImportPage({super.key});

  @override
  State<DeliveryImportPage> createState() => _DeliveryImportPageState();
}

class _DeliveryImportPageState extends State<DeliveryImportPage>
    with DeliveryImportPageControllerMixin {
  Future<void> confirmDeleteAll() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete all deliveries?'),
          content: const Text(
            'This will remove every imported delivery from local history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      await deleteAllDeliveryRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppMenuDrawer(
        currentDestination: AppMenuDestination.deliveries,
        onSelectDestination: onSelectDestination,
      ),
      appBar: AppBar(title: const Text('Deliveries')),
      body: Watch((context) {
        final previewRecord = activePreviewRecord.value;
        final queryText = searchController.text;

        Widget content;
        if ((isLoading.value || isSearching.value) &&
            deliveryRecords.value.isEmpty) {
          content = const Center(child: CircularProgressIndicator());
        } else if (errorMessage.value != null &&
            deliveryRecords.value.isEmpty) {
          content = Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColor.errorText),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => searchQuery.value.isEmpty
                        ? loadDeliveryRecords()
                        : onSearchChanged(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (deliveryRecords.value.isEmpty) {
          content = Center(
            child: Text(
              searchQuery.value.isEmpty
                  ? 'No imported deliveries yet.'
                  : 'No deliveries found for this phone number',
            ),
          );
        } else {
          content = ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...deliveryRecords.value.map(
                (record) => _DeliveryCard(
                  record: record,
                  onUseAgain: () => openDeliveryForReprint(record),
                  onDelete: isImporting.value || isPrintingAll.value
                      ? null
                      : () => deleteDeliveryRecord(record),
                ),
              ),
            ],
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Google Sheet Import',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Paste a public Google Sheet share URL. The app will download the sheet, scrape rows as-is, and replace the local delivery import list.',
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: sheetUrlController,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              labelText: 'Google Sheet URL',
                              hintText:
                                  'https://docs.google.com/spreadsheets/d/.../edit',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              filled: true,
                              fillColor: AppColor.pureWhite,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed:
                                      isImporting.value || isPrintingAll.value
                                      ? null
                                      : importFromGoogleSheet,
                                  icon: const Icon(
                                    Icons.cloud_download_outlined,
                                  ),
                                  label: Text(
                                    isImporting.value
                                        ? 'Importing...'
                                        : 'Import Deliveries',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      isImporting.value ||
                                          isPrintingAll.value ||
                                          deliveryRecords.value.isEmpty
                                      ? null
                                      : printAllDeliveries,
                                  icon: const Icon(Icons.print_outlined),
                                  label: Text(
                                    isPrintingAll.value
                                        ? 'Printing...'
                                        : 'Print All',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed:
                                  isImporting.value ||
                                      isPrintingAll.value ||
                                      allDeliveryRecords.value.isEmpty
                                  ? null
                                  : confirmDeleteAll,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete All'),
                            ),
                          ),
                          if (summaryMessage.value != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColor.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColor.borderLighter,
                                ),
                              ),
                              child: Text(summaryMessage.value!),
                            ),
                          ],
                          if (importMessages.value.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...importMessages.value.map(
                              (message) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• $message',
                                  style: const TextStyle(
                                    color: AppColor.errorText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: TextField(
                    controller: searchController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Optional: search by phone number',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: queryText.isEmpty
                          ? null
                          : IconButton(
                              onPressed: searchController.clear,
                              icon: const Icon(Icons.close),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: AppColor.pureWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: content),
              ],
            ),
            if (previewRecord != null)
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: const Offset(0, 2400),
                    child: RepaintBoundary(
                      key: printPreviewKey,
                      child: PrintTemplateCard(
                        data: templateDataFromRecord(previewRecord),
                      ),
                    ),
                  ),
                ),
              ),
            if (isImporting.value || isPrintingAll.value) ...[
              const ModalBarrier(
                dismissible: false,
                color: AppColor.overlayScrim,
              ),
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          isImporting.value
                              ? 'Importing deliveries...'
                              : 'Printing all deliveries...',
                        ),
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

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.record,
    required this.onUseAgain,
    required this.onDelete,
  });

  final DeliveryRecord record;
  final VoidCallback onUseAgain;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final detailStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColor.neutral500);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.customerName.isEmpty ? '-' : record.customerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  record.price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(record.shop.isEmpty ? '-' : record.shop, style: detailStyle),
            const SizedBox(height: 6),
            Text(record.phone.isEmpty ? '-' : record.phone, style: detailStyle),
            const SizedBox(height: 6),
            Text(
              record.location.isEmpty ? '-' : record.location,
              style: detailStyle,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.deliverService.isEmpty ? '-' : record.deliverService,
                    style: detailStyle,
                  ),
                ),
                Text('Printed ${record.printCount}x', style: detailStyle),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onUseAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Use Again'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
