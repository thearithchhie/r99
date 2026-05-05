import 'package:flutter/material.dart';
import 'package:r99/src/core/database/models/print_invoice.dart';
import 'package:r99/src/core/view/invoice/controller_mixin.dart';
import 'package:r99/src/utilities/app_colors.dart';
import 'package:r99/src/widgets/app_menu_drawer.dart';
import 'package:signals_flutter/signals_flutter.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> with InvoiceListPageControllerMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppMenuDrawer(currentDestination: AppMenuDestination.invoices, onSelectDestination: onSelectDestination),
      appBar: AppBar(title: const Text('Invoices')),
      body: Watch((context) {
        final queryText = searchController.text;

        Widget content;
        if ((isInitialLoading.value || isSearching.value) && invoices.value.isEmpty) {
          content = const Center(child: CircularProgressIndicator());
        } else if (errorMessage.value != null && invoices.value.isEmpty) {
          content = Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColor.errorText),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => searchQuery.value.isEmpty ? loadInvoices(reset: true) : onSearchChanged(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (invoices.value.isEmpty) {
          content = Center(
            child: Text(searchQuery.value.isEmpty ? 'No invoices yet' : 'No invoices found for this phone number'),
          );
        } else {
          content = ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: invoices.value.length + (isLoadingMore.value && searchQuery.value.isEmpty ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= invoices.value.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final invoice = invoices.value[index];
              return _InvoiceCard(
                invoice: invoice,
                amount: invoiceAmount(invoice),
                onUseAgain: () => openInvoiceForReprint(invoice),
              );
            },
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: searchController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Optional: search by phone number',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: queryText.isEmpty
                      ? null
                      : IconButton(onPressed: searchController.clear, icon: const Icon(Icons.close)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: AppColor.pureWhite,
                ),
              ),
            ),
            Expanded(child: content),
          ],
        );
      }),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.amount, required this.onUseAgain});

  final PrintInvoice invoice;
  final String amount;
  final VoidCallback onUseAgain;

  @override
  Widget build(BuildContext context) {
    final detailStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColor.neutral500);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    invoice.customerName.isEmpty ? 'R99' : invoice.customerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            Text(invoice.pageName.isEmpty ? '-' : invoice.pageName, style: detailStyle),
            const SizedBox(height: 6),
            Text(invoice.phoneLines.isEmpty ? '-' : invoice.phoneLines.join(', '), style: detailStyle),
            const SizedBox(height: 6),
            Text(invoice.locationLines.isEmpty ? '-' : invoice.locationLines.join(', '), style: detailStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    invoice.printerName.isEmpty
                        ? invoice.printerTransport
                        : '${invoice.printerName} • ${invoice.printerTransport}',
                    style: detailStyle,
                  ),
                ),
                Text(invoice.createdAt.toLocal().toString().substring(0, 16), style: detailStyle),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onUseAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Use Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
