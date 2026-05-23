import 'package:flutter/material.dart';
import 'package:r99/src/controllers/printer_page_controller_mixin.dart';
import 'package:r99/src/core/database/models/print_invoice.dart';
import 'package:r99/src/core/view/delivery_import/delivery_import_page.dart';
import 'package:r99/src/core/view/invoice/invoice_list_page.dart';
import 'package:r99/src/core/view/ocr/text_scanner_page.dart';
import 'package:r99/src/utilities/app_colors.dart';
import 'package:r99/src/widgets/app_menu_drawer.dart';
import 'package:r99/src/widgets/print_template_card.dart';
import 'package:r99/src/widgets/print_template_editor.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key, this.initialInvoice});

  final PrintInvoice? initialInvoice;

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage>
    with PrinterPageControllerMixin {
  void onSelectDestination(AppMenuDestination destination) {
    Navigator.of(context).pop();
    switch (destination) {
      case AppMenuDestination.printer:
        return;
      case AppMenuDestination.textScanner:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TextScannerPage()));
      case AppMenuDestination.invoices:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const InvoiceListPage()));
      case AppMenuDestination.deliveries:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DeliveryImportPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppMenuDrawer(
        currentDestination: AppMenuDestination.printer,
        onSelectDestination: onSelectDestination,
      ),
      appBar: AppBar(
        title: const Text('R99 Shop'),
        centerTitle: true,
        actions: [
          Watch((context) {
            return IconButton(
              onPressed: state.value == PrinterConnectionState.connected
                  ? disconnectPrinter
                  : null,
              icon: const Icon(Icons.link_off),
            );
          }),
        ],
      ),
      body: Watch((context) {
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.value != PrinterConnectionState.connected)
                  Card(
                    child: ListTile(
                      title: const Text('Printer Status'),
                      subtitle: Text('State: ${prettyState(state.value)}'),
                      trailing: Text(
                        connectedDevice.value == null
                            ? 'No device'
                            : '${connectedDevice.value!.name}\n${deviceTransport(connectedDevice.value!)}',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                if (connectedViaBle) ...[
                  const SizedBox(height: 12),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('BLE connected'),
                      subtitle: Text(
                        'Printing is blocked on BLE. Pair the printer in Android Bluetooth settings, disconnect this device, and connect to the Classic Bluetooth entry instead.',
                      ),
                    ),
                  ),
                ],
                if (isDesktopUsbMode &&
                    state.value != PrinterConnectionState.connected) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.usb_outlined),
                      title: const Text('Desktop USB note'),
                      subtitle: Text(desktopUsbHelpText),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                PrintTemplateEditor(
                  customerNameController: customerNameController,
                  onCustomerNameChanged: setCustomerName,
                  pageNameController: pageNameController,
                  totalPriceController: totalPriceController,
                  selectedOption: selectedOption.value,
                  onSelectedOptionChanged: setSelectedOption,
                  currency: currency.value,
                  onCurrencyChanged: setCurrency,
                  phoneControllers: phoneControllers.value,
                  locationControllers: locationControllers.value,
                  guestServiceChecked: guestServiceChecked.value,
                  virakChecked: virakChecked.value,
                  jtChecked: jtChecked.value,
                  otherChecked: otherChecked.value,
                  onAddPhone: addPhoneField,
                  onAddLocation: addLocationField,
                  onRemovePhone: removePhoneField,
                  onRemoveLocation: removeLocationField,
                  onToggleGuestService: toggleGuestService,
                  onToggleVirak: toggleVirak,
                  onToggleJt: toggleJt,
                  onToggleOther: toggleOther,
                ),
                const SizedBox(height: 16),
                if (showPreview.value) ...[
                  const Text(
                    'Card Preview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: RepaintBoundary(
                      key: cardPreviewKey,
                      child: PrintTemplateCard(data: templateData),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  const Card(
                    color: AppColor.surfaceMuted,
                    child: ListTile(
                      leading: Icon(Icons.visibility_off_outlined),
                      title: Text('Preview hidden'),
                      subtitle: Text('Turn it back on from the menu toggle.'),
                    ),
                  ),
                  Offstage(
                    offstage: true,
                    child: RepaintBoundary(
                      key: cardPreviewKey,
                      child: PrintTemplateCard(data: templateData),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isScanning.value ? null : startScan,
                        child: Text(
                          isScanning.value ? 'Scanning...' : 'Scan Printers',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canPrintDesign ? printDesign : null,
                        child: const Text('Print Design'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.value != PrinterConnectionState.connected &&
                    printerDevices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        isDesktopUsbMode
                            ? desktopUsbEmptyStateText
                            : 'No printer devices found.\nMake sure the printer is powered on and paired, then scan again.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (state.value != PrinterConnectionState.connected)
                  ...printerDevices.map((device) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.print),
                        title: Text(deviceDisplayName(device)),
                        subtitle: Text(deviceSubtitle(device)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => connectPrinter(device),
                      ),
                    );
                  }),
              ],
            ),
            if (isScanning.value &&
                state.value != PrinterConnectionState.connected) ...[
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
                        Text('Scanning printers...'),
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
