class PrintTemplateData {
  const PrintTemplateData({
    required this.customerName,
    required this.pageName,
    required this.phoneLines,
    required this.locationLines,
    required this.virakChecked,
    required this.jtChecked,
    required this.otherChecked,
  });

  final String customerName;
  final String pageName;
  final List<String> phoneLines;
  final List<String> locationLines;
  final bool virakChecked;
  final bool jtChecked;
  final bool otherChecked;
}
