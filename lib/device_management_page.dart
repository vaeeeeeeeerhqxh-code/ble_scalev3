import 'package:flutter/material.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_peripheral_ice.dart';
import 'package:pp_bluetooth_kit_flutter/enums/pp_scale_enums.dart';
import 'ble_scan_page.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  bool _isConnected = false;
  String _statusMessage = '';

  void _showMessage(String msg, {bool isError = false}) {
    setState(() => _statusMessage = msg);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _runIfConnected(Future<void> Function() action) async {
    if (!_isConnected) {
      _showMessage('Весы не подключены', isError: true);
      return;
    }
    await action();
  }

  Future<void> _syncTime() async {
    await _runIfConnected(() async {
      await PPPeripheralIce.syncTime();
      _showMessage('Время синхронизировано');
    });
  }

  Future<void> _fetchHistory() async {
    await _runIfConnected(() async {
      PPPeripheralIce.fetchHistoryData(callBack: (dataList, isSuccess) {
        _showMessage('Получено записей: ${dataList.length}');
        if (isSuccess && dataList.isNotEmpty) {
          PPPeripheralIce.deleteHistoryData();
        }
      });
    });
  }

  Future<void> _fetchBattery() async {
    await _runIfConnected(() async {
      PPPeripheralIce.fetchBatteryInfo(continuity: false, callBack: (power) {
        _showMessage('Заряд батареи: $power%');
      });
    });
  }

  Future<void> _toggleImpedance(bool enable) async {
    await _runIfConnected(() async {
      await PPPeripheralIce.impedanceSwitchControl(enable);
      _showMessage(enable ? 'Импеданс включён' : 'Импеданс выключен');
    });
  }

  Future<void> _resetDevice() async {
    await _runIfConnected(() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A2340),
          title: const Text('Сброс устройства', style: TextStyle(color: Colors.white)),
          content: const Text('Вы уверены? Все настройки весов будут сброшены.',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Сбросить', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        PPPeripheralIce.resetDevice();
        _showMessage('Устройство сброшено');
      }
    });
  }

  Future<void> _configWifi() async {
    await _runIfConnected(() async {
      final ssidCtrl = TextEditingController();
      final passCtrl = TextEditingController();
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A2340),
          title: const Text('Настройка Wi-Fi', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(ssidCtrl, 'SSID (название сети)', Icons.wifi),
              const SizedBox(height: 12),
              _dialogField(passCtrl, 'Пароль', Icons.lock_outline, obscure: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final result = await PPPeripheralIce.configWifi(
                  domain: 'http://120.79.144.170:6032',
                  ssId: ssidCtrl.text,
                  password: passCtrl.text,
                );
                _showMessage(result.success ? 'Wi-Fi настроен' : 'Ошибка Wi-Fi',
                    isError: !result.success);
              },
              child: const Text('Подключить', style: TextStyle(color: Color(0xFF4C6EF5))),
            ),
          ],
        ),
      );
    });
  }

  Widget _dialogField(TextEditingController ctrl, String hint, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF0D1B3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        title: const Text('Управление устройством',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B3E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2F6B), Color(0xFF0D1B3E), Color(0xFF0A0A1A)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Статус подключения
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2340),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isConnected
                      ? Colors.green.withOpacity(0.5)
                      : const Color(0xFF4C6EF5).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: (_isConnected ? Colors.green : const Color(0xFF4C6EF5))
                          .withOpacity(0.15),
                    ),
                    child: Icon(Icons.scale,
                        color: _isConnected ? Colors.green : const Color(0xFF4C6EF5),
                        size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isConnected ? 'Весы подключены' : 'Нет подключения',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isConnected
                              ? 'Все функции доступны'
                              : 'Подключите весы для управления',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Переключатель для теста (в реальности — слушать BLE статус)
                  Switch(
                    value: _isConnected,
                    onChanged: (val) {
                      if (!val) {
                        setState(() => _isConnected = false);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BleScanPage()),
                        ).then((_) => setState(() => _isConnected = true));
                      }
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),

            if (!_isConnected) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BleScanPage()),
                ).then((_) => setState(() => _isConnected = true)),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C6EF5).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF4C6EF5).withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth_searching, color: Color(0xFF4C6EF5)),
                      SizedBox(width: 10),
                      Text('Подключить весы',
                          style: TextStyle(
                              color: Color(0xFF4C6EF5),
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            _sectionLabel('Настройки устройства'),
            const SizedBox(height: 12),

            _buildMenuCard([
              _buildTile(Icons.sync, 'Синхронизировать время', _syncTime),
              _buildTile(Icons.history, 'Получить историю', _fetchHistory),
              _buildTile(Icons.battery_full, 'Уровень заряда', _fetchBattery),
              _buildTile(Icons.wifi, 'Настройка Wi-Fi', _configWifi),
            ]),

            const SizedBox(height: 24),
            _sectionLabel('Импеданс (состав тела)'),
            const SizedBox(height: 12),

            _buildMenuCard([
              _buildTile(Icons.power, 'Включить импеданс',
                      () => _toggleImpedance(true)),
              _buildTile(Icons.power_off, 'Выключить импеданс',
                      () => _toggleImpedance(false)),
            ]),

            const SizedBox(height: 24),
            _sectionLabel('Дополнительно'),
            const SizedBox(height: 12),

            _buildMenuCard([
              _buildTile(Icons.restore, 'Сброс до заводских настроек',
                  _resetDevice, isDestructive: true),
            ]),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) => Text(title,
      style: const TextStyle(
          color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500));

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2340),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(children: [
            e.value,
            if (!isLast)
              const Divider(height: 1, color: Colors.white10, indent: 56),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildTile(IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isDestructive ? Colors.redAccent : Colors.white54, size: 22),
      title: Text(label,
          style: TextStyle(
              color: isDestructive ? Colors.redAccent : Colors.white,
              fontSize: 15)),
      trailing: Icon(
        _isConnected ? Icons.chevron_right : Icons.lock_outline,
        color: Colors.white24, size: 20,
      ),
      onTap: onTap,
    );
  }
}