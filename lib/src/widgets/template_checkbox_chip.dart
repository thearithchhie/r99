import 'package:flutter/material.dart';
import 'package:r99/gen/fonts.gen.dart';
import 'package:r99/src/utilities/app_colors.dart';

class TemplateCheckboxChip extends StatelessWidget {
  const TemplateCheckboxChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColor.transparent,
              border: Border.all(color: AppColor.pureBlack),
              borderRadius: BorderRadius.circular(3),
            ),
            child: selected
                ? const Icon(Icons.check, size: 19, color: AppColor.pureBlack)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: FontFamily.siemreap,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColor.pureBlack,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
