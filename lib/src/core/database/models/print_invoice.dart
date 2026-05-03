import 'package:isar_community/isar.dart';

part 'print_invoice.g.dart';

@collection
class PrintInvoice {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime createdAt;

  String customerName = '';
  String pageName = '';
  List<String> phoneLines = [];
  List<String> locationLines = [];
  String selectedOption = '';
  String totalPrice = '';
  String currency = '';
  bool guestServiceChecked = false;
  bool virakChecked = false;
  bool jtChecked = false;
  bool otherChecked = false;
  String printerName = '';
  String printerTransport = '';
}
