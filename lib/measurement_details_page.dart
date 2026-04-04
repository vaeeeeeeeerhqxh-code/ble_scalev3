import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_state.dart';

class MeasurementDetailsPage extends StatefulWidget {
  const MeasurementDetailsPage({super.key});

  @override
  State<MeasurementDetailsPage> createState() => _MeasurementDetailsPageState();
}

class _MeasurementDetailsPageState extends State<MeasurementDetailsPage> {
  String _selectedKey = 'weight';

  final List<Map<String, dynamic>> _options = [
    {'key': 'weight',      'label': 'Вес',            'unit': 'кг', 'color': const Color(0xFF4C6EF5)},
    {'key': 'bmi',         'label': 'ИМТ',            'unit': '',   'color': const Color(0xFFCC5DE8)},
    {'key': 'bodyFat',     'label': 'Жир',            'unit': '%',  'color': const Color(0xFFFF6B6B)},
    {'key': 'muscle',      'label': 'Мышцы',          'unit': '%',  'color': const Color(0xFF51CF66)},
    {'key': 'water',       'label': 'Вода',           'unit': '%',  'color': const Color(0xFF339AF0)},
    {'key': 'visceralFat', 'label': 'Висц. жир',      'unit': '',   'color': const Color(0xFFFF922B)},
    {'key': 'protein',     'label': 'Белок',          'unit': '%',  'color': const Color(0xFFFFD43B)},
    {'key': 'bmr',         'label': 'BMR',            'unit': 'ккал','color': const Color(0xFFFFD43B)},
    {'key': 'boneMass',    'label': 'Кости',          'unit': 'кг', 'color': const Color(0xFF90A4AE)},
  ];

  @override
  Widget build(BuildContext context) {
    final selected = _options.firstWhere((o) => o['key'] == _selectedKey);
    final color = selected['color'] as Color;
    final unit = selected['unit'] as String;
    final label = selected['label'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2340),
        title: const Text('Детали измерений',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
            final values = AppState.instance.valuesFor(_selectedKey);
            final latestVal = AppState.instance.latestFor(_selectedKey);

            return Column(
              children: [
                // Горизонтальный скролл фильтров
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _options.length,
                    itemBuilder: (context, i) {
                      final opt = _options[i];
                      final isSelected = opt['key'] == _selectedKey;
                      final c = opt['color'] as Color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedKey = opt['key'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? c : const Color(0xFF1A2340),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected ? c : Colors.white12, width: 1.5),
                          ),
                          child: Text(
                            opt['label'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Текущее значение
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2340),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label,
                                style: const TextStyle(color: Colors.white54, fontSize: 13)),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: latestVal > 0 ? latestVal.toStringAsFixed(1) : '--',
                                  style: TextStyle(
                                      color: color, fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: unit.isNotEmpty ? ' $unit' : '',
                                  style: const TextStyle(color: Colors.white38, fontSize: 16),
                                ),
                              ]),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${values.length} измерений',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // График
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2340),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: values.length >= 2
                        ? _buildChart(values, color)
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.show_chart, color: Colors.white12, size: 40),
                                SizedBox(height: 8),
                                Text('Недостаточно данных для графика',
                                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Статистика
                if (values.isNotEmpty) _buildStats(values, unit, color),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStats(List<double> values, String unit, Color color) {
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final avg = values.reduce((a, b) => a + b) / values.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2340),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('Мин.', '${min.toStringAsFixed(1)}${unit.isNotEmpty ? " $unit" : ""}', Colors.green),
            _statItem('Среднее', '${avg.toStringAsFixed(1)}${unit.isNotEmpty ? " $unit" : ""}', color),
            _statItem('Макс.', '${max.toStringAsFixed(1)}${unit.isNotEmpty ? " $unit" : ""}', Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildChart(List<double> values, Color color) {
    final spots = values.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.97;
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.03;

    return LineChart(LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.white10, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (val, _) => Text(
              val.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white24, fontSize: 9),
            ),
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
              radius: 3,
              color: color,
              strokeWidth: 1.5,
              strokeColor: Colors.white,
            ),
          ),
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
    ));
  }
}
