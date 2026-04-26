class PrintTemplateData {
  const PrintTemplateData({
    required this.customerName,
    required this.pageName,
    required this.phoneLines,
    required this.locationLines,
    required this.totalPrice,
    required this.currency,
    required this.guestServiceChecked,
    required this.virakChecked,
    required this.jtChecked,
    required this.otherChecked,
  });

  final String customerName;
  final String pageName;
  final List<String> phoneLines;
  final List<String> locationLines;
  final String totalPrice;
  final String currency;
  final bool guestServiceChecked;
  final bool virakChecked;
  final bool jtChecked;
  final bool otherChecked;
}
