class PrintTemplateData {
  const PrintTemplateData({
    required this.customerName,
    required this.pageName,
    required this.phoneLines,
    required this.locationLines,
    required this.selectedOption,
    required this.totalPrice,
    required this.currency,
    required this.guestServiceChecked,
    required this.virakChecked,
    required this.jtChecked,
    required this.jtCod,
    required this.otherChecked,
  });

  final String customerName;
  final String pageName;
  final List<String> phoneLines;
  final List<String> locationLines;
  final String selectedOption;
  final String totalPrice;
  final String currency;
  final bool guestServiceChecked;
  final bool virakChecked;
  final bool jtChecked;
  final bool jtCod;
  final bool otherChecked;

  String get jtLabel {
    if (!jtCod) return 'J&T';
    if (locationLines.isEmpty) return 'J&T(COD)';
    return '${locationLines[0].split(' | ').first.trim()}(COD)';
  }

  Map<String, Object?> toMacOSPrintMap() {
    return {
      'customerName': customerName,
      'pageName': pageName,
      'phoneLines': phoneLines,
      'locationLines': locationLines,
      'selectedOption': selectedOption,
      'totalPrice': totalPrice,
      'currency': currency,
      'guestServiceChecked': guestServiceChecked,
      'virakChecked': virakChecked,
      'jtChecked': jtChecked,
      'jtCod': jtCod,
      'jtLabel': jtLabel,
      'otherChecked': otherChecked,
    };
  }
}
