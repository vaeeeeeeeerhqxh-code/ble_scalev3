import 'dart:math';

class UserProfile {
  final double height; // cm
  final int age;
  final bool isMale;

  UserProfile({
    required this.height,
    required this.age,
    required this.isMale,
  });
}

class BodyAnalyzer {
  static Map<String, dynamic> calculate({
    required double weight,
    required List<int> impedanceValues,
    required UserProfile profile,
  }) {
    // -----------------------------
    // ✅ 1. VALIDATION
    // -----------------------------
    if (weight <= 0 || weight > 300 || impedanceValues.isEmpty) {
      print("ERROR: Invalid input");
      return {};
    }

    final height = profile.height;
    final age = profile.age;
    final isMale = profile.isMale;

    // -----------------------------
    // ✅ 2. BMI
    // -----------------------------
    final heightM = height / 100.0;
    final bmi = weight / (heightM * heightM);

    // -----------------------------
    // ✅ 3. IMPEDANCE PROCESSING
    // -----------------------------
    List<double> processed = impedanceValues.map((v) {
      if (v <= 0) return 0.0;
      if (v > 10000) return v / 100.0;
      return v.toDouble();
    }).where((v) => v > 100 && v < 1200).toList();

    if (processed.isEmpty) {
      print("ERROR: No valid impedance");
      return {};
    }

    final resistance =
        processed.reduce((a, b) => a + b) / processed.length;

    // -----------------------------
    // ✅ 4. IMP INDEX
    // -----------------------------
    final impIndex = (height * height) / resistance;

    // -----------------------------
    // ✅ 5. TBW
    // -----------------------------
    double tbw;

    if (isMale) {
      tbw =
          (0.396 * impIndex) +
              (0.143 * weight) +
              (0.067 * age) +
              0.1;
    } else {
      tbw =
          (0.346 * impIndex) +
              (0.137 * weight) +
              (0.054 * age) +
              0.1;
    }

    // -----------------------------
    // ✅ 6. FFM (ADAPTIVE)
    // -----------------------------
    double hydrationBase = isMale ? 0.72 : 0.69;

    double rNorm = resistance / (height * 2.2);

    double correction =
    (1.0 + (rNorm - 1.0) * 0.4).clamp(0.85, 1.15);

    double ffm = tbw / (hydrationBase * correction);
    ffm = ffm.clamp(weight * 0.5, weight * 0.95);

    // -----------------------------
    // ✅ 7. FAT
    // -----------------------------
    double fatMass = weight - ffm;

    double bodyFat = fatMass / weight * 100;

    double fatCorrection =
        ((bmi - 20) * 0.8) +
            ((resistance - 400) * 0.02);

    bodyFat = (bodyFat + fatCorrection).clamp(5.0, 35.0);

    // -----------------------------
    // ✅ 8. WATER
    // -----------------------------
    double water = (tbw / weight * 100).clamp(30.0, 75.0);

    // -----------------------------
    // ✅ 9. FAT TYPES
    // -----------------------------
    double subcutaneousFat =
    (bodyFat * 0.82).clamp(5.0, 35.0);

    double visceralFat = (
        (bodyFat * 0.12) +
            (bmi * 0.18) +
            (isMale ? 1.5 : 1)
    ).clamp(1.0, 15.0);

    // -----------------------------
    // ✅ 10. MUSCLE (REAL)
    // -----------------------------
    double skeletalMuscle = ffm * (isMale ? 0.50 : 0.45);
    double skeletalMusclePercent =
        skeletalMuscle / weight * 100;

    // -----------------------------
    // ✅ 11. BODY MUSCLE (как в весах)
    // -----------------------------
    double bodyMuscle = ffm;
    double bodyMusclePercent =
        (ffm / weight) * 100;

    // -----------------------------
    // ✅ 12. CLASSIC MUSCLE
    // -----------------------------
    double muscleMass = ffm * (isMale ? 0.56 : 0.51);
    double muscle = muscleMass / weight * 100;

    // -----------------------------
    // ✅ 13. BONE
    // -----------------------------
    double boneMass = (
        ffm * 0.055 +
            weight * 0.008
    ).clamp(2.5, 4.0);

    // -----------------------------
    // ✅ 14. PROTEIN
    // -----------------------------
    double protein =
    (muscleMass * 0.2 / weight * 100).clamp(8.0, 25.0);

    // -----------------------------
    // ✅ 15. BMR
    // -----------------------------
    double bmr = isMale
        ? 10 * weight + 6.25 * height - 5 * age + 5
        : 10 * weight + 6.25 * height - 5 * age - 161;

    // -----------------------------
    // ✅ 16. LEAN MASS
    // -----------------------------
    double leanMassPercent = (ffm / weight) * 100;

    // -----------------------------
    // ✅ 17. BODY AGE
    // -----------------------------
    double normalFat = isMale ? 15.0 : 22.0;

    double bodyAge =
    (age + (bodyFat - normalFat) * 0.4)
        .clamp(age - 5, age + 20);

    // -----------------------------
    // ✅ 18. HEALTH
    // -----------------------------
    double idealFat = isMale ? 12.0 : 20.0;

    double bodyHealth =
    (100 - (bodyFat - idealFat).abs() * 2.5)
        .clamp(0.0, 100.0);

    // -----------------------------
    // ✅ 19. SEGMENTS (BASE)
    // -----------------------------
    double m = muscleMass;

    double m_la = m * 0.105;
    double m_ra = m * 0.105;
    double m_ll = m * 0.19;
    double m_rl = m * 0.19;
    double m_tr = m * 0.41;

    // -----------------------------
    // ✅ RESULT
    // -----------------------------
    return {
      "bmi": bmi,
      "bodyFat": bodyFat,
      "subcutaneousFat": subcutaneousFat,
      "visceralFat": visceralFat,
      "water": water,

      // 🔥 главное
      "bodyMuscle": bodyMuscle,
      "bodyMusclePercent": bodyMusclePercent,

      "skeletalMuscle": skeletalMuscle,
      "skeletalMusclePercent": skeletalMusclePercent,

      "muscle": muscle,
      "leanMass": leanMassPercent,

      "protein": protein,
      "boneMass": boneMass,
      "bmr": bmr,

      "bodyAge": bodyAge,
      "bodyHealth": bodyHealth,

      "m_la": m_la,
      "m_ra": m_ra,
      "m_ll": m_ll,
      "m_rl": m_rl,
      "m_tr": m_tr,
    };
  }
}
