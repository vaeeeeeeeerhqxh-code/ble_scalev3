import 'dart:async';
import 'package:ble_scale_app/core/body_analyzer.dart';
import 'package:ble_scale_app/ui/widgets/analysis_grid.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_peripheral_ice.dart';
import 'package:pp_bluetooth_kit_flutter/enums/pp_scale_enums.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_body_base_model.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_model.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_user.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_wifi_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ble_scale_app/app_state.dart';

class DeviceIce extends StatefulWidget {
  final PPDeviceModel device;
  const DeviceIce({super.key, required this.device});

  @override
  State<DeviceIce> createState() => _DeviceIceState();
}

class _DeviceIceState extends State<DeviceIce> {
  // --- Состояние измерений ---
  PPDeviceConnectionState _connectionStatus = PPDeviceConnectionState.disconnected;
  double _weightValue = 0;
  String _measurementStateStr = 'Ожидание...';
  bool _isMeasuring = false;
  bool _showResults = false;
  Timer? _timer;
  Map<String, dynamic> _analysisResult = {};

  // --- Единица измерения (сохраняется через SharedPreferences) ---
  PPUnitType _unit = PPUnitType.Unit_KG;

  // --- Профиль пользователя ---
  final PPDeviceUser _userProfile = PPDeviceUser(
    userHeight: 180,
    age: 18,
    sex: PPUserGender.male,
    unitType: PPUnitType.Unit_KG,
  );

  @override
  void initState() {
    super.initState();
    _loadUnitPreference();
    _startConnection();
  }

