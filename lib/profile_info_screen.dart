import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'main_screen.dart';
import 'profile_manager.dart';

class ProfileInfoScreen extends StatefulWidget {
  final String? profileId;
  const ProfileInfoScreen({super.key, this.profileId});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  String _type = 'Взрослый человек';
  String _gender = 'Мужской';
  DateTime _birthday = DateTime(2000, 1, 1);
  int _height = 170;
  String _lengthUnit = 'cm';
  String? _avatarPath;

  final List<String> _types = ['Взрослый человек', 'Спортсмен', 'Ребёнок'];
  final List<String> _genders = ['Мужской', 'Женский'];

  UserProfile? get _targetProfile {
    final id = widget.profileId;
    if (id != null) {
      try { return ProfileManager.instance.profiles.firstWhere((p) => p.id == id); } catch (_) {}
    }
    return ProfileManager.instance.activeProfile;
  }

  @override
  void initState() {
    super.initState();
    final p = _targetProfile;
    if (p != null) {
      _type = p.type; _gender = p.gender;
      _birthday = p.birthday; _height = p.height; _lengthUnit = p.lengthUnit;
      _avatarPath = p.avatarPath.isEmpty ? null : p.avatarPath;
    }
  }

  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2340),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text('Фото таңдау', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white70),
            title: const Text('Галереядан', style: TextStyle(color: Colors.white)),
            onTap: () async {
              Navigator.pop(ctx);
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (picked != null) setState(() => _avatarPath = picked.path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white70),
            title: const Text('Камерадан', style: TextStyle(color: Colors.white)),
            onTap: () async {
              Navigator.pop(ctx);
              final picked = await ImagePicker().pickImage(
                source: ImageSource.camera,
                imageQuality: 85,
              );
              if (picked != null) setState(() => _avatarPath = picked.path);
            },
          ),
          if (_avatarPath != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Фотоны жою', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _avatarPath = null);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    final profile = _targetProfile;
    if (profile == null) return;
    await ProfileManager.instance.updateProfile(profile.copyWith(
      type: _type, gender: _gender, birthday: _birthday, height: _height,
      avatarPath: _avatarPath ?? '',
    ));
    if (!mounted) return;
    if (widget.profileId == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      Navigator.of(context).pop();
    }
  }

  void _pickBirthday() {
    DateTime tempDate = _birthday;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280, color: const Color(0xFF1A2340),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CupertinoButton(child: const Text('Отмена', style: TextStyle(color: Colors.white54)), onPressed: () => Navigator.pop(context)),
            CupertinoButton(child: const Text('Готово', style: TextStyle(color: Color(0xFF4C6EF5))), onPressed: () { setState(() => _birthday = tempDate); Navigator.pop(context); }),
          ]),
          Expanded(child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date, initialDateTime: _birthday,
            maximumDate: DateTime.now(), minimumYear: 1920,
            onDateTimeChanged: (val) => tempDate = val,
          )),
        ]),
      ),
    );
  }

  void _pickHeight() {
    int tempHeight = _height;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280, color: const Color(0xFF1A2340),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CupertinoButton(child: const Text('Отмена', style: TextStyle(color: Colors.white54)), onPressed: () => Navigator.pop(context)),
            CupertinoButton(child: const Text('Готово', style: TextStyle(color: Color(0xFF4C6EF5))), onPressed: () { setState(() => _height = tempHeight); Navigator.pop(context); }),
          ]),
          Expanded(child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: tempHeight - 100),
            itemExtent: 40,
            onSelectedItemChanged: (i) => tempHeight = i + 100,
            children: List.generate(151, (i) => Center(child: Text('${i + 100} $_lengthUnit', style: const TextStyle(color: Colors.white, fontSize: 18)))),
          )),
        ]),
      ),
    );
  }

  void _showOptions(String title, List<String> options, String current, ValueChanged<String> onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2340),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...options.map((opt) {
            final sel = opt == current;
            return ListTile(
              title: Text(opt, style: TextStyle(color: sel ? const Color(0xFF4C6EF5) : Colors.white)),
              trailing: sel ? const Icon(Icons.check, color: Color(0xFF4C6EF5)) : null,
              onTap: () { onSelect(opt); Navigator.pop(ctx); },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formattedBirthday() =>
      '${_birthday.year}-${_birthday.month.toString().padLeft(2, '0')}-${_birthday.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.profileId != null;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: isEditing ? AppBar(
        title: const Text('Редактировать профиль', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B3E), elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ) : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF1A2F6B), Color(0xFF0D1B3E), Color(0xFF0A0A1A)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 48),
                    Center(
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1A2340),
                                border: Border.all(color: const Color(0xFF4C6EF5), width: 2),
                              ),
                              child: ClipOval(
                                child: _avatarPath != null
                                    ? Image.file(File(_avatarPath!), fit: BoxFit.cover, width: 80, height: 80)
                                    : const Icon(Icons.person, color: Colors.white54, size: 40),
                              ),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 24, height: 24,
                                decoration: const BoxDecoration(color: Color(0xFF4C6EF5), shape: BoxShape.circle),
                                child: const Icon(Icons.edit, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(child: Text(isEditing ? 'Редактировать информацию' : 'Заполните информацию',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 32),
                    _buildMenuCard([
                      _buildTile('Тип', _type, () => _showOptions('Тип', _types, _type, (v) => setState(() => _type = v))),
                      _buildTile('Пол', _gender, () => _showOptions('Пол', _genders, _gender, (v) => setState(() => _gender = v))),
                      _buildTile('День рождения', _formattedBirthday(), _pickBirthday),
                      _buildTile('Рост', '$_height $_lengthUnit', _pickHeight, isLast: true),
                    ]),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6EF5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(isEditing ? 'Сохранить' : 'Продолжить',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) => Container(
    decoration: BoxDecoration(color: const Color(0xFF1A2340), borderRadius: BorderRadius.circular(14)),
    child: Column(children: items),
  );

  Widget _buildTile(String label, String value, VoidCallback onTap, {bool isLast = false}) {
    return Column(children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(value, style: const TextStyle(color: Colors.white54, fontSize: 15)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ]),
        ),
      ),
      if (!isLast) const Divider(height: 1, color: Colors.white10, indent: 16, endIndent: 16),
    ]);
  }
}