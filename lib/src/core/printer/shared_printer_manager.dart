import 'package:signals_flutter/signals_flutter.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

final PrinterManager sharedPrinterManager = PrinterManager();
final Signal<PrinterDevice?> sharedMacOSNativePrinterDevice =
    signal<PrinterDevice?>(null);