  // Загружаем сохранённую единицу измерения
  Future<void> _loadUnitPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final unit = prefs.getString('unit_weight') ?? 'kg';
    if (mounted) {
      setState(() {
        _unit = unit == 'lb' ? PPUnitType.Unit_LB : PPUnitType.Unit_KG;
      });
    }
  }

  // Сохраняем единицу измерения
  Future<void> _saveUnitPreference(PPUnitType unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unit_weight', unit == PPUnitType.Unit_LB ? 'lb' : 'kg');
  }

  void _startConnection() {
    PPBluetoothKitManager.connectDevice(widget.device, callBack: (state) {
      if (state == PPDeviceConnectionState.connected) {
        // Синхронизируем сохранённую единицу
        PPPeripheralIce.syncUnit(_unit);

        // Включаем импеданс для анализа состава тела
        Future.delayed(const Duration(seconds: 2), () async {
          await PPPeripheralIce.impedanceSwitchControl(true);
        });
      }

      // Keep-alive каждые 10 секунд
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        PPPeripheralIce.keepAlive();
      });

      if (mounted) setState(() => _connectionStatus = state);
    });

    PPBluetoothKitManager.addMeasurementListener(
      callBack: (measurementState, dataModel, device) {
        if (mounted) {
          setState(() {
            _weightValue = dataModel.weight / 100.0;

            if (measurementState == PPMeasurementDataState.completed) {
              _measurementStateStr = 'Готово';
              _isMeasuring = false;
              _showResults = true;
              
              final result = BodyAnalyzer.calculate(
                weight: _weightValue,
                impedanceValues: AppState.instance.lastImpedanceValues,
                profile: UserProfile(
                  height: _userProfile.userHeight.toDouble(),
                  age: _userProfile.age,
                  isMale: _userProfile.sex == PPUserGender.male,
                ),
              );

              _analysisResult = result;

              if (result.isNotEmpty) {
                AppState.instance.addRecord(MeasurementRecord(
                  date: DateTime.now(),
                  weight: _weightValue,
                  bodyFat: (result['bodyFat'] ?? 0).toDouble(),
                  muscle: (result['muscle'] ?? 0).toDouble(),
                  water: (result['water'] ?? 0).toDouble(),
                  bmi: (result['bmi'] ?? 0).toDouble(),
                  bmr: (result['bmr'] ?? 0).toDouble(),
                  boneMass: (result['boneMass'] ?? 0).toDouble(),
                  visceralFat: (result['visceralFat'] ?? 0).toDouble(),
                  protein: (result['protein'] ?? 0).toDouble(),
                  bodyAge: (result['bodyAge'] ?? 0).toDouble(),
                  bodyHealth: (result['bodyHealth'] ?? 0).toDouble(),
                  mLa: (result['m_la'] ?? 0).toDouble(),
                  mRa: (result['m_ra'] ?? 0).toDouble(),
                  mLl: (result['m_ll'] ?? 0).toDouble(),
                  mRl: (result['m_rl'] ?? 0).toDouble(),
                  mTr: (result['m_tr'] ?? 0).toDouble(),
                ));
              }
            } else if (measurementState == PPMeasurementDataState.measuringBodyFat) {
              _measurementStateStr = 'Анализ состава тела...';
              _isMeasuring = true;
            } else if (measurementState == PPMeasurementDataState.measuringHeartRate) {
              _measurementStateStr = 'Измерение пульса...';
              _isMeasuring = true;
            } else {
              if (!_showResults) {
                _measurementStateStr = 'Взвешивание...';
                _isMeasuring = false;
              }
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    PPBluetoothKitManager.stopScan();
    PPBluetoothKitManager.disconnect();
    super.dispose();
  }

  // --- ДЕЙСТВИЯ УСТРОЙСТВА ---

  Future<void> _toggleUnit() async {
    _unit = _unit == PPUnitType.Unit_KG ? PPUnitType.Unit_LB : PPUnitType.Unit_KG;
    await _saveUnitPreference(_unit);
    if (_connectionStatus == PPDeviceConnectionState.connected) {
      await PPPeripheralIce.syncUnit(_unit);
    }
    if (mounted) setState(() {});
  }

  Future<void> _fetchHistory() async {
    if (_connectionStatus != PPDeviceConnectionState.connected) return;
    PPPeripheralIce.fetchHistoryData(callBack: (dataList, isSuccess) {
      if (isSuccess && dataList.isNotEmpty) {
        PPPeripheralIce.deleteHistoryData();
      }
    });
  }

  Future<void> _configWifi() async {
    if (_connectionStatus != PPDeviceConnectionState.connected) return;
    _showWifiInputDialog(context, (ssid, password) async {
      final PPWifiResult result = await PPPeripheralIce.configWifi(
        domain: "http://120.79.144.170:6032",
        ssId: ssid,
        password: password,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.success ? 'Wi-Fi настроен успешно' : 'Ошибка настройки Wi-Fi'),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _wifiOTA() async {
    if (_connectionStatus != PPDeviceConnectionState.connected) return;
    final ret = await PPPeripheralIce.wifiOTA();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTA: $ret')),
      );
    }
  }

  Future<void> _syncDeviceLog() async {
    if (_connectionStatus != PPDeviceConnectionState.connected) return;
    final directory = await getApplicationDocumentsDirectory();
    final logDirectory = '${directory.path}/DeviceLog';
    PPPeripheralIce.syncDeviceLog(logDirectory, callBack: (progress, isFailed, filePath) {
      // Sync log callback
    });
  }

  Future<void> _syncTime() async {
    if (_connectionStatus != PPDeviceConnectionState.connected) return;
    await PPPeripheralIce.syncTime();
  }

  Future<void> _resetDevice() async {
    if (_connectionStatus != PPDeviceConnectionState.connected) return;
    PPPeripheralIce.resetDevice();
  }

  void _showWifiInputDialog(BuildContext context, Function(String ssid, String password) callBack) {
    final TextEditingController ssidController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Настройка Wi-Fi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ssidController,
                decoration: const InputDecoration(
                  labelText: 'SSID (название сети)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final ssid = ssidController.text;
                final password = passwordController.text;
                Navigator.pop(context);
                callBack(ssid, password);
              },
              child: const Text('Подключить'),
            ),
          ],
        );
      },
    );
  }

  // --- UI КОМПОНЕНТЫ ---

  Widget _buildWeightBlock() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4C6EF5), Color(0xFFCC5DE8)]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: const Color(0xFFCC5DE8).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Text(_measurementStateStr, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 10),
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: _weightValue),
            duration: const Duration(milliseconds: 500),
            builder: (_, double value, __) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15, left: 8),
                    child: Text(
                      _unit == PPUnitType.Unit_LB ? "lb" : "kg",
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ],
              );
            },
          ),
          Text(
            _connectionStatus == PPDeviceConnectionState.connected ? "Подключено" : "Поиск весов...",
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            _measurementStateStr,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          const Text(
            "Пожалуйста, не сходите с весов",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildActionChip(
            Icons.swap_horiz,
            _unit == PPUnitType.Unit_KG ? "→ lb" : "→ kg",
            _toggleUnit,
          ),
          _buildActionChip(Icons.history, "История", _fetchHistory),
          _buildActionChip(Icons.access_time, "Синх. время", _syncTime),
          _buildActionChip(Icons.wifi, "Wi-Fi", _configWifi),
          _buildActionChip(Icons.system_update, "OTA", _wifiOTA),
          _buildActionChip(Icons.article_outlined, "Логи", _syncDeviceLog),
          _buildActionChip(Icons.refresh, "Сброс", () => PPPeripheralIce.exitNetworkConfig()),
          _buildActionChip(Icons.restore, "Завод. уст.", _resetDevice),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFCC5DE8), size: 18),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        title: Text(widget.device.deviceName ?? "Умные весы"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Column(
        children: [
          _buildWeightBlock(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "АНАЛИЗ СОСТАВА ТЕЛА",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _weightValue == 0
                  ? const Center(
                      child: Text(
                        "Встаньте на весы голыми ногами",
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : _isMeasuring
                      ? _buildAnalysisLoading()
                      : _showResults
                          ? AnalysisGrid(data: _analysisResult)
                          : const Center(
                              child: Text(
                                "Ожидание завершения анализа...",
                                style: TextStyle(color: Colors.white38),
                              ),
                            ),
            ),
          ),
          _buildSettingsPanel(),
        ],
      ),
    );
  }
}
