import 'package:flutter/material.dart';
import 'meal_detail_page.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),

          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Питание',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Текущее потребление',
                              style: TextStyle(color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 4),
                          RichText(
                            text: const TextSpan(children: [
                              TextSpan(text: '--',
                                  style: TextStyle(color: Color(0xFF4C6EF5), fontSize: 18, fontWeight: FontWeight.bold)),
                              TextSpan(text: '/1500 kcal',
                                  style: TextStyle(color: Colors.white70, fontSize: 15)),
                            ]),
                          ),
                          const SizedBox(height: 8),
                          const Text('Осталось', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 4),
                          const Text('-- kcal',
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80, height: 80,
                      child: CircularProgressIndicator(
                        value: 0, strokeWidth: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF4C6EF5)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                _buildMealRow(context, Icons.wb_sunny_outlined, '+Завтрак', 'Завтрак'),
                const Divider(color: Colors.white10),
                _buildMealRow(context, Icons.lunch_dining_outlined, '+Обед', 'Обед'),
                const Divider(color: Colors.white10),
                _buildMealRow(context, Icons.dinner_dining_outlined, '+Ужин', 'Ужин'),
                const Divider(color: Colors.white10),
                _buildMealRow(context, Icons.cookie_outlined, '+Закуски', 'Закуски'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Калории',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientCircle('Белки', '--', 'г', const Color(0xFF4C6EF5)),
                    _buildNutrientCircle('Жиры', '--', 'г', const Color(0xFFFF6B6B)),
                    _buildNutrientCircle('Углеводы', '--', 'г', const Color(0xFFFFD43B)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Вода',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.water_drop, color: Color(0xFF339AF0), size: 32),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('--/8 стаканов',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Рекомендуется 2л в день',
                            style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(8, (i) => Container(
                    width: 28, height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(color: const Color(0xFF339AF0).withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.water_drop_outlined, color: Colors.white24, size: 16),
                  )),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMealRow(BuildContext context, IconData icon, String label, String mealName) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MealDetailPage(mealName: mealName)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 22),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientCircle(String label, String value, String unit, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 64, height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 0, strokeWidth: 6,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(unit, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2340),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}