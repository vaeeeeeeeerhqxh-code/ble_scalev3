import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'diet_page.dart';
import 'health_tools_page.dart';
import 'members_page.dart';
import 'device_management_page.dart';
import 'history_page.dart';
import 'ble_scan_page.dart';
import 'app_state.dart';
import 'profile_manager.dart';
import 'all_records_page.dart';
import 'measurement_result_page.dart';
import 'measurement_details_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.title});
  final String title;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Все метрики — основные + детали + сегментарный анализ + состояние
  final List<Map<String, dynamic>> _metrics = [
    // ОСНОВНОЕ
    {'key': 'weight',      'label': 'Вес',                'unit': 'кг',   'icon': Icons.monitor_weight_outlined,      'color': const Color(0xFF4C6EF5), 'section': 'ОСНОВНОЕ'},
    {'key': 'bmi',         'label': 'ИМТ (BMI)',          'unit': '',     'icon': Icons.accessibility_new,            'color': const Color(0xFFCC5DE8), 'section': 'ОСНОВНОЕ'},
    {'key': 'bodyFat',     'label': 'Жир',                'unit': '%',    'icon': Icons.opacity,                      'color': const Color(0xFFFF6B6B), 'section': 'ОСНОВНОЕ'},
    {'key': 'muscle',      'label': 'Мышцы',              'unit': '%',    'icon': Icons.fitness_center,               'color': const Color(0xFF51CF66), 'section': 'ОСНОВНОЕ'},
    {'key': 'water',       'label': 'Вода',               'unit': '%',    'icon': Icons.water_drop_outlined,          'color': const Color(0xFF339AF0), 'section': 'ОСНОВНОЕ'},
    // ДЕТАЛИ
    {'key': 'visceralFat', 'label': 'Висцеральный жир',   'unit': '',     'icon': Icons.monitor_weight,               'color': const Color(0xFFFF922B), 'section': 'ДЕТАЛИ'},
    {'key': 'protein',     'label': 'Белок',              'unit': '%',    'icon': Icons.egg_outlined,                 'color': const Color(0xFFFFD43B), 'section': 'ДЕТАЛИ'},
    {'key': 'bmr',         'label': 'BMR',                'unit': 'ккал', 'icon': Icons.bolt,                         'color': const Color(0xFFFFD43B), 'section': 'ДЕТАЛИ'},
    {'key': 'boneMass',    'label': 'Кости',              'unit': 'кг',   'icon': Icons.brightness_high,              'color': const Color(0xFF90A4AE), 'section': 'ДЕТАЛИ'},
    // СОСТОЯНИЕ
    {'key': 'bodyAge',     'label': 'Возраст тела',       'unit': 'лет',  'icon': Icons.history,                      'color': const Color(0xFFAB47BC), 'section': 'СОСТОЯНИЕ'},
    {'key': 'bodyHealth',  'label': 'Оценка здоровья',    'unit': '/100', 'icon': Icons.favorite_outline,             'color': const Color(0xFFEC407A), 'section': 'СОСТОЯНИЕ'},
    // СЕГМЕНТАРНЫЙ АНАЛИЗ
    {'key': 'm_la',        'label': 'Мышцы — Лев. рука', 'unit': 'кг',   'icon': Icons.back_hand_outlined,           'color': const Color(0xFF26C6DA), 'section': 'СЕГМЕНТЫ'},
    {'key': 'm_ra',        'label': 'Мышцы — Пр. рука',  'unit': 'кг',   'icon': Icons.back_hand_outlined,           'color': const Color(0xFF26C6DA), 'section': 'СЕГМЕНТЫ'},
    {'key': 'm_ll',        'label': 'Мышцы — Лев. нога', 'unit': 'кг',   'icon': Icons.directions_walk,              'color': const Color(0xFF66BB6A), 'section': 'СЕГМЕНТЫ'},
    {'key': 'm_rl',        'label': 'Мышцы — Пр. нога',  'unit': 'кг',   'icon': Icons.directions_walk,              'color': const Color(0xFF66BB6A), 'section': 'СЕГМЕНТЫ'},
    {'key': 'm_tr',        'label': 'Мышцы — Туловище',  'unit': 'кг',   'icon': Icons.accessibility,                'color': const Color(0xFF42A5F5), 'section': 'СЕГМЕНТЫ'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    AppState.instance.load();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _openHistory(String key, String label, String unit, Color color) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => HistoryPage(
        metricKey: key,
        metricLabel: label,
        metricUnit: unit,
        metricColor: color,
      ),
    ));
  }

  void _showProfileSwitcher() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2340),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListenableBuilder(
        listenable: ProfileManager.instance,
        builder: (context, _) {
          final profiles = ProfileManager.instance.profiles;
          final activeId = ProfileManager.instance.activeProfile?.id;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ...profiles.map((p) {
                final isActive = p.id == activeId;
                return ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: const Color(0xFF2A3A6B),
                      border: Border.all(color: isActive ? const Color(0xFF4C6EF5) : Colors.white24, width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.white54, size: 22),
                  ),
                  title: Text(p.name, style: TextStyle(
                    color: isActive ? const Color(0xFF4C6EF5) : Colors.white,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  )),
                  subtitle: Text('${p.type} · ${p.age} лет',
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: isActive ? const Icon(Icons.check, color: Color(0xFF4C6EF5)) : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (!isActive) {
                      await ProfileManager.instance.switchProfile(p.id);
                      await AppState.instance.onProfileSwitch();
                      if (mounted) setState(() {});
                    }
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext buttonContext) async {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: const Color(0xFF1E2C4F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 200),
      items: [
        _popupItem('add_device', Icons.bluetooth_searching, 'Добавить устройство'),
        _popupItem('scan_qr', Icons.qr_code_scanner, 'Отсканировать QR'),
        _popupItem('manage_device', Icons.devices, 'Управление устройством'),
        _popupItem('manage_members', Icons.group_outlined, 'Управление участниками'),
      ],
    );

    if (result == null || !mounted) return;
    switch (result) {
      case 'add_device':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BleScanPage()));
        break;
      case 'manage_device':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceManagementPage()));
        break;
      case 'manage_members':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersPage()));
        break;
    }
  }

  PopupMenuItem<String> _popupItem(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF4C6EF5), size: 18),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2F6B), Color(0xFF0D1B3E), Color(0xFF0A0A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBodyDataTab(),
                    const DietPage(),
                    const HealthToolsPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: ProfileManager.instance,
      builder: (context, _) {
        final profile = ProfileManager.instance.activeProfile;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: const Color(0xFF1A2340),
                  border: Border.all(color: const Color(0xFF4C6EF5), width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.white54, size: 24),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _showProfileSwitcher,
                child: Row(
                  children: [
                    Text(profile?.name ?? 'Пользователь',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  ],
                ),
              ),
              const Spacer(),
            Builder(
              builder: (buttonContext) => GestureDetector(
                onTap: () => _showMenu(buttonContext),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF1A2340), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.dashboard_outlined, color: Colors.white54, size: 22),
                ),
              ),
             ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController!,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xFF4C6EF5), width: 2.5),
        ),
        tabs: const [
          Tab(text: 'Данные тела'),
          Tab(text: 'Диетические данные'),
          Tab(text: 'Инструменты'),
        ],
      ),
    );
  }

  Widget _buildBodyDataTab() {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final latest = AppState.instance.latest;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Большая карточка веса
              _buildWeightCard(latest),
              const SizedBox(height: 20),

              // Секции с карточками
              ..._buildSections(latest),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // Группируем метрики по секциям
  List<Widget> _buildSections(MeasurementRecord? latest) {
    final sections = <String>['ОСНОВНОЕ', 'ДЕТАЛИ', 'СОСТОЯНИЕ', 'СЕГМЕНТЫ'];
    final result = <Widget>[];

    for (final section in sections) {
      final sectionMetrics = _metrics.where((m) => m['section'] == section).toList();
      // Пропускаем вес — он уже в большой карточке
      final filtered = section == 'ОСНОВНОЕ'
          ? sectionMetrics.where((m) => m['key'] != 'weight').toList()
          : sectionMetrics;

      result.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Text(section,
            style: const TextStyle(
                color: Colors.white38, fontSize: 11,
                fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ));

      result.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final m = filtered[index];
            return _buildMetricCard(m);
          },
        ),
      ));

      result.add(const SizedBox(height: 20));
    }

    return result;
  }

  Widget _buildMetricCard(Map<String, dynamic> m) {
    final key = m['key'] as String;
    final color = m['color'] as Color;
    final unit = m['unit'] as String;
    final values = AppState.instance.valuesFor(key);
    final change = AppState.instance.changePercent(key);

    final double val = AppState.instance.latestFor(key);

    return GestureDetector(
      onTap: () => _openHistory(key, m['label'] as String, unit, color),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2340),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Иконка + название
            Row(
              children: [
                Icon(m['icon'] as IconData, color: color, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(m['label'] as String,
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Значение
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: val > 0 ? val.toStringAsFixed(1) : '--',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: unit.isNotEmpty ? ' $unit' : '',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ]),
            ),
            if (change.isNotEmpty)
              Text(change,
                  style: TextStyle(
                      color: change.startsWith('↓') ? Colors.green : Colors.redAccent,
                      fontSize: 10)),
            const Spacer(),
            // Мини-график
            if (values.length >= 2)
              SizedBox(height: 32, child: _miniChart(values, color))
            else
              SizedBox(height: 32,
                  child: const Center(child: Text('Нет данных',
                      style: TextStyle(color: Colors.white12, fontSize: 9)))),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard(MeasurementRecord? latest) {
    final values = AppState.instance.valuesFor('weight');
    final change = AppState.instance.changePercent('weight');
    final weight = latest?.weight ?? 0;

    return GestureDetector(
      onTap: () => _openHistory('weight', 'Вес', 'кг', const Color(0xFF4C6EF5)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2340),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Вес',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Row(children: [
                  Text(latest != null ? _fmtTime(latest.date) : '--:--',
                      style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                ]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: weight > 0 ? weight.toStringAsFixed(2) : '--',
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' кг',
                              style: TextStyle(color: Colors.white54, fontSize: 18)),
                        ]),
                      ),
                      if (change.isNotEmpty)
                        Text(change,
                            style: TextStyle(
                                color: change.startsWith('↓') ? Colors.green : Colors.redAccent,
                                fontSize: 13)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120, height: 60,
                  child: values.length >= 2
                      ? _miniChart(values, const Color(0xFF4C6EF5))
                      : const Center(child: Text('Нет данных',
                      style: TextStyle(color: Colors.white24, fontSize: 10))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Цель', style: TextStyle(color: Colors.white54, fontSize: 13)),
                const Row(children: [
                  Text('-- кг', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.edit_outlined, color: Colors.white38, size: 16),
                ]),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            _navRow(Icons.list_alt_outlined, 'Все записи', () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const AllRecordsPage(),
              ));
            }),
            _navRow(Icons.bar_chart, 'Результат измерения', () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const MeasurementResultPage(),
              ));
            }),
            _navRow(Icons.show_chart, 'Детали измерений', () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const MeasurementDetailsPage(),
              ));
            }),
            ],
        ),
      ),
    );
  }

  Widget _navRow(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500))),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
        ]),
      ),
    );
  }

  Widget _miniChart(List<double> values, Color color) {
    if (values.length < 2) return const SizedBox();
    final spots = values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.05;

    return LineChart(LineChartData(
      minY: minY, maxY: maxY,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots, isCurved: true, color: color, barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
            ),
          ),
        ),
      ],
    ));
  }

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
