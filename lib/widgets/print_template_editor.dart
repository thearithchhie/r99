import 'package:flutter/material.dart';
import 'package:r99/widgets/template_checkbox_chip.dart';

class PrintTemplateEditor extends StatelessWidget {
  const PrintTemplateEditor({
    super.key,
    required this.customerNameController,
    required this.pageNameController,
    required this.phoneNumberController,
    required this.extraPhoneController,
    required this.location1Controller,
    required this.location2Controller,
    required this.location3Controller,
    required this.virakChecked,
    required this.jtChecked,
    required this.otherChecked,
    required this.onToggleVirak,
    required this.onToggleJt,
    required this.onToggleOther,
  });

  final TextEditingController customerNameController;
  final TextEditingController pageNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController extraPhoneController;
  final TextEditingController location1Controller;
  final TextEditingController location2Controller;
  final TextEditingController location3Controller;
  final bool virakChecked;
  final bool jtChecked;
  final bool otherChecked;
  final VoidCallback onToggleVirak;
  final VoidCallback onToggleJt;
  final VoidCallback onToggleOther;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Template Input', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _InputField(controller: customerNameController, label: 'Name'),
                const SizedBox(height: 10),
                _InputField(controller: pageNameController, label: 'Facebook / Page Name'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InputField(controller: phoneNumberController, label: 'Phone 1'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InputField(controller: extraPhoneController, label: 'Phone 2'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _InputField(controller: location1Controller, label: 'ទីតាំង 1'),
                const SizedBox(height: 10),
                _InputField(controller: location2Controller, label: 'ទីតាំង 2'),
                const SizedBox(height: 10),
                _InputField(controller: location3Controller, label: 'ទីតាំង 3'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TemplateCheckboxChip(label: 'វីរៈប៊ុនថាំ', selected: virakChecked, onTap: onToggleVirak),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TemplateCheckboxChip(label: 'J&T', selected: jtChecked, onTap: onToggleJt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
