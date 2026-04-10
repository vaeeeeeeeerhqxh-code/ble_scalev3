import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_manager.dart';

class MeasurementRecord {
  final DateTime date;
  final double weight;
  final double bodyFat;
  final double muscle;
  final double water;
  final double bmi;
  final double bmr;
  final double boneMass;
  final double visceralFat;
  final double protein;
  final double bodyAge;
  final double bodyHealth;

  MeasurementRecord({
    required this.date,
    required this.weight,
    required this.bodyFat,
    required this.muscle,
    required this.water,
    required this.bmi,
    required this.bmr,
    required this.boneMass,
    required this.visceralFat,
    required this.protein,
    required this.bodyAge,
    required this.bodyHealth,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight, 'bodyFat': bodyFat, 'muscle': muscle,
    'water': water, 'bmi': bmi, 'bmr': bmr, 'boneMass': boneMass,
    'visceralFat': visceralFat, 'protein': protein,
    'bodyAge': bodyAge, 'bodyHealth': bodyHealth,
  };

  factory MeasurementRecord.fromJson(Map<String, dynamic> j) => MeasurementRecord(
    date: DateTime.parse(j['date']),
    weight: (j['weight'] ?? 0).toDouble(),
    bodyFat: (j['bodyFat'] ?? 0).toDouble(),
    muscle: (j['muscle'] ?? 0).toDouble(),
    water: (j['water'] ?? 0).toDouble(),
    bmi: (j['bmi'] ?? 0).toDouble(),
    bmr: (j['bmr'] ?? 0).toDouble(),
    boneMass: (j['boneMass'] ?? 0).toDouble(),
    visceralFat: (j['visceralFat'] ?? 0).toDouble(),
    protein: (j['protein'] ?? 0).toDouble(),
    bodyAge: (j['bodyAge'] ?? 0).toDouble(),
    bodyHealth: (j['bodyHealth'] ?? 0).toDouble(),
  );
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  // История по профилям: profileId -> список записей
  final Map<String, List<MeasurementRecord>> _history = {};

  String get _activeId =>
      ProfileManager.instance.activeProfile?.id ?? 'default';

  List<MeasurementRecord> get records => _history[_activeId] ?? [];
  MeasurementRecord? get latest => records.isEmpty ? null : records.last;

  // Последние полученные значения импеданса из логов
  List<int> lastImpedanceValues = [];

  // ← ДОБАВЛЕНО: Данные профиля для BIA (всего 1 поле!)
  Map<String, dynamic>? lastProfileData;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Загружаем историю для всех профилей
    for (final profile in ProfileManager.instance.profiles) {
      final raw = prefs.getString('history_${profile.id}') ?? '[]';
      try {
        final list = jsonDecode(raw) as List;
        _history[profile.id] =
            list.map((e) => MeasurementRecord.fromJson(e)).toList();
      } catch (_) {
        _history[profile.id] = [];
      }
    }

    // Миграция старой истории
    final oldRaw = prefs.getString('measurement_history');
    if (oldRaw != null && _activeId != 'default') {
      try {
        final list = jsonDecode(oldRaw) as List;
        if (list.isNotEmpty && (_history[_activeId]?.isEmpty ?? true)) {
          _history[_activeId] =
              list.map((e) => MeasurementRecord.fromJson(e)).toList();
          await _saveForProfile(_activeId);
        }
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> addRecord(MeasurementRecord record) async {
    _history[_activeId] ??= [];
    _history[_activeId]!.add(record);
    await _saveForProfile(_activeId);
    notifyListeners();
  }

  void addMeasurement({
    required double weight,
    double bodyFat = 0,
    double muscle = 0,
    double water = 0,
    double bmi = 0,
    double bmr = 0,
    double boneMass = 0,
    double visceralFat = 0,
    double protein = 0,
    double bodyAge = 0,
    double bodyHealth = 0,
  }) {
    addRecord(MeasurementRecord(
      date: DateTime.now(),
      weight: weight,
      bodyFat: bodyFat,
      muscle: muscle,
      water: water,
      bmi: bmi,
      bmr: bmr,
      boneMass: boneMass,
      visceralFat: visceralFat,
      protein: protein,
      bodyAge: bodyAge,
      bodyHealth: bodyHealth,
    ));
  }

  Future<void> _saveForProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _history[profileId] ?? [];
    await prefs.setString(
      'history_$profileId',
      jsonEncode(list.map((r) => r.toJson()).toList()),
    );
  }

  /// При переключении профиля — перезагрузить данные
  Future<void> onProfileSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('history_$_activeId') ?? '[]';
    try {
      final list = jsonDecode(raw) as List;
      _history[_activeId] =
          list.map((e) => MeasurementRecord.fromJson(e)).toList();
    } catch (_) {
      _history[_activeId] = [];
    }
    notifyListeners();
  }

  List<double> valuesFor(String key) {
    return records.map((r) {
      switch (key) {
        case 'weight': return r.weight;
        case 'bodyFat': return r.bodyFat;
        case 'muscle': return r.muscle;
        case 'water': return r.water;
        case 'bmi': return r.bmi;
        case 'bmr': return r.bmr;
        case 'boneMass': return r.boneMass;
        case 'visceralFat': return r.visceralFat;
        case 'protein': return r.protein;
        case 'bodyAge': return r.bodyAge;
        case 'bodyHealth': return r.bodyHealth;
        default: return 0.0;
      }
    }).toList();
  }

  double latestFor(String key) {
    final r = latest;
    if (r == null) return 0.0;
    switch (key) {
      case 'weight': return r.weight;
      case 'bodyFat': return r.bodyFat;
      case 'muscle': return r.muscle;
      case 'water': return r.water;
      case 'bmi': return r.bmi;
      case 'bmr': return r.bmr;
      case 'boneMass': return r.boneMass;
      case 'visceralFat': return r.visceralFat;
      case 'protein': return r.protein;
      case 'bodyAge': return r.bodyAge;
      case 'bodyHealth': return r.bodyHealth;
      default: return 0.0;
    }
  }

  List<MeasurementRecord> recordsFor(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return records.where((r) => r.date.isAfter(cutoff)).toList();
  }

  String changePercent(String key) {
    final vals = valuesFor(key);
    if (vals.length < 2) return '';
    final prev = vals[vals.length - 2];
    final curr = vals[vals.length - 1];
    if (prev == 0) return '';
    final diff = ((curr - prev) / prev * 100);
    final sign = diff >= 0 ? '↑' : '↓';
    return '$sign${diff.abs().toStringAsFixed(1)}%';
  }
}
