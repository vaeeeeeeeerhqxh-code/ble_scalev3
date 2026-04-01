import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_info_screen.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  String _weightUnit = 'kg';
  String _lengthUnit = 'cm';
  String _language = 'Русский';
  String _region = 'Казахстан';
  bool _darkMode = true;

  final List<String> _languages = ['Казахский', 'Русский', 'Английский'];
  final List<String> _regions = ['Казахстан', 'Россия', 'США'];

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unit_weight', _weightUnit);
    await prefs.setString('unit_length', _lengthUnit);
    await prefs.setString('language', _language);
    await prefs.setString('region', _region);
    await prefs.setBool('dark_mode', _darkMode);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProfileInfoScreen()),
    );
  }

  void _showOptions(String title, List<String> options, String current, ValueChanged<String> onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2340),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...options.map((opt) {
            final isSelected = opt == current;
            return ListTile(
              title: Text(opt, style: TextStyle(
                color: isSelected ? const Color(0xFF4C6EF5) : Colors.white,
              )),
              trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF4C6EF5)) : null,
              onTap: () {
                onSelect(opt);
                Navigator.pop(ctx);
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
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
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 48),
                    const Text('Basic information',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Set basic information before using',
                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 32),

                    _buildMenuCard([
                      _buildRowTile(
                        label: 'Unit of weight',
                        value: _weightUnit,
                        onTap: () => _showOptions('Unit of weight', ['kg', 'lb'], _weightUnit,
                                (val) => setState(() => _weightUnit = val)),
                      ),
                      _buildRowTile(
                        label: 'Unit of length',
                        value: _lengthUnit,
                        onTap: () => _showOptions('Unit of length', ['cm', 'inch'], _lengthUnit,
                                (val) => setState(() => _lengthUnit = val)),
                      ),
                      _buildRowTile(
                        label: 'Language',
                        value: _language,
                        onTap: () => _showOptions('Language', _languages, _language,
                                (val) => setState(() => _language = val)),
                      ),
                      _buildRowTile(
                        label: 'Region',
                        value: _region,
                        onTap: () => _showOptions('Region', _regions, _region,
                                (val) => setState(() => _region = val)),
                      ),
                      _buildSwitchTile(
                        label: 'Dark Mode',
                        value: _darkMode,
                        onChanged: (val) => setState(() => _darkMode = val),
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6EF5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Продолжить',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2340),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildRowTile({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(value, style: const TextStyle(color: Colors.white54, fontSize: 15)),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: Colors.white10, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF4C6EF5),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: Colors.white10, indent: 16, endIndent: 16),
      ],
    );
  }
}