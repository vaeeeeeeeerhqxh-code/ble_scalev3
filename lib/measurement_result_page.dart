import 'package:flutter/material.dart';
import 'app_state.dart';

class MeasurementResultPage extends StatelessWidget {
  const MeasurementResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2340),
        title: const Text('Результат измерения',
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
            final r = AppState.instance.latest;
            if (r == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, color: Colors.white12, size: 64),
                    SizedBox(height: 16),
                    Text('Нет данных', style: TextStyle(color: Colors.white38, fontSize: 16)),
                  ],
                ),
              );
            }

            final metrics = [
              _Metric('Вес',         '${r.weight.toStringAsFixed(2)} кг', Icons.monitor_weight_outlined, const Color(0xFF4C6EF5)),
              _Metric('ИМТ (BMI)',   r.bmi.toStringAsFixed(1),            Icons.accessibility_new,       const Color(0xFFCC5DE8)),
              _Metric('Жир',        '${r.bodyFat.toStringAsFixed(1)} %',  Icons.opacity,                 const Color(0xFFFF6B6B)),
              _Metric('Мышцы',      '${r.muscle.toStringAsFixed(1)} %',   Icons.fitness_center,          const Color(0xFF51CF66)),
              _Metric('Вода',       '${r.water.toStringAsFixed(1)} %',    Icons.water_drop_outlined,     const Color(0xFF339AF0)),
              _Metric('Висц. жир',  r.visceralFat.toStringAsFixed(1),     Icons.monitor_weight,          const Color(0xFFFF922B)),
              _Metric('Белок',      '${r.protein.toStringAsFixed(1)} %',  Icons.egg_outlined,            const Color(0xFFFFD43B)),
              _Metric('BMR',        '${r.bmr.toStringAsFixed(0)} ккал',   Icons.bolt,                    const Color(0xFFFFD43B)),
              _Metric('Кости',      '${r.boneMass.toStringAsFixed(2)} кг',Icons.brightness_high,         const Color(0xFF90A4AE)),
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Дата последнего измерения
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C6EF5).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4C6EF5).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Color(0xFF4C6EF5), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Последнее измерение: ${_fmtDateTime(r.date)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('ПОКАЗАТЕЛИ',
                      style: TextStyle(color: Colors.white38, fontSize: 11,
                          fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: metrics.length,
                    itemBuilder: (context, i) => _buildMetricTile(metrics[i]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricTile(_Metric m) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2340),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: m.color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(m.icon, color: m.color, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(m.label,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Text(m.value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _fmtDateTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Metric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _Metric(this.label, this.value, this.icon, this.color);
}
