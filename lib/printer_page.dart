import 'package:flutter/material.dart';
import 'package:r99/controllers/printer_page_controller_mixin.dart';
import 'package:r99/widgets/print_template_card.dart';
import 'package:r99/widgets/print_template_editor.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> with PrinterPageControllerMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Printer'),
        actions: [
          Watch((context) {
            return IconButton(
              onPressed: state.value == PrinterConnectionState.connected ? disconnectPrinter : null,
              icon: const Icon(Icons.link_off),
            );
          }),
        ],
      ),
      body: Watch((context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                    'If Print Test does nothing, pair the printer in Android Bluetooth settings and connect to the Classic Bluetooth device instead of BLE.',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            PrintTemplateEditor(
              customerNameController: customerNameController,
              pageNameController: pageNameController,
              phoneNumberController: phoneNumberController,
              extraPhoneController: extraPhoneController,
              location1Controller: location1Controller,
              location2Controller: location2Controller,
              location3Controller: location3Controller,
              virakChecked: virakChecked.value,
              jtChecked: jtChecked.value,
              otherChecked: otherChecked.value,
              onToggleVirak: toggleVirak,
              onToggleJt: toggleJt,
              onToggleOther: toggleOther,
            ),
            const SizedBox(height: 16),
            const Text('Card Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            // PrintTemplateCard(data: templateData),
            Center(
              child: RepaintBoundary(
                key: cardPreviewKey,
                child: PrintTemplateCard(data: templateData),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isScanning.value ? null : startScan,
                    child: Text(isScanning.value ? 'Scanning...' : 'Scan Printers'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(onPressed: printDesign, child: const Text('Print Design')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (printerDevices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No printer devices found.\nMake sure the printer is powered on and paired, then scan again.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...printerDevices.map((device) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.print),
                    title: Text(device.name),
                    subtitle: Text(deviceSubtitle(device)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => connectPrinter(device),
                  ),
                );
              }),
          ],
        );
      }),
    );
  }
}
