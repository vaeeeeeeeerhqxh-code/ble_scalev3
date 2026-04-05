import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  static const _bg     = Color(0xFF0D1B3E);
  static const _card   = Color(0xFF1A2340);
  static const _accent = Color(0xFF4C6EF5);

  final List<_FaqItem> _items = const [
    _FaqItem(
      question: 'Как подключить весы к приложению?',
      answer: 'Включите Bluetooth на телефоне, затем нажмите «Взвеситься» или перейдите в «Управление устройством» → «Подключить весы». Приложение автоматически найдёт весы и подключится.',
    ),
    _FaqItem(
      question: 'Почему весы не находятся при поиске?',
      answer: '• Убедитесь что весы включены и рядом (до 2 м)\n• Bluetooth включён на телефоне\n• Разрешения на Bluetooth выданы приложению в настройках\n• Весы не подключены к другому устройству',
    ),
    _FaqItem(
      question: 'Что такое ИМТ (BMI) и как он считается?',
      answer: 'ИМТ — индекс массы тела. Формула: вес (кг) ÷ рост² (м).\n\n• До 18.5 — недостаточный вес\n• 18.5–24.9 — норма\n• 25–29.9 — избыточный вес\n• 30 и выше — ожирение',
    ),
    _FaqItem(
      question: 'Как весы измеряют процент жира?',
      answer: 'Используется технология биоэлектрического импеданса (BIA): через тело пропускается слабый безопасный ток. По сопротивлению тканей определяется состав тела — жир, мышцы, вода.',
    ),
    _FaqItem(
      question: 'Когда лучше всего взвешиваться?',
      answer: 'Для точных результатов взвешивайтесь утром, после туалета, натощак, без одежды. Старайтесь делать это в одно время каждый день.',
    ),
    _FaqItem(
      question: 'Почему вес отличается от обычных весов?',
      answer: 'Небольшие расхождения (0.1–0.3 кг) могут быть из-за положения весов, неровного пола или разного времени взвешивания.',
    ),
    _FaqItem(
      question: 'Мои данные в безопасности?',
      answer: 'Все данные хранятся локально на вашем устройстве. Приложение не передаёт личные данные третьим лицам без вашего согласия.',
    ),
    _FaqItem(
      question: 'Как добавить второго пользователя?',
      answer: 'На главном экране нажмите на имя профиля вверху — откроется список профилей. Там можно добавить участников и переключаться между ними.',
    ),
    _FaqItem(
      question: 'Что делать если весы не заряжаются?',
      answer: 'Проверьте кабель и порт зарядки на загрязнения. Попробуйте другой кабель или адаптер. Если проблема сохраняется — обратитесь к производителю весов.',
    ),
    _FaqItem(
      question: 'Как сбросить весы до заводских настроек?',
      answer: 'Перейдите в «Управление устройством» → «Сброс до заводских настроек». Все настройки весов будут удалены. Данные в приложении сохранятся.',
    ),
  ];

  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Частые вопросы',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2F6B), _bg, Color(0xFF0A0A1A)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            final isOpen = _expanded.contains(index);

            return GestureDetector(
              onTap: () => setState(() {
                isOpen ? _expanded.remove(index) : _expanded.add(index);
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isOpen ? _accent.withOpacity(0.4) : _accent.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Вопрос
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(children: [
                        Expanded(
                          child: Text(
                            item.question,
                            style: TextStyle(
                              color: isOpen ? Colors.white : Colors.white70,
                              fontSize: 14,
                              fontWeight: isOpen ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: isOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: isOpen ? _accent : Colors.white38,
                            size: 22,
                          ),
                        ),
                      ]),
                    ),

                    // Ответ
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: isOpen
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Colors.white10, height: 1),
                            const SizedBox(height: 12),
                            Text(
                              item.answer,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}