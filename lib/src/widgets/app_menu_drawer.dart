import 'package:flutter/material.dart';
import 'package:r99/src/core/database/app_preferences_store.dart';
import 'package:r99/src/core/services/supabase_auth_service.dart';
import 'package:r99/src/core/view/auth/login_page.dart';
import 'package:r99/src/printer_page.dart';

enum AppMenuDestination { printer, textScanner, invoices, deliveries, logs }

class AppMenuDrawer extends StatefulWidget {
  const AppMenuDrawer({
    super.key,
    required this.currentDestination,
    required this.onSelectDestination,
  });

  final AppMenuDestination currentDestination;
  final ValueChanged<AppMenuDestination> onSelectDestination;

  @override
  State<AppMenuDrawer> createState() => _AppMenuDrawerState();
}

class _AppMenuDrawerState extends State<AppMenuDrawer> {
  bool showPreview = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadPreviewPreference();
  }

  Future<void> loadPreviewPreference() async {
    final savedValue = await AppPreferencesStore.loadShowPreview();
    if (!mounted) return;
    setState(() {
      showPreview = savedValue;
    });
  }

  Future<void> togglePreview(bool value) async {
    setState(() {
      showPreview = value;
      isSaving = true;
    });

    try {
      await AppPreferencesStore.saveShowPreview(value);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        showPreview = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save preview setting')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    await SupabaseAuthService.signOut();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onLoginSuccess: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PrinterPage()),
              (_) => false,
            );
          },
        ),
      ),
      (_) => false,
    );
  }

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
              selected: widget.currentDestination == AppMenuDestination.printer,
              onTap: () =>
                  widget.onSelectDestination(AppMenuDestination.printer),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: const Text('Text Scanner'),
              selected:
                  widget.currentDestination == AppMenuDestination.textScanner,
              onTap: () =>
                  widget.onSelectDestination(AppMenuDestination.textScanner),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Invoices'),
              selected:
                  widget.currentDestination == AppMenuDestination.invoices,
              onTap: () =>
                  widget.onSelectDestination(AppMenuDestination.invoices),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: const Text('Deliveries'),
              selected:
                  widget.currentDestination == AppMenuDestination.deliveries,
              onTap: () =>
                  widget.onSelectDestination(AppMenuDestination.deliveries),
            ),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Health Logs'),
              selected: widget.currentDestination == AppMenuDestination.logs,
              onTap: () => widget.onSelectDestination(AppMenuDestination.logs),
            ),
            const Divider(height: 24),
            SwitchListTile(
              secondary: const Icon(Icons.visibility_outlined),
              title: const Text('Show Preview'),
              subtitle: Text(
                showPreview ? 'Preview is visible' : 'Preview is hidden',
              ),
              value: showPreview,
              onChanged: isSaving ? null : togglePreview,
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Sign Out'),
              onTap: confirmSignOut,
            ),
          ],
        ),
      ),
    );
  }
}
