import 'package:flutter/material.dart';
import 'package:r99/src/utilities/app_colors.dart';
import 'package:r99/src/widgets/template_checkbox_chip.dart';

class PrintTemplateEditor extends StatelessWidget {
  const PrintTemplateEditor({
    super.key,
    required this.customerNameController,
    required this.onCustomerNameChanged,
    required this.pageNameController,
    required this.totalPriceController,
    required this.selectedOption,
    required this.onSelectedOptionChanged,
    required this.currency,
    required this.onCurrencyChanged,
    required this.phoneControllers,
    required this.locationControllers,
    required this.guestServiceChecked,
    required this.virakChecked,
    required this.jtChecked,
    required this.otherChecked,
    required this.onAddPhone,
    required this.onAddLocation,
    required this.onRemovePhone,
    required this.onRemoveLocation,
    required this.onToggleGuestService,
    required this.onToggleVirak,
    required this.onToggleJt,
    required this.onToggleOther,
  });

  final TextEditingController customerNameController;
  final ValueChanged<String> onCustomerNameChanged;
  final TextEditingController pageNameController;
  final TextEditingController totalPriceController;
  final String selectedOption;
  final ValueChanged<String> onSelectedOptionChanged;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  final List<TextEditingController> phoneControllers;
  final List<TextEditingController> locationControllers;
  final bool guestServiceChecked;
  final bool virakChecked;
  final bool jtChecked;
  final bool otherChecked;
  final VoidCallback onAddPhone;
  final VoidCallback onAddLocation;
  final void Function(int index) onRemovePhone;
  final void Function(int index) onRemoveLocation;
  final VoidCallback onToggleGuestService;
  final VoidCallback onToggleVirak;
  final VoidCallback onToggleJt;
  final VoidCallback onToggleOther;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Template Input',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: customerNameController.text,
                  decoration: InputDecoration(
                    labelText: 'ឈ្នោះផេក',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: AppColor.pureWhite,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'shop', child: Text('shop')),
                    DropdownMenuItem(value: 'none', child: Text('none')),
                  ],
                  onChanged: (value) {
                    if (value != null) onCustomerNameChanged(value);
                  },
                ),
                const SizedBox(height: 10),
                _InputField(
                  controller: pageNameController,
                  label: 'ឈ្នោះអតិថិជន',
                ),
                const SizedBox(height: 10),
                _DynamicFieldGroup(
                  title: 'លេខទូរស័ព្ទ',
                  icon: Icons.add,
                  onAdd: onAddPhone,
                  controllers: phoneControllers,
                  labelBuilder: (index) => 'លេខទូរស័ព្ទ ${index + 1}',
                  onRemove: onRemovePhone,
                ),
                const SizedBox(height: 10),
                _DynamicFieldGroup(
                  title: 'ទីតាំង',
                  icon: Icons.add,
                  onAdd: onAddLocation,
                  controllers: locationControllers,
                  labelBuilder: (index) => 'ទីតាំង ${index + 1}',
                  onRemove: onRemoveLocation,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "តម្លៃសរុប៖ ",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InputField(
                        controller: totalPriceController,
                        label: 'តម្លៃសរុប',
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 92,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedOption,
                        decoration: InputDecoration(
                          labelText: 'ជម្រើស',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: AppColor.pureWhite,
                        ),
                        items: const [
                          DropdownMenuItem(value: '0', child: Text('0')),
                          DropdownMenuItem(value: '2', child: Text('2')),
                          DropdownMenuItem(value: '10', child: Text('10')),
                          DropdownMenuItem(value: '11', child: Text('11')),
                          DropdownMenuItem(value: '12', child: Text('12')),
                          DropdownMenuItem(value: '18', child: Text('18')),
                          DropdownMenuItem(value: '19', child: Text('19')),
                          DropdownMenuItem(value: '20', child: Text('20')),
                          DropdownMenuItem(value: '23', child: Text('23')),
                        ],
                        onChanged: (value) {
                          if (value != null) onSelectedOptionChanged(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 92,
                      child: DropdownButtonFormField<String>(
                        initialValue: currency,
                        decoration: InputDecoration(
                          labelText: 'រូបិយប័ណ្ណ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: AppColor.pureWhite,
                        ),
                        items: const [
                          DropdownMenuItem(value: '\$', child: Text('\$')),
                          DropdownMenuItem(value: '៛', child: Text('៛')),
                        ],
                        onChanged: (value) {
                          if (value != null) onCurrencyChanged(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TemplateCheckboxChip(
                        label: 'សេវាខាងភ្ញៀវ',
                        selected: guestServiceChecked,
                        onTap: onToggleGuestService,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TemplateCheckboxChip(
                        label: 'វីរៈប៊ុនថាំ',
                        selected: virakChecked,
                        onTap: onToggleVirak,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TemplateCheckboxChip(
                        label: 'J&T',
                        selected: jtChecked,
                        onTap: onToggleJt,
                      ),
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
        fillColor: AppColor.pureWhite,
      ),
    );
  }
}

class _DynamicFieldGroup extends StatelessWidget {
  const _DynamicFieldGroup({
    required this.title,
    required this.icon,
    required this.onAdd,
    required this.controllers,
    required this.labelBuilder,
    required this.onRemove,
  });

  final String title;
  final IconData icon;
  final VoidCallback onAdd;
  final List<TextEditingController> controllers;
  final String Function(int index) labelBuilder;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: onAdd,
              icon: Icon(icon),
              tooltip: 'Add $title',
            ),
          ],
        ),
        for (int index = 0; index < controllers.length; index++) ...[
          Row(
            children: [
              Expanded(
                child: _InputField(
                  controller: controllers[index],
                  label: labelBuilder(index),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: controllers.length > 1
                    ? () => onRemove(index)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                tooltip: 'Remove ${labelBuilder(index)}',
              ),
            ],
          ),
          if (index != controllers.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
