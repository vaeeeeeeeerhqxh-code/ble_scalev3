import 'package:flutter/material.dart';

class AnalysisGrid extends StatelessWidget {
  final Map<String, dynamic>? data;

  const AnalysisGrid({super.key, this.data});

  String _v(String key, {int d = 1, String unit = ""}) {
    if (data == null || !data!.containsKey(key)) return "--";

    final val = data![key];
    if (val == null) return "--";

    if (val is double) {
      return "${val.toStringAsFixed(d)}$unit";
    }
    return "$val$unit";
  }

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return const Center(child: Text("Нет данных"));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        /// 🔥 ОСНОВА
        _section("ОСНОВА", [
          _card("BMI", _v("bmi"), Icons.monitor_weight),
          _card("Жир", _v("bodyFat", unit: "%"), Icons.opacity),
          _card("Вода", _v("water", unit: "%"), Icons.water),
          _card("Вес", _v("weight", unit: " кг"), Icons.fitness_center),
        ]),

        /// 🔥 ТЕЛО (как в Unique Health)
        _section("ТЕЛО", [
          _card("Мышцы (Body)", _v("bodyMusclePercent", unit: "%"), Icons.sports_gymnastics),
          _card("Скелетные мышцы", _v("skeletalMusclePercent", unit: "%"), Icons.accessibility),
          _card("Белок", _v("protein", unit: "%"), Icons.egg),
          _card("Кости", _v("boneMass", unit: " кг"), Icons.health_and_safety),
        ]),

        /// 🔥 ЖИР
        _section("ЖИР", [
          _card("Подкожный", _v("subcutaneousFat", unit: "%"), Icons.circle),
          _card("Висцеральный", _v("visceralFat"), Icons.warning),
        ]),

        /// 🔥 СЕГМЕНТЫ
        _section("СЕГМЕНТЫ", [
          _segment("Левая рука", _v("m_la"), _v("f_la")),
          _segment("Правая рука", _v("m_ra"), _v("f_ra")),
          _segment("Левая нога", _v("m_ll"), _v("f_ll")),
          _segment("Правая нога", _v("m_rl"), _v("f_rl")),
          _segment("Туловище", _v("m_tr"), _v("f_tr")),
        ]),

        /// 🔥 СОСТОЯНИЕ
        _section("СОСТОЯНИЕ", [
          _card("Возраст тела", _v("bodyAge", d: 0), Icons.timer),
          _card("Здоровье", _v("bodyHealth", d: 0), Icons.favorite),
          _card("BMR", _v("bmr", d: 0, unit: " kcal"), Icons.local_fire_department),
        ]),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: children,
        ),
      ],
    );
  }

  Widget _card(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 10)),
              )
            ],
          ),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _segment(String name, String muscle, String fat) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          _row("Мышцы", muscle, Colors.green),
          _row("Жир", fat, Colors.orange),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
