import 'package:flutter/material.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_peripheral_ice.dart';
import 'profile_manager.dart';
import 'ble_scan_page.dart';
import 'profile_info_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

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
          child: ListenableBuilder(
            listenable: ProfileManager.instance,
            builder: (context, _) {
              final profile = ProfileManager.instance.activeProfile;
              return ListView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 28),

                  _buildSectionLabel('Устройство'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _SettingsItem(
                      icon: Icons.bluetooth,
                      label: 'Подключить весы',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BleScanPage()),
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.straighten,
                      label: 'Единицы измерения',
                      trailing: Text(
                        profile?.weightUnit ?? 'kg',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14),
                      ),
                      onTap: () => _showUnitsDialog(profile),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildSectionLabel('Профиль'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _SettingsItem(
                      icon: Icons.person_outline,
                      label: 'Редактировать профиль',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileInfoScreen(
                              profileId: profile?.id),
                        ),
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Рост: ${profile?.height ?? '--'} ${profile?.lengthUnit ?? 'cm'}',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileInfoScreen(
                              profileId: profile?.id),
                        ),
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.cake_outlined,
                      label: profile != null
                          ? 'Возраст: ${profile.age} лет'
                          : 'Возраст: --',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileInfoScreen(
                              profileId: profile?.id),
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildSectionLabel('Прочее'),
                  const SizedBox(height: 10),
                  _buildMenuCard([
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      label: 'Уведомления',
                      trailing: Switch(
                        value: notificationsEnabled,
                        onChanged: (val) =>
                            setState(() => notificationsEnabled = val),
                        activeColor: const Color(0xFF4C6EF5),
                      ),
                      onTap: () =>
                          setState(() => notificationsEnabled = !notificationsEnabled),
                    ),
                    _SettingsItem(
                      icon: Icons.info_outline,
                      label: 'О приложении',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'BLE Scale App',
                        applicationVersion: '1.0',
                        children: const [
                          Text('Приложение для работы с умными весами.'),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile? profile) {
    return Row(
      children: [
        Container(
          width: 64, height: 64,
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
                profile?.name ?? '...',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                profile != null
                    ? '${profile.type} · ${profile.gender}'
                    : '',
                style:
                const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        _buildIconButton(
          Icons.edit_outlined,
              () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProfileInfoScreen(profileId: profile?.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFF1E2D5A),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildMenuCard(List<_SettingsItem> items) {
    return Column(
      children: items.map((item) {
        final isLast = item == items.last;
        return Column(children: [
          _buildMenuTile(item),
          if (!isLast) const SizedBox(height: 8),
        ]);
      }).toList(),
    );
  }

  Widget _buildMenuTile(_SettingsItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2340),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(
                  color: Color(0xFF2A3A6B), shape: BoxShape.circle),
              child: Icon(item.icon, color: Colors.white70, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            if (item.trailing != null) item.trailing!,
            if (item.trailing == null)
              const Icon(Icons.chevron_right,
                  color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }

  void _showUnitsDialog(UserProfile? profile) {
    if (profile == null) return;
    String currentUnit = profile.weightUnit;

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
              title: Text(unit,
                  style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF4C6EF5)
                          : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal)),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Color(0xFF4C6EF5))
                  : null,
              onTap: () async {
                Navigator.pop(ctx);
                // Сохраняем в профиль
                await ProfileManager.instance.updateProfile(
                  profile.copyWith(weightUnit: unit),
                );
                // Синхронизируем с весами
                try {
                  await PPPeripheralIce.syncUnit(
                    unit == 'lb'
                        ? (await _getLbUnit())
                        : (await _getKgUnit()),
                  );
                } catch (_) {}
                setState(() {});
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // Хелперы для PPUnitType
  Future<dynamic> _getLbUnit() async {
    // ignore: invalid_use_of_internal_member
    return 1; // PPUnitType.Unit_LB — числовое значение
  }

  Future<dynamic> _getKgUnit() async {
    return 0; // PPUnitType.Unit_KG
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });
}