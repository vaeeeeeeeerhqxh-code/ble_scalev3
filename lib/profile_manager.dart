import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String id;
  String name;
  String email;
  String gender;
  String type;
  int height;
  DateTime birthday;
  String weightUnit;
  String lengthUnit;

  UserProfile({
    required this.id,
    required this.name,
    this.email = '',
    this.gender = 'Мужской',
    this.type = 'Взрослый человек',
    this.height = 170,
    DateTime? birthday,
    this.weightUnit = 'kg',
    this.lengthUnit = 'cm',
  }) : birthday = birthday ?? DateTime(2000, 1, 1);

  int get age {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  bool get isMale => gender == 'Мужской';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'gender': gender,
    'type': type,
    'height': height,
    'birthday': birthday.toIso8601String(),
    'weightUnit': weightUnit,
    'lengthUnit': lengthUnit,
  };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    gender: j['gender'] ?? 'Мужской',
    type: j['type'] ?? 'Взрослый человек',
    height: j['height'] ?? 170,
    birthday: DateTime.tryParse(j['birthday'] ?? '') ?? DateTime(2000, 1, 1),
    weightUnit: j['weightUnit'] ?? 'kg',
    lengthUnit: j['lengthUnit'] ?? 'cm',
  );

  UserProfile copyWith({
    String? name, String? email, String? gender, String? type,
    int? height, DateTime? birthday, String? weightUnit, String? lengthUnit,
  }) => UserProfile(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    gender: gender ?? this.gender,
    type: type ?? this.type,
    height: height ?? this.height,
    birthday: birthday ?? this.birthday,
    weightUnit: weightUnit ?? this.weightUnit,
    lengthUnit: lengthUnit ?? this.lengthUnit,
  );
}

class ProfileManager extends ChangeNotifier {
  static final ProfileManager instance = ProfileManager._();
  ProfileManager._();

  List<UserProfile> _profiles = [];
  String _activeProfileId = '';

  List<UserProfile> get profiles => _profiles;

  UserProfile? get activeProfile {
    if (_profiles.isEmpty) return null;
    try {
      return _profiles.firstWhere((p) => p.id == _activeProfileId);
    } catch (_) {
      return _profiles.first;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('profiles') ?? '[]';
    final list = jsonDecode(raw) as List;
    _profiles = list.map((e) => UserProfile.fromJson(e)).toList();
    _activeProfileId = prefs.getString('active_profile_id') ?? '';

    // Миграция старых данных если профилей нет
    if (_profiles.isEmpty) {
      final oldName = prefs.getString('user_name');
      if (oldName != null && oldName.isNotEmpty) {
        final profile = UserProfile(
          id: 'profile_1',
          name: oldName,
          email: prefs.getString('user_email') ?? '',
          gender: prefs.getString('profile_gender') ?? 'Мужской',
          type: prefs.getString('profile_type') ?? 'Взрослый человек',
          height: prefs.getInt('profile_height') ?? 170,
          birthday: DateTime.tryParse(
                  prefs.getString('profile_birthday') ?? '') ??
              DateTime(2000, 1, 1),
          weightUnit: prefs.getString('unit_weight') ?? 'kg',
          lengthUnit: prefs.getString('unit_length') ?? 'cm',
        );
        _profiles = [profile];
        _activeProfileId = profile.id;
        await _save();
      }
    }

    if (_activeProfileId.isEmpty && _profiles.isNotEmpty) {
      _activeProfileId = _profiles.first.id;
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'profiles', jsonEncode(_profiles.map((p) => p.toJson()).toList()));
    await prefs.setString('active_profile_id', _activeProfileId);
  }

  /// Создать первый профиль при онбординге
  Future<UserProfile> createProfile({
    required String name,
    String email = '',
    String gender = 'Мужской',
    String type = 'Взрослый человек',
    int height = 170,
    DateTime? birthday,
    String weightUnit = 'kg',
    String lengthUnit = 'cm',
  }) async {
    final id = 'profile_${DateTime.now().millisecondsSinceEpoch}';
    final profile = UserProfile(
      id: id,
      name: name,
      email: email,
      gender: gender,
      type: type,
      height: height,
      birthday: birthday,
      weightUnit: weightUnit,
      lengthUnit: lengthUnit,
    );
    _profiles.add(profile);
    _activeProfileId = id;
    await _save();
    notifyListeners();
    return profile;
  }

  /// Переключить активный профиль
  Future<void> switchProfile(String profileId) async {
    _activeProfileId = profileId;
    await _save();
    notifyListeners();
  }

  /// Обновить профиль
  Future<void> updateProfile(UserProfile updated) async {
    final idx = _profiles.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _profiles[idx] = updated;
      await _save();
      notifyListeners();
    }
  }

  /// Удалить профиль (нельзя удалить активный)
  Future<bool> deleteProfile(String profileId) async {
    if (profileId == _activeProfileId) return false;
    _profiles.removeWhere((p) => p.id == profileId);
    await _save();
    notifyListeners();
    return true;
  }

  bool get hasProfiles => _profiles.isNotEmpty;
  bool get canAddMore => _profiles.length < 5;
}
