import 'package:flutter/material.dart';
import 'basic_info_screen.dart';
import 'profile_manager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Создаём первый профиль через ProfileManager
    await ProfileManager.instance.createProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BasicInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                  const SizedBox(height: 60),
                  Center(
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2340),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF4C6EF5), width: 2),
                      ),
                      child: const Icon(Icons.monitor_weight_outlined,
                          color: Color(0xFF4C6EF5), size: 40),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text('Добро пожаловать!',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Расскажите немного о себе',
                        style: TextStyle(color: Colors.white54, fontSize: 15)),
                  ),
                  const SizedBox(height: 48),
                  _buildLabel('Ваше имя'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Например: Nurda',
                    icon: Icons.person_outline,
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Введите имя' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Электронная почта (необязательно)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'example@gmail.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C6EF5),
                        disabledBackgroundColor: const Color(0xFF4C6EF5).withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
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

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF1A2340),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4C6EF5), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
