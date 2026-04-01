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
    this.metricUnit = 'kg',
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

  final List<Map<String, dynamic>> _metrics = [
    {'key': 'weight', 'label': 'Вес', 'unit': 'kg', 'color': const Color(0xFF4C6EF5)},
    {'key': 'bodyFat', 'label': 'Телесный жир', 'unit': '%', 'color': const Color(0xFFFF6B6B)},
    {'key': 'muscle', 'label': 'Мышцы', 'unit': '%', 'color': const Color(0xFF51CF66)},
    {'key': 'water', 'label': 'Вода', 'unit': '%', 'color': const Color(0xFF339AF0)},
    {'key': 'bmi', 'label': 'ИМТ', 'unit': '', 'color': const Color(0xFFCC5DE8)},
    {'key': 'bmr', 'label': 'БМР', 'unit': 'ккал', 'color': const Color(0xFFFF922B)},
    {'key': 'bodyHealth', 'label': 'Оценка здоровья', 'unit': '', 'color': const Color(0xFFFF6B6B)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedMetricKey = widget.metricKey;
    _selectedMetricLabel = widget.metricLabel;
    _selectedMetricUnit = widget.metricUnit;
    _selectedMetricColor = widget.metricColor;
  }

  List<MeasurementRecord> get _filteredRecords =>
      AppState.instance.recordsFor(_selectedDays);

  List<FlSpot> get _spots {
    final records = _filteredRecords;
    if (records.isEmpty) return [];
    return records.asMap().entries.map((e) {
      double val = 0;
      switch (_selectedMetricKey) {
        case 'weight': val = e.value.weight; break;
        case 'bodyFat': val = e.value.bodyFat; break;
        case 'muscle': val = e.value.muscle; break;
        case 'water': val = e.value.water; break;
        case 'bmi': val = e.value.bmi; break;
        case 'bmr': val = e.value.bmr; break;
        case 'bodyHealth': val = e.value.bodyHealth; break;
      }
      return FlSpot(e.key.toDouble(), val);
    }).toList();
  }

  double get _minY {
    if (_spots.isEmpty) return 0;
    return (_spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.95);
  }

  double get _maxY {
    if (_spots.isEmpty) return 100;
    return (_spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.05);
  }

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
      default:
        return 'Норма';
    }
  }

  Color _statusColor(String key, double val) {
    final s = _statusFor(key, val);
    if (s == 'Норма' || s == 'Высокий') return Colors.green;
    if (s == 'Слегка повышенный') return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;
    final spots = _spots;
    final latest = AppState.instance.latest;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        title: const Text('Графики данных',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Карточка с графиком
                  Container(
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
                              _periodBtn('Стат.', 90),
                              _periodBtn('День', 1),
                              _periodBtn('7 дней', 7),
                              _periodBtn('30 дней', 30),
                              _periodBtn('90 дней', 90),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Выбор показателя
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

                        const SizedBox(height: 4),

                        // Дата диапазон
                        if (records.isNotEmpty)
                          Text(
                            '${_fmt(records.first.date)} ~ ${_fmt(records.last.date)}',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12),
                          ),

                        const SizedBox(height: 12),

                        // Мин/Макс
                        if (spots.isNotEmpty) ...[
                          Row(
                            children: [
                              _statBox(
                                  'Высокий: $_selectedMetricLabel',
                                  '${_maxY.toStringAsFixed(1)} $_selectedMetricUnit'),
                              const SizedBox(width: 24),
                              _statBox(
                                  'Низкий: $_selectedMetricLabel',
                                  '${_minY.toStringAsFixed(1)} $_selectedMetricUnit'),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // График
                        SizedBox(
                          height: 200,
                          child: spots.isEmpty
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bar_chart,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.15)),
                                const SizedBox(height: 8),
                                const Text('Нет данных',
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 14)),
                              ],
                            ),
                          )
                              : LineChart(
                            LineChartData(
                              minY: _minY,
                              maxY: _maxY,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: Colors.white.withOpacity(0.05),
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (val, _) => Text(
                                      val.toStringAsFixed(0),
                                      style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, _) {
                                      final idx = val.toInt();
                                      if (idx < 0 || idx >= records.length) {
                                        return const SizedBox();
                                      }
                                      final d = records[idx].date;
                                      return Text(
                                        '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 9),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                    sideTitles:
                                    SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles:
                                    SideTitles(showTitles: false)),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: _selectedMetricColor,
                                  barWidth: 2.5,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (_, __, ___, ____) =>
                                        FlDotCirclePainter(
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
                                        _selectedMetricColor
                                            .withOpacity(0.3),
                                        _selectedMetricColor
                                            .withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Карточки других показателей
                  if (latest != null)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: _metrics.map((m) {
                        double val = 0;
                        switch (m['key']) {
                          case 'weight': val = latest.weight; break;
                          case 'bodyFat': val = latest.bodyFat; break;
                          case 'muscle': val = latest.muscle; break;
                          case 'water': val = latest.water; break;
                          case 'bmi': val = latest.bmi; break;
                          case 'bmr': val = latest.bmr; break;
                          case 'bodyHealth': val = latest.bodyHealth; break;
                        }
                        final color = m['color'] as Color;
                        final key = m['key'] as String;
                        final status = _statusFor(key, val);
                        final statusColor = _statusColor(key, val);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMetricKey = key;
                              _selectedMetricLabel = m['label'] as String;
                              _selectedMetricUnit = m['unit'] as String;
                              _selectedMetricColor = color;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2340),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedMetricKey == key
                                    ? color
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
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          m['label'].toString().substring(0, 1),
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
                                              fontSize: 12),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  val > 0
                                      ? '${val.toStringAsFixed(1)} ${m['unit']}'
                                      : '--',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(status,
                                    style: TextStyle(
                                        color: statusColor, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
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
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: selected ? Colors.white : Colors.white38,
                fontSize: 12,
                fontWeight:
                selected ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._metrics.map((m) {
            final isSelected = m['key'] == _selectedMetricKey;
            return ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (m['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.show_chart,
                    color: m['color'] as Color, size: 18),
              ),
              title: Text(m['label'] as String,
                  style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF4C6EF5)
                          : Colors.white)),
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

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}