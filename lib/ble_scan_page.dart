import 'dart:math';
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

class BleScanPage extends StatefulWidget {
  const BleScanPage({super.key});

  @override
  State<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage>
    with TickerProviderStateMixin {
  bool _isScanning = false;
  final List<PPDeviceModel> _scanResults = [];

  // Анимации
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    PPBluetoothKitManager.addBlePermissionListener(callBack: (permission) {});
    PPBluetoothKitManager.addScanStateListener(callBack: (scanning) {
      if (mounted) setState(() => _isScanning = scanning);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _onScanPressed());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    PPBluetoothKitManager.stopScan();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<void> _onScanPressed() async {
    await _requestPermissions();
    setState(() => _scanResults.clear());
    PPBluetoothKitManager.startScan((device) {
      if (mounted) {
        setState(() {
          final index =
          _scanResults.indexWhere((e) => e.deviceMac == device.deviceMac);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar кастомный
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text('Подключить весы',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                  ),
                  if (_isScanning)
                    GestureDetector(
                      onTap: _onStopPressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.redAccent.withOpacity(0.4)),
                        ),
                        child: const Text('Стоп',
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 13)),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _onScanPressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C6EF5).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF4C6EF5).withOpacity(0.4)),
                        ),
                        child: const Text('Сканировать',
                            style: TextStyle(
                                color: Color(0xFF4C6EF5), fontSize: 13)),
                      ),
                    ),
                ],
              ),
            ),

            // Основной контент
            Expanded(
              child: _scanResults.isEmpty
                  ? _buildScanningView()
                  : _buildResultsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    return Column(
      children: [
        const SizedBox(height: 32),

        // Текст состояния
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isScanning
                    ? 'Поиск устройств...'
                    : 'Устройства не найдены',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _isScanning
                    ? 'Убедитесь что весы включены\nи находятся рядом'
                    : 'Включите Bluetooth и попробуйте снова',
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Анимация сканирования
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Пульсирующие кольца
              if (_isScanning) ...[
                _PulseRing(delay: 0, color: const Color(0xFF4C6EF5)),
                _PulseRing(delay: 0.4, color: const Color(0xFF4C6EF5)),
                _PulseRing(delay: 0.8, color: const Color(0xFF4C6EF5)),
              ],

              // Вращающаяся дуга
              if (_isScanning)
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (_, __) => Transform.rotate(
                    angle: _rotateController.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(200, 200),
                      painter: _ArcPainter(),
                    ),
                  ),
                ),

              // Центральный круг
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: _isScanning ? _pulseAnim.value : 1.0,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D1B3E),
                      border: Border.all(
                        color: const Color(0xFF4C6EF5).withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4C6EF5).withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_searching,
                          color: const Color(0xFF4C6EF5),
                          size: _isScanning ? 36 : 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isScanning ? 'Поиск' : 'Стоп',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Иллюстрация весов снизу
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              // Весы SVG-подобные
              _buildScaleIllustration(),
              const SizedBox(height: 16),
              Text(
                _isScanning
                    ? 'Нажмите на весы для активации'
                    : 'Нажмите «Сканировать» для поиска',
                textAlign: TextAlign.center,
                style:
                const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildScaleIllustration() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A2340).withOpacity(0.8),
              const Color(0xFF0D1224).withOpacity(0.9),
            ],
          ),
          border: Border.all(
            color: _isScanning
                ? const Color(0xFF4C6EF5)
                .withOpacity(0.3 + 0.2 * _pulseAnim.value)
                : Colors.white12,
          ),
          boxShadow: _isScanning
              ? [
            BoxShadow(
              color: const Color(0xFF4C6EF5).withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.scale,
                color: _isScanning
                    ? const Color(0xFF4C6EF5)
                    : Colors.white24,
                size: 32),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Умные весы',
                  style: TextStyle(
                    color: _isScanning ? Colors.white70 : Colors.white38,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isScanning ? 'Ожидание подключения...' : 'Не найдено',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Text(
                'Найдено: ${_scanResults.length}',
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (_isScanning)
                Row(
                  children: [
                    SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF4C6EF5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('Сканирование...',
                        style: TextStyle(color: Color(0xFF4C6EF5), fontSize: 12)),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _scanResults.length,
            itemBuilder: (context, index) {
              final device = _scanResults[index];
              final name = device.deviceName?.toString().isNotEmpty == true
                  ? device.deviceName.toString()
                  : 'Unknown Device';
              final rssi = device.rssi ?? 0;
              final signalStrength = _signalStrength(rssi);

              return GestureDetector(
                onTap: () => _handleDeviceTap(device),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2340),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                        const Color(0xFF4C6EF5).withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4C6EF5).withOpacity(0.08),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Иконка устройства
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4C6EF5), Color(0xFF339AF0)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4C6EF5).withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.scale,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),

                      // Инфо
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              device.deviceMac?.toString() ?? '',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      // Сигнал + стрелка
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.white38, size: 14),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                signalStrength == 'Отлично'
                                    ? Icons.signal_cellular_alt
                                    : signalStrength == 'Хорошо'
                                    ? Icons.signal_cellular_alt_2_bar
                                    : Icons.signal_cellular_alt_1_bar,
                                color: signalStrength == 'Отлично'
                                    ? Colors.green
                                    : signalStrength == 'Хорошо'
                                    ? Colors.orange
                                    : Colors.redAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(signalStrength,
                                  style: TextStyle(
                                    color: signalStrength == 'Отлично'
                                        ? Colors.green
                                        : signalStrength == 'Хорошо'
                                        ? Colors.orange
                                        : Colors.redAccent,
                                    fontSize: 11,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _signalStrength(int rssi) {
    if (rssi >= -60) return 'Отлично';
    if (rssi >= -80) return 'Хорошо';
    return 'Слабый';
  }
}

// Пульсирующее кольцо
class _PulseRing extends StatefulWidget {
  final double delay;
  final Color color;
  const _PulseRing({required this.delay, required this.color});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    Future.delayed(
      Duration(milliseconds: (widget.delay * 800).toInt()),
          () {
        if (mounted) _ctrl.repeat();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(_opacity.value),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// Вращающаяся дуга
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [Colors.transparent, Color(0xFF4C6EF5)],
        stops: [0.7, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2 - 2,
      ),
      0, 2 * pi, false, paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => false;
}