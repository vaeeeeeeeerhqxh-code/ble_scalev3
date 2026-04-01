import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double grams;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.grams,
  });

  Map<String, dynamic> toJson() => {
    'name': name, 'calories': calories,
    'protein': protein, 'fat': fat,
    'carbs': carbs, 'grams': grams,
  };

  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
    name: j['name'] ?? '',
    calories: (j['calories'] ?? 0).toDouble(),
    protein: (j['protein'] ?? 0).toDouble(),
    fat: (j['fat'] ?? 0).toDouble(),
    carbs: (j['carbs'] ?? 0).toDouble(),
    grams: (j['grams'] ?? 100).toDouble(),
  );
}

class MealDetailPage extends StatefulWidget {
  final String mealName;
  const MealDetailPage({super.key, required this.mealName});

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  List<FoodItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _key => 'meal_${widget.mealName}';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? '[]';
    final list = jsonDecode(raw) as List;
    setState(() => _items = list.map((e) => FoodItem.fromJson(e)).toList());
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  double get _totalCalories => _items.fold(0, (s, e) => s + e.calories);
  double get _totalProtein => _items.fold(0, (s, e) => s + e.protein);
  double get _totalFat => _items.fold(0, (s, e) => s + e.fat);
  double get _totalCarbs => _items.fold(0, (s, e) => s + e.carbs);

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final gramsCtrl = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A2340),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Добавить продукт',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _field(nameCtrl, 'Название продукта', Icons.fastfood_outlined),
            const SizedBox(height: 10),
            _field(calCtrl, 'Калории (ккал)', Icons.local_fire_department_outlined,
                isNumber: true),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(protCtrl, 'Белки (г)', Icons.egg_outlined, isNumber: true)),
              const SizedBox(width: 10),
              Expanded(child: _field(fatCtrl, 'Жиры (г)', Icons.opacity, isNumber: true)),
              const SizedBox(width: 10),
              Expanded(child: _field(carbCtrl, 'Углеводы (г)', Icons.grain, isNumber: true)),
            ]),
            const SizedBox(height: 10),
            _field(gramsCtrl, 'Порция (г)', Icons.scale_outlined, isNumber: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty) return;
                  final item = FoodItem(
                    name: nameCtrl.text,
                    calories: double.tryParse(calCtrl.text) ?? 0,
                    protein: double.tryParse(protCtrl.text) ?? 0,
                    fat: double.tryParse(fatCtrl.text) ?? 0,
                    carbs: double.tryParse(carbCtrl.text) ?? 0,
                    grams: double.tryParse(gramsCtrl.text) ?? 100,
                  );
                  setState(() => _items.add(item));
                  _save();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C6EF5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Добавить',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        filled: true,
        fillColor: const Color(0xFF0D1B3E),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        title: Text(widget.mealName, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B3E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4C6EF5)),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2F6B), Color(0xFF0D1B3E), Color(0xFF0A0A1A)],
          ),
        ),
        child: Column(
          children: [
            // Итого
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2340),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _nutrient('Калории', _totalCalories.round().toString(), 'ккал',
                      const Color(0xFF4C6EF5)),
                  _nutrient('Белки', _totalProtein.toStringAsFixed(1), 'г',
                      const Color(0xFF51CF66)),
                  _nutrient('Жиры', _totalFat.toStringAsFixed(1), 'г',
                      const Color(0xFFFF6B6B)),
                  _nutrient('Углеводы', _totalCarbs.toStringAsFixed(1), 'г',
                      const Color(0xFFFFD43B)),
                ],
              ),
            ),

            // Список продуктов
            Expanded(
              child: _items.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu,
                        size: 64, color: Colors.white.withOpacity(0.15)),
                    const SizedBox(height: 16),
                    const Text('Нет добавленных продуктов',
                        style: TextStyle(color: Colors.white38, fontSize: 16)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить продукт'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C6EF5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  return Dismissible(
                    key: Key('$i${item.name}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                    onDismissed: (_) {
                      setState(() => _items.removeAt(i));
                      _save();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2340),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.grams.round()}г  •  Б:${item.protein.toStringAsFixed(1)}  Ж:${item.fat.toStringAsFixed(1)}  У:${item.carbs.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text('${item.calories.round()} ккал',
                              style: const TextStyle(
                                  color: Color(0xFF4C6EF5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrient(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(unit, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}