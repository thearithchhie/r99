import 'package:r99/src/core/database/models/delivery_record.dart';
import 'package:r99/src/print_template_data.dart';
import 'package:r99/src/utilities/enum.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

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

PrintTemplateData buildTemplateDataFromRecord(DeliveryRecord record) {
  final parsedPrice = parsePrice(record.price);
  final serviceLabel = record.deliverService.trim();
  final compact = serviceLabel.toUpperCase().replaceAll(RegExp(r'[\s\-–—_]'), '');
  final isJtCod = compact == 'J&TCOD';
  final isVetCod = compact == 'VETCOD';
  final isCod = isJtCod || isVetCod;
  final isJt = !isCod && compact == 'J&T';
  final isServicePaidByCustomer =
      compact == DeliverServiceValue.servicePaidByCustomer.toUpperCase().replaceAll('_', '');
  final hasOtherService = serviceLabel.isNotEmpty && !isJt && !isCod && !isServicePaidByCustomer;

  final codPrefix = isJtCod ? 'J&T' : 'VET';
  final locationLines = [if (isCod) '$codPrefix | លុយខ្មែរ = ${record.convertedTotal}', record.location];

  return PrintTemplateData(
    customerName: normalizeShopValue(record.shop),
    pageName: record.customerName,
    phoneLines: [record.phone],
    locationLines: locationLines,
    selectedOption: '0',
    totalPrice: parsedPrice.amount,
    currency: parsedPrice.currency,
    guestServiceChecked: isServicePaidByCustomer,
    virakChecked: false,
    jtChecked: isJt || isCod,
    jtCod: isCod,
    otherChecked: hasOtherService,
  );
}

String deviceTransport(PrinterDevice device) {
  return switch (device.connectionType) {
    PrinterConnectionType.bluetooth => 'Classic Bluetooth',
    PrinterConnectionType.ble => 'BLE',
    PrinterConnectionType.usb => 'USB',
    PrinterConnectionType.network => 'Network',
  };
}
