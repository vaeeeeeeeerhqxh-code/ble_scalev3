import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthToolsPage extends StatelessWidget {
  const HealthToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {
        'title': 'Калькулятор BMI',
        'subtitle': 'Индекс массы тела',
        'icon': Icons.monitor_weight_outlined,
        'color': const Color(0xFF4C6EF5),
        'onTap': () => _openCalculator(context, 'bmi'),
      },
      {
        'title': 'Норма воды',
        'subtitle': 'Суточная потребность',
        'icon': Icons.water_drop_outlined,
        'color': const Color(0xFF339AF0),
        'onTap': () => _openCalculator(context, 'water'),
      },
      {
        'title': 'Норма калорий',
        'subtitle': 'Дневная норма',
        'icon': Icons.local_fire_department_outlined,
        'color': const Color(0xFFFF922B),
        'onTap': () => _openCalculator(context, 'calories'),
      },
      {
        'title': 'Процент жира',
        'subtitle': 'Анализ состава тела',
        'icon': Icons.analytics_outlined,
        'color': const Color(0xFFFF6B6B),
        'onTap': () => _openCalculator(context, 'fat'),
      },
      {
        'title': 'Базальный метаболизм',
        'subtitle': 'BMR — калории в покое',
        'icon': Icons.speed_outlined,
        'color': const Color(0xFFCC5DE8),
        'onTap': () => _openCalculator(context, 'bmr'),
      },
      {
        'title': 'Мышечная масса',
        'subtitle': 'Расчёт мышечной массы',
        'icon': Icons.fitness_center,
        'color': const Color(0xFF51CF66),
        'onTap': () => _openCalculator(context, 'muscle'),
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Инструменты',
              style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final t = tools[index];
              final color = t['color'] as Color;
              return GestureDetector(
                onTap: t['onTap'] as VoidCallback,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2340),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(t['icon'] as IconData, color: color, size: 22),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['title'] as String,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(t['subtitle'] as String,
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _openCalculator(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _CalculatorPage(type: type)),
    );
  }
}

class _CalculatorPage extends StatefulWidget {
  final String type;
  const _CalculatorPage({required this.type});

