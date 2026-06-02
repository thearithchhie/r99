import 'dart:io';

import 'package:r99/export.dart';
import 'package:r99/gen/fonts.gen.dart';

class PrintTemplateCard extends StatelessWidget {
  const PrintTemplateCard({super.key, required this.data});

  static const double printWidth = 360;

  final PrintTemplateData data;

  TextStyle get khmerTitleStyle => TextStyle(
    fontFamily: FontFamily.siemreap,
    fontSize: Platform.isAndroid ? 20 : 24,
    fontWeight: FontWeight.w900,
    color: AppColor.pureBlack,
    height: 1.25,
  );

  TextStyle get khmerBodyStyleCustomerName => TextStyle(
    fontFamily: FontFamily.siemreap,
    fontSize: Platform.isAndroid ? 20 : 22,
    fontWeight: FontWeight.w900,
    color: AppColor.pureBlack,
    height: 1.25,
  );

  TextStyle get khmerBodyStyleLocation => TextStyle(
    fontFamily: FontFamily.siemreap,
    fontSize: Platform.isAndroid ? 20 : 24,
    fontWeight: FontWeight.w900,
    color: AppColor.pureBlack,
    height: 1.25,
  );

  TextStyle get bodyStylePhone => const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColor.pureBlack);

  TextStyle get khmerBodyStyle => const TextStyle(
    fontFamily: FontFamily.siemreap,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColor.pureBlack,
    height: 1.3,
  );

  TextStyle get _khmerSmallStyle =>
      const TextStyle(fontFamily: FontFamily.siemreap, fontSize: 24, fontWeight: FontWeight.w800, height: 1.4);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: printWidth,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.pureWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.pureBlack, width: 3),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (data.customerName == ColumMapHeader.shop.key) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.facebook_rounded, size: 22, fontWeight: FontWeight.w500),
                              const SizedBox(width: 5),
                              Text('ឈ្មោះផេក៖', style: khmerBodyStyle),
                              const SizedBox(width: 5),
                              Text('R99', style: khmerBodyStyle),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            alignment: WrapAlignment.center,
                            children: [
                              const Icon(Icons.phone, size: 22, fontWeight: FontWeight.w500),
                              Text('លេខទូរស័ព្ទអ្នកផ្ញើរ ឬ លុយ', style: khmerBodyStyle),
                              Text(
                                '097 71 56 486',
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColor.pureBlack),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 15),
                        _InfoBox(
                          icon: Icons.person,
                          title: 'ឈ្មោះអតិថិជន',
                          lines: [data.pageName.isEmpty ? '-' : data.pageName],
                          titleStyle: khmerTitleStyle,
                          bodyStyle: khmerBodyStyleCustomerName,
                        ),
                        const SizedBox(height: 10),
                        _InfoBox(
                          icon: Icons.call,
                          title: 'លេខទូរស័ព្ទអ្នកទទួល',
                          lines: data.phoneLines.isEmpty
                              ? const ['-']
                              : data.phoneLines.map((value) => value.formatPhonePreview()).toList(),
                          titleStyle: khmerTitleStyle,
                          bodyStyle: bodyStylePhone,
                        ),
                        const SizedBox(height: 10),
                        _InfoBox(
                          icon: Icons.location_on,
                          title: 'ទីតាំង',
                          lines: data.locationLines.isEmpty ? const ['-'] : data.locationLines,
                          titleStyle: khmerTitleStyle,
                          bodyStyle: khmerBodyStyleLocation,
                          tall: true,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColor.surfaceMuted,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColor.borderLight, width: 1.4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_shipping_outlined, size: 24, fontWeight: FontWeight.w500),
                              const SizedBox(width: 8),
                              Expanded(child: Text('សេវាដឹក', style: khmerTitleStyle)),
                              Text(
                                data.totalPrice.isEmpty
                                    ? 'តម្លៃសរុប៖ ${data.currency}${data.selectedOption}'
                                    : 'តម្លៃសរុប៖ ${data.currency}${data.totalPrice}',
                                style: khmerTitleStyle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TemplateCheckboxChip(label: 'សេវាខាងភ្ញៀវ', selected: data.guestServiceChecked),
                            ),
                            const SizedBox(width: 8),
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
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.borderLight, width: 1.4),
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
          const SizedBox(height: 5),
          for (int index = 0; index < lines.length; index++) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: tall ? 7 : 5),
              decoration: BoxDecoration(
                color: AppColor.pureWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.borderSubtle, width: 1.4),
              ),
              child: Text(lines[index], style: bodyStyle),
            ),
            // if (index != lines.length - 1) const SizedBox(height: 0),
          ],
        ],
      ),
    );
  }
}
