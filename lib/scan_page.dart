import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'diet_page.dart';
import 'health_tools_page.dart';
import 'members_page.dart';
import 'device_management_page.dart';
import 'history_page.dart';
import 'ble_scan_page.dart';
import 'app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_manager.dart';
import 'app_state.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.title});
  final String title;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _userName = '';
  String? _activeBodyPart;
  Offset? _tooltipOffset;

  final Map<String, Map<String, String>> _bodyPartData = {
    'Голова': {'Гидратация': '--', 'Состояние': '--'},
    'Грудь': {'Мышцы': '--', 'Жир': '--'},
    'Живот': {'Висцеральный жир': '--', 'Обмен веществ': '--'},
    'Правая рука': {'Мышцы': '--', 'Жир': '--'},
    'Левая рука': {'Мышцы': '--', 'Жир': '--'},
    'Правая нога': {'Мышцы': '--', 'Жир': '--'},
    'Левая нога': {'Мышцы': '--', 'Жир': '--'},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserName();
    AppState.instance.load();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Пользователь';
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onBodyPartTap(String part, Offset offset) {
    setState(() {
      if (_activeBodyPart == part) {
        _activeBodyPart = null;
        _tooltipOffset = null;
      } else {
        _activeBodyPart = part;
        _tooltipOffset = offset;
      }
    });
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
                      shape: BoxShape.circle,
                      color: const Color(0xFF2A3A6B),
                      border: Border.all(
                          color: isActive ? const Color(0xFF4C6EF5) : Colors.white24, width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.white54, size: 22),
                  ),
                  title: Text(p.name, style: TextStyle(
                    color: isActive ? const Color(0xFF4C6EF5) : Colors.white,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  )),
                  subtitle: Text('${p.type} · ${p.age} лет',
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: isActive
                      ? const Icon(Icons.check, color: Color(0xFF4C6EF5))
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (!isActive) {
                      await ProfileManager.instance.switchProfile(p.id);
                      await AppState.instance.onProfileSwitch();
                      setState(() {});
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

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2340),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(icon: Icons.bluetooth_searching, label: 'Добавить устройство',
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BleScanPage()));
            },
          ),
          _buildMenuItem(icon: Icons.qr_code_scanner, label: 'Отсканировать QR',
            onTap: () => Navigator.pop(ctx),
          ),
          _buildMenuItem(icon: Icons.devices, label: 'Управление устройством',
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceManagementPage()));
            },
          ),
          _buildMenuItem(icon: Icons.group_outlined, label: 'Управление участниками',
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersPage()));
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF4C6EF5).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF4C6EF5), size: 20),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
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
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A2340),
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
              GestureDetector(
                onTap: _showMenu,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2340),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dashboard_outlined, color: Colors.white54, size: 22),
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
        return GestureDetector(
          onTap: () => setState(() { _activeBodyPart = null; _tooltipOffset = null; }),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Большая карточка Веса
                _buildWeightCard(latest),
                const SizedBox(height: 12),

                // Человечек
                _buildBodyFigure(),
                const SizedBox(height: 16),

                // Маленькие карточки с мини-графиком
                _buildMetricCards(latest),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightCard(MeasurementRecord? latest) {
    final values = AppState.instance.valuesFor('weight');
    final change = AppState.instance.changePercent('weight');
    final weight = latest?.weight ?? 0;

    return GestureDetector(
      onTap: () => _openHistory('weight', 'Вес', 'kg', const Color(0xFF4C6EF5)),
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
                const Text('Вес', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(
                      latest != null ? _fmtTime(latest.date) : '--:--',
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                  ],
                ),
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
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: weight > 0 ? weight.toStringAsFixed(2) : '--',
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: ' kg',
                              style: TextStyle(color: Colors.white54, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      if (change.isNotEmpty)
                        Text(change,
                          style: TextStyle(
                            color: change.startsWith('↓') ? Colors.green : Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                // Мини-график
                SizedBox(
                  width: 120, height: 60,
                  child: values.length >= 2
                      ? _miniChart(values, const Color(0xFF4C6EF5))
                      : Center(child: Text('Нет данных', style: TextStyle(color: Colors.white24, fontSize: 10))),
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
                Row(
                  children: [
                    const Text('-- kg', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined, color: Colors.white38, size: 16),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white10),

            // Навигационные пункты
            _buildNavRow(Icons.list_alt_outlined, 'Все записи'),
            _buildNavRow(Icons.bar_chart, 'Результат измерения'),
            _buildNavRow(Icons.show_chart, 'Детали измерений'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavRow(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _openHistory('weight', 'Вес', 'kg', const Color(0xFF4C6EF5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCards(MeasurementRecord? latest) {
    final metrics = [
      {'key': 'bodyFat', 'label': 'Телесный жир', 'unit': '%', 'color': const Color(0xFFFF6B6B), 'value': latest?.bodyFat ?? 0.0},
      {'key': 'bmi', 'label': 'ИМТ', 'unit': '', 'color': const Color(0xFFCC5DE8), 'value': latest?.bmi ?? 0.0},
      {'key': 'muscle', 'label': 'Мышцы', 'unit': '%', 'color': const Color(0xFF51CF66), 'value': latest?.muscle ?? 0.0},
      {'key': 'water', 'label': 'Вода', 'unit': '%', 'color': const Color(0xFF339AF0), 'value': latest?.water ?? 0.0},
      {'key': 'bmr', 'label': 'Обмен веществ', 'unit': 'ккал', 'color': const Color(0xFFFF922B), 'value': latest?.bmr ?? 0.0},
      {'key': 'boneMass', 'label': 'Кости', 'unit': 'кг', 'color': const Color(0xFFFFD43B), 'value': latest?.boneMass ?? 0.0},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final m = metrics[index];
          final key = m['key'] as String;
          final color = m['color'] as Color;
          final val = m['value'] as double;
          final values = AppState.instance.valuesFor(key);
          final change = AppState.instance.changePercent(key);

          return GestureDetector(
            onTap: () => _openHistory(key, m['label'] as String, m['unit'] as String, color),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2340),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: val > 0 ? val.toStringAsFixed(1) : '--',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${m['unit']}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (change.isNotEmpty)
                    Text(change,
                      style: TextStyle(
                        color: change.startsWith('↓') ? Colors.green : Colors.redAccent,
                        fontSize: 11,
                      ),
                    ),
                  const Spacer(),
                  // Мини-график
                  if (values.length >= 2)
                    SizedBox(height: 40, child: _miniChart(values, color)),
                  const SizedBox(height: 4),
                  Text(m['label'] as String,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _miniChart(List<double> values, Color color) {
    if (values.length < 2) return const SizedBox();
    final spots = values.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.05;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
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
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyFigure() {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160, height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(80),
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4C6EF5).withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          CustomPaint(
            size: const Size(140, 260),
            painter: _BodyPainter(activePart: _activeBodyPart),
          ),
          ..._buildBodyTapZones(),
          if (_activeBodyPart != null && _tooltipOffset != null)
            Positioned(
              left: _tooltipOffset!.dx,
              top: _tooltipOffset!.dy,
              child: _buildTooltip(_activeBodyPart!),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildBodyTapZones() {
    return [
      _bodyZone('Голова', left: 55, top: 8, width: 34, height: 34, tooltipDx: 100, tooltipDy: 10),
      _bodyZone('Грудь', left: 45, top: 52, width: 54, height: 50, tooltipDx: 100, tooltipDy: 55),
      _bodyZone('Живот', left: 48, top: 102, width: 48, height: 40, tooltipDx: 100, tooltipDy: 105),
      _bodyZone('Правая рука', left: 18, top: 55, width: 26, height: 80, tooltipDx: -90, tooltipDy: 60),
      _bodyZone('Левая рука', left: 100, top: 55, width: 26, height: 80, tooltipDx: 20, tooltipDy: 60),
      _bodyZone('Правая нога', left: 42, top: 158, width: 28, height: 100, tooltipDx: -80, tooltipDy: 160),
      _bodyZone('Левая нога', left: 74, top: 158, width: 28, height: 100, tooltipDx: 20, tooltipDy: 160),
    ];
  }

  Widget _bodyZone(String part, {required double left, required double top,
    required double width, required double height, required double tooltipDx, required double tooltipDy}) {
    return Positioned(
      left: left, top: top,
      child: GestureDetector(
        onTapUp: (_) => _onBodyPartTap(part, Offset(tooltipDx, tooltipDy)),
        child: Container(width: width, height: height, color: Colors.transparent),
      ),
    );
  }

  Widget _buildTooltip(String part) {
    final data = _bodyPartData[part] ?? {};
    return Container(
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(maxWidth: 130),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2340),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C6EF5), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFF4C6EF5).withOpacity(0.3), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(part, style: const TextStyle(color: Color(0xFF4C6EF5), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...data.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(width: 8),
                Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _BodyPainter extends CustomPainter {
  final String? activePart;
  _BodyPainter({this.activePart});

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..style = PaintingStyle.fill..color = const Color(0xFF2A3A6B);
    final active = Paint()..style = PaintingStyle.fill..color = const Color(0xFF4C6EF5).withOpacity(0.5);
    final stroke = Paint()..style = PaintingStyle.stroke..color = const Color(0xFF4C6EF5)..strokeWidth = 1.5;
    final cx = size.width / 2;

    p(Paint b, Paint s, void Function() path) {}

    // Голова
    final head = Rect.fromCenter(center: Offset(cx, 22), width: 34, height: 34);
    canvas.drawOval(head, activePart == 'Голова' ? active : body);
    canvas.drawOval(head, stroke);

    canvas.drawRect(Rect.fromCenter(center: Offset(cx, 43), width: 12, height: 10), body);

    final chest = Path()..moveTo(cx-28,50)..lineTo(cx+28,50)..lineTo(cx+22,100)..lineTo(cx-22,100)..close();
    canvas.drawPath(chest, activePart == 'Грудь' ? active : body);
    canvas.drawPath(chest, stroke);

    final belly = Path()..moveTo(cx-22,100)..lineTo(cx+22,100)..lineTo(cx+18,148)..lineTo(cx-18,148)..close();
    canvas.drawPath(belly, activePart == 'Живот' ? active : body);
    canvas.drawPath(belly, stroke);

    final ra = Path()..moveTo(cx-28,52)..lineTo(cx-40,58)..lineTo(cx-38,130)..lineTo(cx-26,128)..close();
    canvas.drawPath(ra, activePart == 'Правая рука' ? active : body);
    canvas.drawPath(ra, stroke);

    final la = Path()..moveTo(cx+28,52)..lineTo(cx+40,58)..lineTo(cx+38,130)..lineTo(cx+26,128)..close();
    canvas.drawPath(la, activePart == 'Левая рука' ? active : body);
    canvas.drawPath(la, stroke);

    final rl = Path()..moveTo(cx-18,148)..lineTo(cx-4,148)..lineTo(cx-6,255)..lineTo(cx-22,255)..close();
    canvas.drawPath(rl, activePart == 'Правая нога' ? active : body);
    canvas.drawPath(rl, stroke);

    final ll = Path()..moveTo(cx+4,148)..lineTo(cx+18,148)..lineTo(cx+22,255)..lineTo(cx+6,255)..close();
    canvas.drawPath(ll, activePart == 'Левая нога' ? active : body);
    canvas.drawPath(ll, stroke);
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.activePart != activePart;
}