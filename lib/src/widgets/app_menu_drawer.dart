import 'package:flutter/material.dart';

enum AppMenuDestination { printer, textScanner }

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({
    super.key,
    required this.currentDestination,
    required this.onSelectDestination,
  });

  final AppMenuDestination currentDestination;
  final ValueChanged<AppMenuDestination> onSelectDestination;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              title: Text(
                'R99 Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              subtitle: Text('More features can be added here later'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: const Text('Printer'),
              selected: currentDestination == AppMenuDestination.printer,
              onTap: () => onSelectDestination(AppMenuDestination.printer),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: const Text('Text Scanner'),
              selected: currentDestination == AppMenuDestination.textScanner,
              onTap: () => onSelectDestination(AppMenuDestination.textScanner),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Orders'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orders will be added soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings will be added soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
