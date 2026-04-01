import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  // Данные пользователя — загружаются из SharedPreferences
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Читаем имя и email, которые пользователь ввёл на онбординге
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Пользователь';
      userEmail = prefs.getString('user_email') ?? '';
    });
  }

  /// Сохраняем обновлённые данные (вызывается из диалога редактирования)
  Future<void> _saveUserData(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    setState(() {
      userName = name;
      userEmail = email;
    });
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
            colors: [
              Color(0xFF1A2F6B),
              Color(0xFF0D1B3E),
              Color(0xFF0A0A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 28),

              _buildSectionLabel('Устройство'),
              const SizedBox(height: 10),
              _buildMenuCard([
                _SettingsItem(
                  icon: Icons.bluetooth,
                  label: 'Подключить весы',
                  onTap: () {
                    // TODO: открыть BLE scanner
                  },
                ),
                _SettingsItem(
                  icon: Icons.straighten,
                  label: 'Единицы измерения',
                  onTap: _showUnitsDialog,
                ),
                _SettingsItem(
                  icon: Icons.tune,
                  label: 'Калибровка',
                  onTap: () {
                    // TODO: экран калибровки
                  },
                ),
              ]),

              const SizedBox(height: 24),

              _buildSectionLabel('Прочее'),
              const SizedBox(height: 10),
              _buildMenuCard([
                _SettingsItem(
                  icon: Icons.settings,
                  label: 'Общие настройки',
                  onTap: _showGeneralSettings,
                ),
                _SettingsItem(
                  icon: Icons.info_outline,
                  label: 'О приложении',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'BLE Scale App',
                      applicationVersion: '1.0',
                      children: const [
                        Text('Приложение для работы с умными весами.'),
                      ],
                    );
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4C6EF5), width: 2),
          ),
          child: const CircleAvatar(
            backgroundColor: Color(0xFF2A3A6B),
            child: Icon(Icons.person, color: Colors.white54, size: 32),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName.isEmpty ? '...' : userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userEmail,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        _buildIconButton(Icons.contrast, () {
          setState(() => isDarkMode = !isDarkMode);
        }),
        const SizedBox(width: 8),
        _buildIconButton(Icons.edit_outlined, _showEditProfileDialog),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFF1E2D5A),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMenuCard(List<_SettingsItem> items) {
    return Column(
      children: items.map((item) {
        final isLast = item == items.last;
        return Column(
          children: [
            _buildMenuTile(item),
            if (!isLast) const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMenuTile(_SettingsItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2340),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2A3A6B),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: Colors.white70, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: userName);
    final emailCtrl = TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2340),
        title: const Text('Редактировать профиль',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nameCtrl, 'Имя', Icons.person_outline),
            const SizedBox(height: 12),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              _saveUserData(
                nameCtrl.text.trim(),
                emailCtrl.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить',
                style: TextStyle(color: Color(0xFF4C6EF5))),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(
      TextEditingController ctrl,
      String hint,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF0D1B3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: Color(0xFF4C6EF5), width: 1.5),
        ),
      ),
    );
  }

  void _showUnitsDialog() async {
    final prefs = await SharedPreferences.getInstance();
    String currentUnit = prefs.getString('unit_weight') ?? 'kg';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2340),
        title: const Text('Единицы измерения',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['kg', 'lb'].map((unit) {
            final isSelected = unit == currentUnit;
            return ListTile(
              title: Text(unit, style: TextStyle(
                color: isSelected ? const Color(0xFF4C6EF5) : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Color(0xFF4C6EF5))
                  : null,
              onTap: () async {
                final p = await SharedPreferences.getInstance();
                await p.setString('unit_weight', unit);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showGeneralSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2340),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Тёмная тема',
                  style: TextStyle(color: Colors.white)),
              value: isDarkMode,
              activeColor: const Color(0xFF4C6EF5),
              onChanged: (val) {
                setState(() => isDarkMode = val);
                Navigator.pop(ctx);
              },
            ),
            SwitchListTile(
              title: const Text('Уведомления',
                  style: TextStyle(color: Colors.white)),
              value: notificationsEnabled,
              activeColor: const Color(0xFF4C6EF5),
              onChanged: (val) =>
                  setState(() => notificationsEnabled = val),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}