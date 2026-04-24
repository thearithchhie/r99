import 'package:flutter/material.dart';

class TemplateCheckboxChip extends StatelessWidget {
  const TemplateCheckboxChip({super.key, required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8F4EA) : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),

        // border: Border.all(color: selected ? const Color(0xFF2E7D32) : const Color(0xFFBDBDBD)),
        // border: Border.all(color: selected ? const Color(0xFF2E7D32) : const Color.fromARGB(255, 0, 0, 0)),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2E7D32) : Colors.transparent,
              border: Border.all(color: selected ? const Color.fromARGB(255, 3, 243, 15) : const Color(0xFF666666)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Siemreap',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: child);
  }
}
