import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_peripheral_ice.dart';
import 'app_state.dart';
import 'ble_scan_page.dart';
import 'all_records_page.dart';
import 'profile_manager.dart';
import 'faq_page.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  bool _isConnected = false;
  final String _deviceName = 'CF597_GNLine';

  static const _bg     = Color(0xFF0D1B3E);
  static const _card   = Color(0xFF1A2340);
  static const _accent = Color(0xFF4C6EF5);

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _runIfConnected(Future<void> Function() action) async {
    if (!_isConnected) { _showMessage('Весы не подключены', isError: true); return; }
    await action();
  }

  Future<void> _syncData() async {
    await _runIfConnected(() async {
      await PPPeripheralIce.syncTime();
      PPPeripheralIce.fetchHistoryData(callBack: (dataList, isSuccess) {
        _showMessage('Синхронизировано: ${dataList.length} записей');
        if (isSuccess && dataList.isNotEmpty) PPPeripheralIce.deleteHistoryData();
      });
    });
  }

  ({String label, Color color}) _bmiStatus(double bmi) {
    if (bmi <= 0)   return (label: '—',                  color: Colors.white38);
    if (bmi < 18.5) return (label: 'Недостаточный вес',  color: const Color(0xFF339AF0));
    if (bmi < 25.0) return (label: 'Норма',              color: const Color(0xFF51CF66));
    if (bmi < 30.0) return (label: 'Избыточный вес',     color: const Color(0xFFFF922B));
    return            (label: 'Ожирение',                color: const Color(0xFFFF6B6B));
  }

  double _bmiProgress(double bmi) =>
      bmi <= 0 ? 0.0 : ((bmi - 10) / 30).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final profile   = ProfileManager.instance.activeProfile;
        final latest    = AppState.instance.latest;
        final weight    = latest?.weight ?? 0;
        final bmi       = AppState.instance.latestFor('bmi');
        final bodyFat   = AppState.instance.latestFor('bodyFat');
        final status    = _bmiStatus(bmi);
        final progress  = _bmiProgress(bmi);

        final dateStr = latest != null
            ? '${latest.date.year}-'
            '${latest.date.month.toString().padLeft(2,'0')}-'
            '${latest.date.day.toString().padLeft(2,'0')} '
            '${latest.date.hour.toString().padLeft(2,'0')}:'
            '${latest.date.minute.toString().padLeft(2,'0')}:'
            '${latest.date.second.toString().padLeft(2,'0')}'
            : '';

        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _bg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(children: [
              Text(_deviceName,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              Text(
                _isConnected ? 'Устройство подключено' : 'Устройство не подключено',
                style: TextStyle(
                    color: _isConnected ? const Color(0xFF51CF66) : Colors.white38,
                    fontSize: 12),
              ),
            ]),
            centerTitle: true,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A2F6B), _bg, Color(0xFF0A0A1A)],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                const SizedBox(height: 20),

                // Аватар
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: _card,
                    border: Border.all(color: _accent, width: 2),
                  ),
                  child: const Icon(Icons.person, color: Colors.white54, size: 36),
                ),
                const SizedBox(height: 8),
                Text(profile?.name ?? 'Пользователь',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),

                const SizedBox(height: 16),

                // Шкала BMI
                SizedBox(
                  height: 230,
                  child: Stack(alignment: Alignment.center, children: [
                    CustomPaint(
                      size: const Size(260, 230),
                      painter: GaugePainter(progress: progress),
                    ),
                    Positioned(
                      bottom: 20,
                      child: Column(children: [
                        Text(
                          weight > 0 ? weight.toStringAsFixed(2) : '--',
                          style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        const Text('kg', style: TextStyle(color: Colors.white54, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(status.label,
                            style: TextStyle(color: status.color, fontSize: 14, fontWeight: FontWeight.w500)),
                        if (dateStr.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(dateStr,
                                style: const TextStyle(color: Colors.white24, fontSize: 11)),
                          ),
                      ]),
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                // Взвеситься
                _actionTile(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Взвеситься',
                  enabled: true,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const BleScanPage()))
                      .then((_) => setState(() => _isConnected = true)),
                ),
                const SizedBox(height: 10),

                // Синхронизация
                _actionTile(
                  icon: Icons.sync,
                  label: 'Синхронизация данных',
                  enabled: _isConnected,
                  onTap: _syncData,
                ),

                const SizedBox(height: 20),

                // Последнее измерение
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _accent.withOpacity(0.2)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Последнее измерение',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _statCell(
                          bmi > 0 ? bmi.toStringAsFixed(1) : '--', 'BMI')),
                      Expanded(child: _statCell(
                          bodyFat > 0 ? '${bodyFat.toStringAsFixed(1)}%' : '--%', 'Телесный жир')),
                    ]),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AllRecordsPage())),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Посмотреть все',
                            style: TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w500)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: _accent, size: 16),
                      ]),
                    ),
                  ]),
                ),

                // Подключить весы (если не подключено)
                if (!_isConnected) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BleScanPage()))
                        .then((_) => setState(() => _isConnected = true)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _accent.withOpacity(0.4)),
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.bluetooth_searching, color: _accent, size: 20),
                        SizedBox(width: 10),
                        Text('Подключить весы',
                            style: TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // FAQ
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FaqPage())),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _accent.withOpacity(0.2)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.help_outline, color: Colors.white54, size: 22),
                      SizedBox(width: 14),
                      Text('Часто задаваемые вопросы',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.white24, size: 20),
                    ]),
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accent.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: enabled ? _accent : Colors.white24, size: 20),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                  color: enabled ? Colors.white : Colors.white38,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Icon(Icons.chevron_right,
              color: enabled ? Colors.white24 : Colors.white12, size: 20),
        ]),
      ),
    );
  }

  Widget _statCell(String value, String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
    ]);
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  const GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.80);
    final radius = size.width * 0.44;
    const sw = 16.0;

    // Фон
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, math.pi, false,
      Paint()
        ..color = const Color(0xFF2A3A6B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    // Градиент: синий→зелёный→оранжевый→красный (по зонам BMI)
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect, math.pi, math.pi, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: math.pi,
          endAngle: math.pi * 2,
          colors: const [
            Color(0xFF339AF0), // недостаточный
            Color(0xFF51CF66), // норма
            Color(0xFFFF922B), // избыточный
            Color(0xFFFF6B6B), // ожирение
          ],
          stops: const [0.0, 0.28, 0.50, 1.0],
        ).createShader(rect),
    );

    // Указатель
    final angle = math.pi + math.pi * progress;
    final px = center.dx + radius * math.cos(angle);
    final py = center.dy + radius * math.sin(angle);

    canvas.save();
    canvas.translate(px, py);
    canvas.rotate(angle + math.pi / 2);
    canvas.drawPath(
      Path()
        ..moveTo(0, -10)
        ..lineTo(-6, 7)
        ..lineTo(6, 7)
        ..close(),
      Paint()..color = Colors.white,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(GaugePainter old) => old.progress != progress;
}