import 'package:flutter/material.dart';
import 'package:r99/print_template_data.dart';
import 'package:r99/widgets/template_checkbox_chip.dart';

class PrintTemplateCard extends StatelessWidget {
  const PrintTemplateCard({super.key, required this.data});

  final PrintTemplateData data;

  TextStyle get _khmerTitleStyle => const TextStyle(
    fontFamily: 'Siemreap',
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: Colors.black,
    height: 1.25,
  );

  TextStyle get _khmerBodyStyle => const TextStyle(
    fontFamily: 'Siemreap',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    height: 1.3,
  );

  TextStyle get _khmerSmallStyle => const TextStyle(
    fontFamily: 'Siemreap',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    height: 1.8,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: const Border(
            top: BorderSide(color: Colors.black, width: 4),
            bottom: BorderSide(color: Colors.black, width: 4),
            left: BorderSide(color: Colors.black, width: 2),
            right: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.facebook_rounded, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              data.customerName.isEmpty ? 'Name' : data.customerName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _InfoBox(
                          icon: Icons.facebook_rounded,
                          title: 'ផេកហ្វេសប៊ុក',
                          lines: [data.pageName.isEmpty ? '-' : data.pageName],
                          titleStyle: _khmerTitleStyle,
                          bodyStyle: _khmerBodyStyle,
                        ),
                        const SizedBox(height: 10),
                        _InfoBox(
                          icon: Icons.call,
                          title: 'លេខទូរស័ព្ទ',
                          lines: data.phoneLines.isEmpty ? const ['-'] : data.phoneLines,
                          titleStyle: _khmerTitleStyle,
                          bodyStyle: _khmerBodyStyle,
                        ),
                        const SizedBox(height: 10),
                        _InfoBox(
                          icon: Icons.location_on,
                          title: 'ទីតាំង',
                          lines: data.locationLines.isEmpty ? const ['-'] : data.locationLines,
                          titleStyle: _khmerTitleStyle,
                          bodyStyle: _khmerBodyStyle,
                          tall: true,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFBDBDBD)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_shipping_outlined, size: 22, fontWeight: FontWeight.w500),
                              const SizedBox(width: 8),
                              Expanded(child: Text('សេវាកម្ម', style: _khmerTitleStyle)),
                              Text('ដឹកជញ្ជូន', style: _khmerTitleStyle),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TemplateCheckboxChip(label: 'វីរៈប៊ុនថាំ', selected: data.virakChecked),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TemplateCheckboxChip(label: 'J&T', selected: data.jtChecked),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'សូមអរគុណសម្រាប់ការគាំទ្រ និងជួយចែករំលែកផង',
                          textAlign: TextAlign.center,
                          style: _khmerSmallStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.lines,
    required this.titleStyle,
    required this.bodyStyle,
    this.tall = false,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(title, style: titleStyle),
            ],
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: tall ? 7 : 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: Text(line, style: bodyStyle),
            ),
        ],
      ),
    );
  }
}
