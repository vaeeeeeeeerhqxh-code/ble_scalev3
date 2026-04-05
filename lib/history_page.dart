import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_state.dart';

class HistoryPage extends StatefulWidget {
  final String metricKey;
  final String metricLabel;
  final String metricUnit;
  final Color metricColor;

  const HistoryPage({
    super.key,
    this.metricKey = 'weight',
    this.metricLabel = 'Вес',
    this.metricUnit = 'кг',
    this.metricColor = const Color(0xFF4C6EF5),
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedDays = 7;
  String _selectedMetricKey = '';
  String _selectedMetricLabel = '';
  String _selectedMetricUnit = '';
  Color _selectedMetricColor = const Color(0xFF4C6EF5);

  final List<Map<String, dynamic>> _allMetrics = [
    {'key': 'weight',      'label': 'Вес',              'unit': 'кг',   'color': const Color(0xFF4C6EF5)},
    {'key': 'bodyFat',     'label': 'Телесный жир',     'unit': '%',    'color': const Color(0xFFFF6B6B)},
    {'key': 'muscle',      'label': 'Мышцы',            'unit': '%',    'color': const Color(0xFF51CF66)},
    {'key': 'water',       'label': 'Вода',             'unit': '%',    'color': const Color(0xFF339AF0)},
    {'key': 'bmi',         'label': 'ИМТ',              'unit': '',     'color': const Color(0xFFCC5DE8)},
    {'key': 'bmr',         'label': 'БМР',              'unit': 'ккал', 'color': const Color(0xFFFF922B)},
    {'key': 'bodyHealth',  'label': 'Оценка здоровья',  'unit': '',     'color': const Color(0xFFEC407A)},
    {'key': 'boneMass',    'label': 'Кости',            'unit': 'кг',   'color': const Color(0xFF90A4AE)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedMetricKey = widget.metricKey;
    _selectedMetricLabel = widget.metricLabel;
    _selectedMetricUnit = widget.metricUnit;
    _selectedMetricColor = widget.metricColor;
  }

  List<MeasurementRecord> get _records =>
      AppState.instance.recordsFor(_selectedDays);

  double _getVal(MeasurementRecord r, String key) {
    switch (key) {
      case 'weight':      return r.weight;
      case 'bodyFat':     return r.bodyFat;
      case 'muscle':      return r.muscle;
      case 'water':       return r.water;
      case 'bmi':         return r.bmi;
      case 'bmr':         return r.bmr;
      case 'boneMass':    return r.boneMass;
      case 'visceralFat': return r.visceralFat;
      case 'protein':     return r.protein;
      case 'bodyAge':     return r.bodyAge;
      case 'bodyHealth':  return r.bodyHealth;
      case 'm_la':        return r.mLa;
      case 'm_ra':        return r.mRa;
      case 'm_ll':        return r.mLl;
      case 'm_rl':        return r.mRl;
      case 'm_tr':        return r.mTr;
      default:            return 0;
    }
  }

  List<double> get _values =>
      _records.map((r) => _getVal(r, _selectedMetricKey)).toList();

  double get _minVal => _values.isEmpty ? 0 : _values.reduce((a, b) => a < b ? a : b);
  double get _maxVal => _values.isEmpty ? 0 : _values.reduce((a, b) => a > b ? a : b);

  String _fmt(double v, {int d = 1}) => v == 0 ? '--' : v.toStringAsFixed(d);
  String _fmtDate(DateTime d) =>
      '${d.month}-${d.day.toString().padLeft(2, '0')}';
  String _fmtDateFull(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _statusFor(String key, double val) {
    switch (key) {
      case 'bmi':
        if (val < 18.5) return 'Недовес';
        if (val < 25) return 'Норма';
        if (val < 30) return 'Избыток';
        return 'Ожирение';
      case 'bodyFat':
        if (val < 15) return 'Низкий';
        if (val < 25) return 'Норма';
        return 'Высокий';
      case 'bodyHealth':
        if (val >= 80) return 'Высокий';
        if (val >= 60) return 'Норма';
        return 'Низкий';
      case 'bmr':
        if (val > 1600) return 'Высокий';
        if (val > 1200) return 'Норма';
        return 'Низкий';
      default: return 'Норма';
    }
  }

  Color _statusColor(String key, double val) {
    final s = _statusFor(key, val);
    if (s == 'Норма' || s == 'Высокий') return Colors.green;
    if (s == 'Избыток') return Colors.orange;
    return Colors.redAccent;
  }

  void _showMetricPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2340),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text('Выберите показатель',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._allMetrics.map((m) {
            final isSelected = m['key'] == _selectedMetricKey;
            return ListTile(
              leading: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: (m['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.show_chart, color: m['color'] as Color, size: 18),
              ),
              title: Text(m['label'] as String,
                  style: TextStyle(
                      color: isSelected ? const Color(0xFF4C6EF5) : Colors.white)),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Color(0xFF4C6EF5))
                  : null,
              onTap: () {
                setState(() {
                  _selectedMetricKey = m['key'] as String;
                  _selectedMetricLabel = m['label'] as String;
                  _selectedMetricUnit = m['unit'] as String;
                  _selectedMetricColor = m['color'] as Color;
                });
                Navigator.pop(ctx);
              },
            );
          }),
          const SizedBox(height: 16),
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
          child: ListenableBuilder(
            listenable: AppState.instance,
            builder: (context, _) {
              final records = _records;
              final values = _values;
              final hasData = values.isNotEmpty && values.any((v) => v > 0);
              final latest = records.isNotEmpty ? records.last : null;

              return CustomScrollView(
                slivers: [
                  // Заголовок
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text('Графики данных',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: const SizedBox(height: 16)),

                  // Основная карточка с графиком
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2340),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Переключатель периода
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _periodBtn('Все', 90),
                                  _periodBtn('День', 1),
                                  _periodBtn('7 дней', 7),
                                  _periodBtn('30 дней', 30),
                                  _periodBtn('90 дней', 90),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Название показателя с дропдауном
                            GestureDetector(
                              onTap: _showMetricPicker,
                              child: Row(
                                children: [
                                  Text(_selectedMetricLabel,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Colors.white54),
                                ],
                              ),
                            ),

                            // Диапазон дат
                            if (records.length >= 2) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${_fmtDateFull(records.first.date)} ~ ${_fmtDateFull(records.last.date)}',
                                style: const TextStyle(
                                    color: Color(0xFF4C6EF5), fontSize: 12),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Высокий / Низкий
                            if (hasData)
                              Row(
                                children: [
                                  _highLowBox(
                                    '${_fmt(_maxVal)} ${_selectedMetricUnit}',
                                    'Высокий: $_selectedMetricLabel',
                                  ),
                                  const SizedBox(width: 32),
                                  _highLowBox(
                                    '${_fmt(_minVal)} ${_selectedMetricUnit}',
                                    'Низкий: $_selectedMetricLabel',
                                  ),
                                ],
                              ),

                            const SizedBox(height: 16),

                            // График
                            SizedBox(
                              height: 180,
                              child: hasData
                                  ? _buildChart(records, values)
                                  : _buildEmptyChart(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: const SizedBox(height: 20)),

                  // Карточки других показателей (как в референсе)
                  if (AppState.instance.latest != null)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.6,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final m = _allMetrics[index];
                            final key = m['key'] as String;
                            final color = m['color'] as Color;
                            final val = _getVal(AppState.instance.latest!, key);
                            final status = _statusFor(key, val);
                            final statusColor = _statusColor(key, val);
                            final isSelected = key == _selectedMetricKey;

                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedMetricKey = key;
                                _selectedMetricLabel = m['label'] as String;
                                _selectedMetricUnit = m['unit'] as String;
                                _selectedMetricColor = color;
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A2340),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? color.withOpacity(0.6)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 28, height: 28,
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              (m['label'] as String)[0],
                                              style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(m['label'] as String,
                                              style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 11),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: val > 0
                                              ? val.toStringAsFixed(1)
                                              : '--',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if ((m['unit'] as String).isNotEmpty)
                                          TextSpan(
                                            text: ' ${m['unit']}',
                                            style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 11),
                                          ),
                                      ]),
                                    ),
                                    Text(status,
                                        style: TextStyle(
                                            color: statusColor, fontSize: 11)),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: _allMetrics.length,
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(child: const SizedBox(height: 20)),

                  // Список всех записей
                  if (records.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Row(
                          children: [
                            const Text('Все записи',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text('${records.length} шт.',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final r = records.reversed.toList()[index];
                          final val = _getVal(r, _selectedMetricKey);
                          final isFirst = index == 0;

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A2340),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isFirst
                                      ? _selectedMetricColor.withOpacity(0.4)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_fmtDate(r.date)} ${_fmtTime(r.date)}',
                                        style: const TextStyle(
                                            color: Colors.white54, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_fmt(val)} $_selectedMetricUnit',
                                    style: TextStyle(
                                        color: isFirst
                                            ? _selectedMetricColor
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: records.length,
                      ),
                    ),
                  ] else
                    SliverToBoxAdapter(child: _buildEmptyState()),

                  SliverToBoxAdapter(child: const SizedBox(height: 32)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _periodBtn(String label, int days) {
    final selected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDays = days),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF4C6EF5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.white38,
                  fontSize: 11,
                  fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }

  Widget _highLowBox(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildChart(List<MeasurementRecord> records, List<double> values) {
    final spots = values.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final pad = (_maxVal - _minVal) * 0.1;
    final double minY = (_minVal - pad)
        .clamp(0, double.infinity)
        .toDouble();

    final double maxY = (_maxVal + pad).toDouble();

    return LineChart(
      LineChartData(
        minY: minY, maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withOpacity(0.05), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (val, _) => Text(
                val.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white24, fontSize: 9),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                final idx = val.toInt();
                if (idx != 0 && idx != records.length - 1) return const SizedBox();
                if (idx < 0 || idx >= records.length) return const SizedBox();
                return Text(_fmtDate(records[idx].date),
                    style: const TextStyle(color: Colors.white38, fontSize: 9));
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0D1B3E),
            getTooltipItems: (spots) => spots.map((s) {
              final idx = s.spotIndex;
              final r = records[idx];
              return LineTooltipItem(
                '${_fmt(s.y)} $_selectedMetricUnit\n${_fmtDate(r.date)} ${_fmtTime(r.date)}',
                TextStyle(
                    color: _selectedMetricColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: _selectedMetricColor,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3,
                color: _selectedMetricColor,
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _selectedMetricColor.withOpacity(0.25),
                  _selectedMetricColor.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 40, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 8),
          const Text('Нет данных',
              style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF4C6EF5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bar_chart,
                  size: 32,
                  color: const Color(0xFF4C6EF5).withOpacity(0.4)),
            ),
            const SizedBox(height: 16),
            const Text('Нет записей',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Подключите весы и проведите\nпервое измерение',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}