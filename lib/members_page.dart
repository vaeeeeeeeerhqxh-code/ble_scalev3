import 'package:flutter/material.dart';
import 'profile_manager.dart';
import 'onboarding_screen.dart';
import 'profile_info_screen.dart';
import 'app_state.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        title: const Text('Управление участниками', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B3E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2F6B), Color(0xFF0D1B3E), Color(0xFF0A0A1A)],
          ),
        ),
        child: ListenableBuilder(
          listenable: ProfileManager.instance,
          builder: (context, _) {
            final profiles = ProfileManager.instance.profiles;
            final activeId = ProfileManager.instance.activeProfile?.id;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...profiles.map((profile) {
                  final isActive = profile.id == activeId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2340),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF4C6EF5).withOpacity(0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2A3A6B),
                            border: Border.all(
                              color: isActive ? const Color(0xFF4C6EF5) : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: const Icon(Icons.person, color: Colors.white54, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.name,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                '${profile.type} · ${profile.gender} · ${profile.age} лет',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C6EF5).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Активный',
                                style: TextStyle(color: Color(0xFF4C6EF5), fontSize: 12)),
                          )
                        else
                          Row(
                            children: [
                              // Редактировать
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 20),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileInfoScreen(profileId: profile.id),
                                  ),
                                ),
                              ),
                              // Удалить
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => _confirmDelete(context, profile),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // Кнопка добавить (максимум 5)
                if (ProfileManager.instance.canAddMore)
                  GestureDetector(
                    onTap: () => _addProfile(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2340),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, color: Color(0xFF4C6EF5), size: 22),
                          SizedBox(width: 10),
                          Text('Добавить участника',
                              style: TextStyle(
                                  color: Color(0xFF4C6EF5),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Достигнут максимум (5 профилей)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white24, fontSize: 13),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _addProfile(BuildContext context) {
    // Новый профиль проходит онбординг
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _NewProfileOnboarding()),
    );
  }

  void _confirmDelete(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2340),
        title: const Text('Удалить профиль', style: TextStyle(color: Colors.white)),
        content: Text('Удалить профиль "${profile.name}"? Все данные будут потеряны.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ProfileManager.instance.deleteProfile(profile.id);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

/// Онбординг для нового участника (имя → профиль → главная не меняется)
class _NewProfileOnboarding extends StatefulWidget {
  const _NewProfileOnboarding();

  @override
  State<_NewProfileOnboarding> createState() => _NewProfileOnboardingState();
}

class _NewProfileOnboardingState extends State<_NewProfileOnboarding> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await ProfileManager.instance.createProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );

    // Загрузить историю для нового профиля
    await AppState.instance.onProfileSwitch();

    if (!mounted) return;

    // Идём на заполнение профиля
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProfileInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        title: const Text('Новый участник', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B3E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2F6B), Color(0xFF0D1B3E), Color(0xFF0A0A1A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2340), shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF4C6EF5), width: 2),
                      ),
                      child: const Icon(Icons.person_add_outlined, color: Color(0xFF4C6EF5), size: 36),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(child: Text('Новый участник',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 40),
                  const Text('Имя', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
                    decoration: _inputDeco('Например: Aisha', Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  const Text('Email (необязательно)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('example@gmail.com', Icons.email_outlined),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity, height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C6EF5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Далее',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white30),
    prefixIcon: Icon(icon, color: Colors.white38, size: 20),
    filled: true,
    fillColor: const Color(0xFF1A2340),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4C6EF5), width: 1.5)),
  );
}
