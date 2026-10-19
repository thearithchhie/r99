import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:r99/src/core/database/models/delivery_record.dart';
import 'package:r99/src/core/view/delivery_import/delivery_import_page.dart';
import 'package:r99/src/core/view/delivery_import/model/delivery_import_model.dart';
import 'package:r99/src/core/view/health_log/health_log_page.dart';
import 'package:r99/src/core/view/invoice/invoice_list_page.dart';
import 'package:r99/src/core/view/ocr/text_scanner_page.dart';
import 'package:r99/src/print_template_data.dart';
import 'package:r99/src/printer_page.dart';
import 'package:r99/src/utilities/enum.dart';
import 'package:r99/src/widgets/app_menu_drawer.dart';
import 'package:r99/src/widgets/print_template_card.dart';

enum _ServiceFilter {
  standard('Standard'),
  jt('J&T'),
  jtCod('J&T-COD'),
  vet('VET'),
  vetCod('VET-COD'),
  guestService('សេវាខាងភ្ញៀវ');

  const _ServiceFilter(this.label);
  final String label;
}

class _TemplateEntry {
  const _TemplateEntry({required this.name, required this.shopType});
  final String name;
  final ShopType shopType;
}

const _templates = [
  _TemplateEntry(name: 'R99 Label', shopType: ShopType.r99),
  _TemplateEntry(name: 'R99-II Label', shopType: ShopType.r99II),
];

PrintTemplateData _buildPreview(ShopType shopType, _ServiceFilter filter) {
  final record = DeliveryRecord()
    ..shop = shopType.key
    ..customerName = shopType == ShopType.r99 ? 'សុខ ចន្ទ័' : 'ចាន់ ដារា'
    ..phone = shopType == ShopType.r99 ? '012 345 678' : '098 765 432'
    ..location = shopType == ShopType.r99 ? 'ភ្នំពេញ, ខណ្ឌចំការមន' : 'សៀមរាប, ខណ្ឌស្វាយដង្គំ'
    ..price = '\$25'
    ..convertedTotal = '4000'
    ..deliverService = switch (filter) {
      _ServiceFilter.standard => '',
      _ServiceFilter.jt => 'J&T',
      _ServiceFilter.jtCod => DeliverServiceValue.jtCod,
      _ServiceFilter.vet => 'VET',
      _ServiceFilter.vetCod => DeliverServiceValue.vetCod,
      _ServiceFilter.guestService => DeliverServiceValue.servicePaidByCustomer,
    };
  return buildTemplateDataFromRecord(record);
}

class TemplateListPage extends StatefulWidget {
  const TemplateListPage({super.key});

  @override
  State<TemplateListPage> createState() => _TemplateListPageState();
}

class _TemplateListPageState extends State<TemplateListPage> {
  _ServiceFilter _selected = _ServiceFilter.standard;

  void _onSelectDestination(AppMenuDestination destination) {
    Navigator.of(context).pop();
    switch (destination) {
      case AppMenuDestination.templates:
        return;
      case AppMenuDestination.printer:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PrinterPage()));
      case AppMenuDestination.textScanner:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TextScannerPage()));
      case AppMenuDestination.invoices:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const InvoiceListPage()));
      case AppMenuDestination.deliveries:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DeliveryImportPage()));
      case AppMenuDestination.logs:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HealthLogPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppMenuDrawer(
        currentDestination: AppMenuDestination.templates,
        onSelectDestination: _onSelectDestination,
      ),
      appBar: AppBar(title: const Text('Templates')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _ServiceFilter.values.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter.label),
                          selected: _selected == filter,
                          onSelected: (_) => setState(() => _selected = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 16),
              Expanded(
                child: MasonryGridView.count(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    final preview = _buildPreview(template.shopType, _selected);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            template.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Center(child: PrintTemplateCard(data: preview)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