  @override
  State<_CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<_CalculatorPage> {
  double _weight = 70;
  double _height = 170;
  int _age = 25;
  bool _isMale = true;
  double _activityLevel = 1.55;
  String _result = '';
  String _status = '';
  Color _statusColor = Colors.green;

  final Map<String, String> _titles = {
    'bmi': 'Калькулятор BMI',
    'water': 'Норма воды',
    'calories': 'Норма калорий',
    'fat': 'Процент жира',
    'bmr': 'Базальный метаболизм',
    'muscle': 'Мышечная масса',
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weight = (prefs.getDouble('last_weight') ?? 70);
      _height = (prefs.getInt('profile_height') ?? 170).toDouble();
      _isMale = (prefs.getString('profile_gender') ?? 'Мужской') == 'Мужской';
      final bday = prefs.getString('profile_birthday');
      if (bday != null) {
        final d = DateTime.tryParse(bday);
        if (d != null) _age = DateTime.now().year - d.year;
      }
    });
    _calculate();
  }

  void _calculate() {
    setState(() {
      switch (widget.type) {
        case 'bmi':
          final bmi = _weight / ((_height / 100) * (_height / 100));
          _result = '${bmi.toStringAsFixed(1)} кг/м²';
          if (bmi < 18.5) { _status = 'Недостаточный вес'; _statusColor = Colors.orange; }
          else if (bmi < 25) { _status = 'Норма'; _statusColor = Colors.green; }
          else if (bmi < 30) { _status = 'Избыточный вес'; _statusColor = Colors.orange; }
          else { _status = 'Ожирение'; _statusColor = Colors.redAccent; }
          break;

        case 'water':
          final water = _weight * 0.033;
          _result = '${water.toStringAsFixed(1)} л/день';
          _status = '${(water / 0.25).round()} стаканов';
          _statusColor = const Color(0xFF339AF0);
          break;

        case 'calories':
          double bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) + (_isMale ? 5 : -161);
          final tdee = bmr * _activityLevel;
          _result = '${tdee.round()} ккал/день';
          _status = 'Поддержание веса';
          _statusColor = const Color(0xFFFF922B);
          break;

        case 'fat':
          final bmi = _weight / ((_height / 100) * (_height / 100));
          double fat = (1.20 * bmi) + (0.23 * _age) - (_isMale ? 16.2 : 5.4);
          fat = fat.clamp(5.0, 50.0);
          _result = '${fat.toStringAsFixed(1)}%';
          if (_isMale) {
            _status = fat < 6 ? 'Очень низкий' : fat < 14 ? 'Спортсмен' : fat < 18 ? 'Фитнес' : fat < 25 ? 'Норма' : 'Высокий';
          } else {
            _status = fat < 14 ? 'Очень низкий' : fat < 21 ? 'Спортсмен' : fat < 25 ? 'Фитнес' : fat < 32 ? 'Норма' : 'Высокий';
          }
          _statusColor = _status == 'Норма' || _status == 'Фитнес' ? Colors.green : Colors.orange;
          break;

        case 'bmr':
          final bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) + (_isMale ? 5 : -161);
          _result = '${bmr.round()} ккал/день';
          _status = 'Калории в состоянии покоя';
          _statusColor = const Color(0xFFCC5DE8);
          break;

        case 'muscle':
          final bmi = _weight / ((_height / 100) * (_height / 100));
          final lbm = _weight - (_weight * ((4.15 * bmi - 0.082 * _weight - (_isMale ? 98.42 : 76.76)) / 100));
          _result = '${lbm.abs().toStringAsFixed(1)} кг';
          _status = 'Безжировая масса тела';
          _statusColor = const Color(0xFF51CF66);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        title: Text(_titles[widget.type] ?? 'Калькулятор',
            style: const TextStyle(color: Colors.white)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Результат
              if (_result.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2340),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(_result,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_status,
                            style: TextStyle(color: _statusColor, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

              // Параметры
              _buildCard(children: [
                _buildSlider('Вес', _weight, 30, 200, 'кг', (v) {
                  setState(() => _weight = v);
                  _calculate();
                }),
                _buildSlider('Рост', _height, 100, 220, 'см', (v) {
                  setState(() => _height = v);
                  _calculate();
                }),
                _buildSlider('Возраст', _age.toDouble(), 10, 100, 'лет', (v) {
                  setState(() => _age = v.round());
                  _calculate();
                }),
              ]),

              const SizedBox(height: 12),

              // Пол
              _buildCard(children: [
                Row(
                  children: [
                    const Text('Пол', style: TextStyle(color: Colors.white70, fontSize: 15)),
                    const Spacer(),
                    _genderBtn('Мужской', true),
                    const SizedBox(width: 8),
                    _genderBtn('Женский', false),
                  ],
                ),
              ]),

              // Уровень активности (только для калорий)
              if (widget.type == 'calories') ...[
                const SizedBox(height: 12),
                _buildCard(children: [
                  const Text('Уровень активности',
                      style: TextStyle(color: Colors.white70, fontSize: 15)),
                  const SizedBox(height: 12),
                  ...[
                    {'label': 'Минимальный (сидячий)', 'value': 1.2},
                    {'label': 'Лёгкая активность', 'value': 1.375},
                    {'label': 'Умеренная активность', 'value': 1.55},
                    {'label': 'Высокая активность', 'value': 1.725},
                    {'label': 'Очень высокая', 'value': 1.9},
                  ].map((a) {
                    final val = a['value'] as double;
                    final selected = _activityLevel == val;
                    return GestureDetector(
                      onTap: () { setState(() => _activityLevel = val); _calculate(); },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF4C6EF5).withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? const Color(0xFF4C6EF5) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(a['label'] as String,
                                style: TextStyle(
                                    color: selected ? const Color(0xFF4C6EF5) : Colors.white70,
                                    fontSize: 13)),
                            const Spacer(),
                            if (selected)
                              const Icon(Icons.check, color: Color(0xFF4C6EF5), size: 16),
                          ],
                        ),
                      ),
                    );
                  }),
                ]),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2340),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      String unit, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text('${value.round()} $unit',
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min, max: max,
          activeColor: const Color(0xFF4C6EF5),
          inactiveColor: Colors.white12,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _genderBtn(String label, bool isMale) {
    final selected = _isMale == isMale;
    return GestureDetector(
      onTap: () { setState(() => _isMale = isMale); _calculate(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4C6EF5) : const Color(0xFF0D1B3E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? const Color(0xFF4C6EF5) : Colors.white12),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.white54, fontSize: 13)),
      ),
    );
  }
}