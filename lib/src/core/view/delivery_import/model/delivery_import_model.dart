import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';
import 'package:r99/src/utilities/enum.dart';

class ParsedPrice {
  const ParsedPrice({required this.currency, required this.amount});

  final String currency;
  final String amount;
}

ParsedPrice parsePrice(String rawPrice) {
  final trimmed = rawPrice.trim();
  final currencyType = CurrencyType.fromRawPrice(trimmed);
  final amount = trimmed.startsWith(currencyType.symbol)
      ? trimmed.substring(currencyType.symbol.length).trim()
      : trimmed;

  return ParsedPrice(currency: currencyType.symbol, amount: amount);
}

String normalizeShopValue(String value) {
  return ShopType.normalizeKey(value);
}

String deviceTransport(PrinterDevice device) {
  return switch (device.connectionType) {
    PrinterConnectionType.bluetooth => 'Classic Bluetooth',
    PrinterConnectionType.ble => 'BLE',
    PrinterConnectionType.usb => 'USB',
    PrinterConnectionType.network => 'Network',
  };
}
