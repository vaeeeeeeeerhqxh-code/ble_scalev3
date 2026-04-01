import 'package:flutter/material.dart';
import 'package:ble_scale_app/Device/device_apple.dart';
import 'package:ble_scale_app/Device/device_banana.dart';
import 'package:ble_scale_app/Device/device_borre.dart';
import 'package:ble_scale_app/Device/device_coconut.dart';
import 'package:ble_scale_app/Device/device_egg.dart';
import 'package:ble_scale_app/Device/device_fish.dart';
import 'package:ble_scale_app/Device/device_grapes.dart';
import 'package:ble_scale_app/Device/device_hamburger.dart';
import 'package:ble_scale_app/Device/device_ice.dart';
import 'package:ble_scale_app/Device/device_jambul.dart';
import 'package:ble_scale_app/Device/device_torre.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/enums/pp_scale_enums.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ui/theme.dart';

class BleScanPage extends StatefulWidget {
  const BleScanPage({super.key});

  @override
  State<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage> {
  bool _isScanning = false;
  final List<PPDeviceModel> _scanResults = [];

  @override
  void initState() {
    super.initState();
    PPBluetoothKitManager.addBlePermissionListener(callBack: (permission) {
      print('Bluetooth permission state changed:$permission');
    });
    PPBluetoothKitManager.addScanStateListener(callBack: (scanning) {
      if (mounted) {
        setState(() => _isScanning = scanning);
      }
    });
    // Автоматически начинаем скан при открытии
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScanPressed());
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
        statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bluetooth permissions are required for scanning")),
        );
      }
    }
  }

  Future<void> _onScanPressed() async {
    await _requestPermissions();
    setState(() => _scanResults.clear());
    PPBluetoothKitManager.startScan((device) {
      if (mounted) {
        setState(() {
          final index = _scanResults.indexWhere((e) => e.deviceMac == device.deviceMac);
          if (index == -1) {
            _scanResults.add(device);
          } else {
            _scanResults[index] = device;
          }
        });
      }
    });
  }

  Future<void> _onStopPressed() async {
    PPBluetoothKitManager.stopScan();
  }

  void _handleDeviceTap(PPDeviceModel device) {
    PPBluetoothKitManager.stopScan();
    Widget page;
    switch (device.getDevicePeripheralType()) {
      case PPDevicePeripheralType.apple:
        page = DeviceApple(device: device); break;
      case PPDevicePeripheralType.coconut:
        page = DeviceCoconut(device: device); break;
      case PPDevicePeripheralType.banana:
        page = DeviceBanana(device: device); break;
      case PPDevicePeripheralType.ice:
        page = DeviceIce(device: device); break;
      case PPDevicePeripheralType.jambul:
        page = DeviceJambul(device: device); break;
      case PPDevicePeripheralType.torre:
        page = DeviceTorre(device: device); break;
      case PPDevicePeripheralType.borre:
        page = DeviceBorre(device: device); break;
      case PPDevicePeripheralType.fish:
        page = DeviceFish(device: device); break;
      case PPDevicePeripheralType.hamburger:
        page = DeviceHamburger(device: device); break;
      case PPDevicePeripheralType.egg:
        page = DeviceEgg(device: device); break;
      case PPDevicePeripheralType.grapes:
        page = DeviceGrapes(device: device); break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    PPBluetoothKitManager.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        title: const Text('Подключить весы', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B3E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isScanning)
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
              onPressed: _onStopPressed,
              tooltip: 'Остановить',
            )
          else
            IconButton(
              icon: Icon(Icons.refresh, color: accent),
              onPressed: _onScanPressed,
              tooltip: 'Сканировать',
            ),
        ],
      ),
      body: _scanResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_searching, size: 64, color: accent.withOpacity(0.7)),
                  const SizedBox(height: 20),
                  Text(
                    _isScanning
                        ? 'Сканирование устройств...'
                        : 'Устройства не найдены\nили Bluetooth выключен',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  if (_isScanning) CircularProgressIndicator(color: accent),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final device = _scanResults[index];
                return GestureDetector(
                  onTap: () => _handleDeviceTap(device),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [primary, accent]),
                          ),
                          child: const Icon(Icons.scale, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.deviceName?.toString().isNotEmpty == true
                                    ? device.deviceName.toString()
                                    : 'Unknown Device',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('RSSI: ${device.rssi}',
                                  style: TextStyle(color: Colors.white.withOpacity(0.6))),
                              const SizedBox(height: 2),
                              Text(device.deviceMac?.toString() ?? 'No MAC',
                                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
