import 'package:flutter/material.dart';
import 'package:r99/src/core/database/models/print_invoice.dart';
import 'package:r99/src/utilities/app_colors.dart';
import 'package:r99/src/utilities/enum.dart';

class InvoiceCardWidget extends StatelessWidget {
  const InvoiceCardWidget({
    super.key,
    required this.invoice,
    required this.amount,
    required this.onUseAgain,
  });

  final PrintInvoice invoice;
  final String amount;
  final VoidCallback onUseAgain;

  String get shopDisplayName {
    return ShopType.fromRaw(invoice.customerName)?.value ??
        invoice.customerName;
  }

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
                    shopDisplayName,
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
