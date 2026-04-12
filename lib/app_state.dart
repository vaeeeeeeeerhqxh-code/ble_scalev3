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

  // Segmental Muscle
  final double mLa;
  final double mRa;
  final double mLl;
  final double mRl;
  final double mTr;

  // Segmental Fat
  final double fLa;
  final double fRa;
  final double fLl;
  final double fRl;
  final double fTr;

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
    this.mLa = 0,
    this.mRa = 0,
    this.mLl = 0,
    this.mRl = 0,
    this.mTr = 0,
    this.fLa = 0,
    this.fRa = 0,
    this.fLl = 0,
    this.fRl = 0,
    this.fTr = 0,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight, 'bodyFat': bodyFat, 'muscle': muscle,
    'water': water, 'bmi': bmi, 'bmr': bmr, 'boneMass': boneMass,
    'visceralFat': visceralFat, 'protein': protein,
    'bodyAge': bodyAge, 'bodyHealth': bodyHealth,
    'mLa': mLa, 'mRa': mRa, 'mLl': mLl, 'mRl': mRl, 'mTr': mTr,
    'fLa': fLa, 'fRa': fRa, 'fLl': fLl, 'fRl': fRl, 'fTr': fTr,
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
    mLa: (j['mLa'] ?? 0).toDouble(),
    mRa: (j['mRa'] ?? 0).toDouble(),
    mLl: (j['mLl'] ?? 0).toDouble(),
    mRl: (j['mRl'] ?? 0).toDouble(),
    mTr: (j['mTr'] ?? 0).toDouble(),
    fLa: (j['fLa'] ?? 0).toDouble(),
    fRa: (j['fRa'] ?? 0).toDouble(),
    fLl: (j['fLl'] ?? 0).toDouble(),
    fRl: (j['fRl'] ?? 0).toDouble(),
    fTr: (j['fTr'] ?? 0).toDouble(),
  );
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  final Map<String, List<MeasurementRecord>> _history = {};

  String get _activeId =>
      ProfileManager.instance.activeProfile?.id ?? 'default';

  List<MeasurementRecord> get records => _history[_activeId] ?? [];
  MeasurementRecord? get latest => records.isEmpty ? null : records.last;

  List<int> lastImpedanceValues = [];
  Map<String, dynamic>? lastProfileData;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
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
    notifyListeners();
  }

  Future<void> addRecord(MeasurementRecord record) async {
    _history[_activeId] ??= [];
    _history[_activeId]!.add(record);
    await _saveForProfile(_activeId);
    notifyListeners();
  }

  Future<void> _saveForProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _history[profileId] ?? [];
    await prefs.setString(
      'history_$profileId',
      jsonEncode(list.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> onProfileSwitch() async {
    await load();
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
        case 'm_la': return r.mLa;
        case 'm_ra': return r.mRa;
        case 'm_ll': return r.mLl;
        case 'm_rl': return r.mRl;
        case 'm_tr': return r.mTr;
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
      case 'm_la': return r.mLa;
      case 'm_ra': return r.mRa;
      case 'm_ll': return r.mLl;
      case 'm_rl': return r.mRl;
      case 'm_tr': return r.mTr;
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
