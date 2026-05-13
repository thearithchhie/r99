import 'package:r99/src/core/database/app_database.dart';
import 'package:r99/src/core/database/models/print_invoice.dart';
import 'package:r99/src/print_template_data.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

class PrintInvoiceStore {
  const PrintInvoiceStore._();

  static PrintInvoice buildInvoice(
    PrintTemplateData data, {
    required PrinterDevice? connectedDevice,
    required String Function(PrinterDevice device) deviceTransport,
  }) {
    return PrintInvoice()
      ..createdAt = DateTime.now()
      ..customerName = data.customerName
      ..pageName = data.pageName
      ..phoneLines = List<String>.from(data.phoneLines)
      ..locationLines = List<String>.from(data.locationLines)
      ..selectedOption = data.selectedOption
      ..totalPrice = data.totalPrice
      ..currency = data.currency
      ..guestServiceChecked = data.guestServiceChecked
      ..virakChecked = data.virakChecked
      ..jtChecked = data.jtChecked
      ..otherChecked = data.otherChecked
      ..printerName = connectedDevice?.name ?? ''
      ..printerTransport = connectedDevice == null
          ? ''
          : deviceTransport(connectedDevice);
  }

  static Future<void> saveTemplateAsInvoice(
    PrintTemplateData data, {
    required PrinterDevice? connectedDevice,
    required String Function(PrinterDevice device) deviceTransport,
  }) async {
    final invoice = buildInvoice(
      data,
      connectedDevice: connectedDevice,
      deviceTransport: deviceTransport,
    );

    await AppDatabase.instance.isar.writeTxn(() async {
      await AppDatabase.instance.isar.printInvoices.put(invoice);
    });
  }
}
