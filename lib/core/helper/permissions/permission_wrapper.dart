import 'package:permission_handler/permission_handler.dart';

class PermissionWrapper {
  PermissionWrapper._();

  static final PermissionWrapper _instance = PermissionWrapper._();

  factory PermissionWrapper() => _instance;

  static PermissionWrapper get instance => _instance;

  Future<bool> requestBluetoothScanPermissions() async {
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();

    PermissionStatus locationStatus = PermissionStatus.granted;
    if (await Permission.locationWhenInUse.isDenied || await Permission.locationWhenInUse.isRestricted) {
      locationStatus = await Permission.locationWhenInUse.request();
    }

    return scanStatus.isGranted && connectStatus.isGranted && locationStatus.isGranted;
  }
}
