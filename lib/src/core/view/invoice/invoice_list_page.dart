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

class _InvoiceListPageState extends State<InvoiceListPage>
    with InvoiceListPageControllerMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppMenuDrawer(
        currentDestination: AppMenuDestination.invoices,
        onSelectDestination: onSelectDestination,
      ),
      appBar: AppBar(title: const Text('Invoices')),
      body: Watch((context) {
        if (isInitialLoading.value && invoices.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage.value != null && invoices.value.isEmpty) {
          return Center(
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
                    onPressed: () => loadInvoices(reset: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (invoices.value.isEmpty) {
          return const Center(child: Text('No invoices yet'));
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: invoices.value.length + (isLoadingMore.value ? 1 : 0),
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
            );
          },
        );
      }),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.amount});

  final PrintInvoice invoice;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final detailStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColor.neutral500);

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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              invoice.pageName.isEmpty ? '-' : invoice.pageName,
              style: detailStyle,
            ),
            const SizedBox(height: 6),
            Text(
              invoice.phoneLines.isEmpty ? '-' : invoice.phoneLines.join(', '),
              style: detailStyle,
            ),
            const SizedBox(height: 6),
            Text(
              invoice.locationLines.isEmpty
                  ? '-'
                  : invoice.locationLines.join(', '),
              style: detailStyle,
            ),
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
                Text(
                  invoice.createdAt.toLocal().toString().substring(0, 16),
                  style: detailStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
