import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

enum BluetoothPermissionResult { granted, denied, permanentlyDenied }

class PermissionWrapper {
  PermissionWrapper._();

  static final PermissionWrapper _instance = PermissionWrapper._();

  factory PermissionWrapper() => _instance;

  static PermissionWrapper get instance => _instance;

  Future<BluetoothPermissionResult> requestBluetoothScanPermissions() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return BluetoothPermissionResult.granted;
    }

    if (Platform.isIOS) {
      final bluetoothStatus = await Permission.bluetooth.request();

      if (bluetoothStatus.isGranted) {
        return BluetoothPermissionResult.granted;
      }

      if (bluetoothStatus.isPermanentlyDenied) {
        return BluetoothPermissionResult.permanentlyDenied;
      }

      return BluetoothPermissionResult.denied;
    }

    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    final statuses = [scanStatus, connectStatus];

    if (statuses.every((status) => status.isGranted)) {
      return BluetoothPermissionResult.granted;
    }

    if (statuses.any((status) => status.isPermanentlyDenied)) {
      return BluetoothPermissionResult.permanentlyDenied;
    }

    return BluetoothPermissionResult.denied;
  }

  Future<bool> openSettings() {
    return openAppSettings();
  }
}
