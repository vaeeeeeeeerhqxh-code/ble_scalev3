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
  // Сегментарный анализ — мышцы
  final double mLa;
  final double mRa;
  final double mLl;
  final double mRl;
  final double mTr;
  // Сегментарный анализ — жир
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
    this.mLa = 0, this.mRa = 0, this.mLl = 0, this.mRl = 0, this.mTr = 0,
    this.fLa = 0, this.fRa = 0, this.fLl = 0, this.fRl = 0, this.fTr = 0,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight, 'bodyFat': bodyFat, 'muscle': muscle,
    'water': water, 'bmi': bmi, 'bmr': bmr, 'boneMass': boneMass,
    'visceralFat': visceralFat, 'protein': protein,
    'bodyAge': bodyAge, 'bodyHealth': bodyHealth,
    'm_la': mLa, 'm_ra': mRa, 'm_ll': mLl, 'm_rl': mRl, 'm_tr': mTr,
    'f_la': fLa, 'f_ra': fRa, 'f_ll': fLl, 'f_rl': fRl, 'f_tr': fTr,
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
    mLa: (j['m_la'] ?? 0).toDouble(), mRa: (j['m_ra'] ?? 0).toDouble(),
    mLl: (j['m_ll'] ?? 0).toDouble(), mRl: (j['m_rl'] ?? 0).toDouble(),
    mTr: (j['m_tr'] ?? 0).toDouble(),
    fLa: (j['f_la'] ?? 0).toDouble(), fRa: (j['f_ra'] ?? 0).toDouble(),
    fLl: (j['f_ll'] ?? 0).toDouble(), fRl: (j['f_rl'] ?? 0).toDouble(),
    fTr: (j['f_tr'] ?? 0).toDouble(),
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

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final profile in ProfileManager.instance.profiles) {
      final raw = prefs.getString('history_${profile.id}') ?? '[]';
      try {
        final list = jsonDecode(raw) as List;
        _history[profile.id] = list.map((e) => MeasurementRecord.fromJson(e)).toList();
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
          _history[_activeId] = list.map((e) => MeasurementRecord.fromJson(e)).toList();
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

  Future<void> _saveForProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _history[profileId] ?? [];
    await prefs.setString(
      'history_$profileId',
      jsonEncode(list.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> onProfileSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('history_$_activeId') ?? '[]';
    try {
      final list = jsonDecode(raw) as List;
      _history[_activeId] = list.map((e) => MeasurementRecord.fromJson(e)).toList();
    } catch (_) {
      _history[_activeId] = [];
    }
    notifyListeners();
  }

  List<double> valuesFor(String key) {
    return records.map((r) {
      switch (key) {
        case 'weight':      return r.weight;
        case 'bodyFat':     return r.bodyFat;
        case 'muscle':      return r.muscle;
        case 'water':       return r.water;
        case 'bmi':         return r.bmi;
        case 'bmr':         return r.bmr;
        case 'boneMass':    return r.boneMass;
        case 'visceralFat': return r.visceralFat;
        case 'protein':     return r.protein;
        case 'bodyAge':     return r.bodyAge;
        case 'bodyHealth':  return r.bodyHealth;
        case 'm_la':        return r.mLa;
        case 'm_ra':        return r.mRa;
        case 'm_ll':        return r.mLl;
        case 'm_rl':        return r.mRl;
        case 'm_tr':        return r.mTr;
        case 'f_la':        return r.fLa;
        case 'f_ra':        return r.fRa;
        case 'f_ll':        return r.fLl;
        case 'f_rl':        return r.fRl;
        case 'f_tr':        return r.fTr;
        default:            return 0.0;
      }
    }).toList();
  }

  // Получить значение из latest по ключу
  double latestFor(String key) {
    final l = latest;
    if (l == null) return 0;
    switch (key) {
      case 'weight':      return l.weight;
      case 'bodyFat':     return l.bodyFat;
      case 'muscle':      return l.muscle;
      case 'water':       return l.water;
      case 'bmi':         return l.bmi;
      case 'bmr':         return l.bmr;
      case 'boneMass':    return l.boneMass;
      case 'visceralFat': return l.visceralFat;
      case 'protein':     return l.protein;
      case 'bodyAge':     return l.bodyAge;
      case 'bodyHealth':  return l.bodyHealth;
      case 'm_la':        return l.mLa;
      case 'm_ra':        return l.mRa;
      case 'm_ll':        return l.mLl;
      case 'm_rl':        return l.mRl;
      case 'm_tr':        return l.mTr;
      case 'f_la':        return l.fLa;
      case 'f_ra':        return l.fRa;
      case 'f_ll':        return l.fLl;
      case 'f_rl':        return l.fRl;
      case 'f_tr':        return l.fTr;
      default:            return 0;
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
    return '${diff >= 0 ? '↑' : '↓'}${diff.abs().toStringAsFixed(1)}%';
  }
}