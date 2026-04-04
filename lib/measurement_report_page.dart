import 'package:flutter/material.dart';
import 'app_state.dart';

class MeasurementReportPage extends StatelessWidget {
  final MeasurementRecord record;
  const MeasurementReportPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        title: const Text('Отчет об измерении', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2F6B), Color(0xFF0D1B3E)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Круг с оценкой
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4C6EF5).withOpacity(0.3), width: 10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${record.bodyHealth.toInt()}',
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      const Text('баллов', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _reportRow(Icons.monitor_weight_outlined, 'Вес', '${record.weight.toStringAsFixed(2)} кг'),
              _reportRow(Icons.accessibility_new, 'ИМТ (BMI)', record.bmi.toStringAsFixed(1)),
              _reportRow(Icons.opacity, 'Жир', '${record.bodyFat.toStringAsFixed(1)}%'),
              _reportRow(Icons.fitness_center, 'Мышцы', '${record.muscle.toStringAsFixed(1)}%'),
              _reportRow(Icons.water_drop_outlined, 'Вода', '${record.water.toStringAsFixed(1)}%'),
              
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ваше состояние оценивается как нормальное. Рекомендуется поддерживать текущий уровень активности и сбалансированное питание.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4C6EF5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4C6EF5), size: 24),
          ),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
