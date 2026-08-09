import 'dart:math' as math;

import '../../../model/profile.dart';
import 'health_age_config.dart';
import 'malaysia_mortality.dart';

class FactorContribution {
  const FactorContribution({
    required this.id,
    required this.label,
    required this.labelBm,
    required this.multiplier,
    required this.logContribution,
  });

  final String id;
  final String label;
  final String labelBm;
  final double multiplier;

  /// Absolute log contribution used for ranking explainability.
  final double logContribution;

  double get score => (logContribution.abs() / math.log(2.5)).clamp(0.05, 1.0);

  String get impact {
    if (multiplier >= 1.15 || logContribution >= math.log(1.12)) return 'high';
    if (multiplier >= 1.03 || logContribution >= math.log(1.03)) return 'medium';
    return 'low';
  }
}

class HealthAgeResult {
  const HealthAgeResult({
    required this.chronologicalAge,
    required this.sex,
    required this.bmi,
    required this.riskIndex,
    required this.baselineMortality,
    required this.adjustedMortality,
    required this.equivalentAge,
    required this.healthAge,
    required this.healthAgeDifference,
    required this.lifestyleScore,
    required this.lifestyleLabel,
    required this.factorContributions,
    required this.modelVersion,
    required this.mortalityDataset,
  });

  final int chronologicalAge;
  final String sex;
  final double bmi;
  final double riskIndex;
  final double baselineMortality;
  final double adjustedMortality;
  final double equivalentAge;
  final int healthAge;
  final int healthAgeDifference;
  final double lifestyleScore;
  final String lifestyleLabel;
  final List<FactorContribution> factorContributions;
  final String modelVersion;
  final String mortalityDataset;
}

/// Mortality-equivalence Health Age engine (PDF Model v1.0).
class HealthAgeModel {
  HealthAgeModel._();

  static HealthAgeResult calculate(Profile profile) {
    final age = profile.age.clamp(18, 100);
    final sex = profile.gender == 'female' ? 'female' : 'male';
    final bmi = profile.bmi > 0
        ? profile.bmi
        : (Profile.bmiFromHeightWeight(profile.heightCm, profile.weightKg) ?? 24);

    final smokingKey = profile.smoking ? 'current' : 'never';
    final activityKey = _mapActivity(profile.activityLevel);
    final dietKey = _mapDiet(profile.dietHabit);
    final alcoholKey = _mapAlcohol(profile.alcohol);
    final sleepKey = _mapSleep(profile.sleepHours);
    final hypertension = profile.highBloodPressure;
    final diabetes = profile.diabetes;

    final multipliers = <String, double>{
      'smoking': HealthAgeConfig.smoking[smokingKey]!,
      'physical_inactivity': HealthAgeConfig.physicalActivity[activityKey]!,
      'diet': HealthAgeConfig.diet[dietKey]!,
      'alcohol': HealthAgeConfig.alcohol[alcoholKey]!,
      'bmi': HealthAgeConfig.bmiMultiplier(bmi),
      'sleep': HealthAgeConfig.sleep[sleepKey]!,
      'blood_pressure': HealthAgeConfig.hypertension[hypertension ? 'yes' : 'no']!,
      'diabetes': HealthAgeConfig.diabetes[diabetes ? 'yes' : 'no']!,
    };

    var rawLogRisk = 0.0;
    final logs = <String, double>{};
    for (final entry in multipliers.entries) {
      final logValue = math.log(entry.value);
      logs[entry.key] = logValue;
      rawLogRisk += logValue;
    }

    var adjustedLogRisk = rawLogRisk;
    final obese = bmi >= 30;
    if (obese && hypertension) {
      adjustedLogRisk *= HealthAgeConfig.correlationPairFactor;
    }
    if (obese && diabetes) {
      adjustedLogRisk *= HealthAgeConfig.correlationPairFactor;
    }
    if (hypertension && diabetes) {
      adjustedLogRisk *= HealthAgeConfig.correlationPairFactor;
    }
    if (obese && hypertension && diabetes) {
      adjustedLogRisk *= HealthAgeConfig.correlationTripleFactor;
    }

    var relativeRisk = math.exp(adjustedLogRisk);
    relativeRisk = relativeRisk.clamp(
      HealthAgeConfig.minRelativeRisk,
      HealthAgeConfig.maxRelativeRisk,
    );

    final baselineMortality = MalaysiaMortality.mortality(age, sex);
    final targetMortality = baselineMortality * relativeRisk;
    final equivalentAge = MalaysiaMortality.findEquivalentAge(
      targetMortality: targetMortality,
      sex: sex,
    );

    final bounded = equivalentAge.clamp(
      (age + HealthAgeConfig.minAgeDelta).toDouble(),
      (age + HealthAgeConfig.maxAgeDelta).toDouble(),
    );
    final healthAge = bounded.round();
    final healthAgeDifference = healthAge - age;

    final lifestyleScore = _lifestyleScore(
      smokingKey: smokingKey,
      activityKey: activityKey,
      dietKey: dietKey,
      alcoholKey: alcoholKey,
      sleepKey: sleepKey,
      bmi: bmi,
    );

    final contributions = [
      FactorContribution(
        id: 'smoking',
        label: 'Smoking',
        labelBm: 'Merokok',
        multiplier: multipliers['smoking']!,
        logContribution: logs['smoking']!,
      ),
      FactorContribution(
        id: 'physical_inactivity',
        label: 'Physical Inactivity',
        labelBm: 'Kurang Aktiviti Fizikal',
        multiplier: multipliers['physical_inactivity']!,
        logContribution: logs['physical_inactivity']!,
      ),
      FactorContribution(
        id: 'diet',
        label: 'Dietary Habits',
        labelBm: 'Tabiat Pemakanan',
        multiplier: multipliers['diet']!,
        logContribution: logs['diet']!,
      ),
      FactorContribution(
        id: 'bmi',
        label: 'BMI',
        labelBm: 'BMI',
        multiplier: multipliers['bmi']!,
        logContribution: logs['bmi']!,
      ),
      FactorContribution(
        id: 'alcohol',
        label: 'Alcohol',
        labelBm: 'Alkohol',
        multiplier: multipliers['alcohol']!,
        logContribution: logs['alcohol']!,
      ),
      FactorContribution(
        id: 'sleep',
        label: 'Sleep',
        labelBm: 'Tidur',
        multiplier: multipliers['sleep']!,
        logContribution: logs['sleep']!,
      ),
      FactorContribution(
        id: 'blood_pressure',
        label: 'High Blood Pressure',
        labelBm: 'Tekanan Darah Tinggi',
        multiplier: multipliers['blood_pressure']!,
        logContribution: logs['blood_pressure']!,
      ),
      FactorContribution(
        id: 'diabetes',
        label: 'Diabetes',
        labelBm: 'Diabetes',
        multiplier: multipliers['diabetes']!,
        logContribution: logs['diabetes']!,
      ),
    ]..sort((a, b) => b.logContribution.compareTo(a.logContribution));

    return HealthAgeResult(
      chronologicalAge: age,
      sex: sex,
      bmi: bmi,
      riskIndex: relativeRisk,
      baselineMortality: baselineMortality,
      adjustedMortality: targetMortality,
      equivalentAge: equivalentAge,
      healthAge: healthAge,
      healthAgeDifference: healthAgeDifference,
      lifestyleScore: lifestyleScore,
      lifestyleLabel: _lifestyleLabel(lifestyleScore),
      factorContributions: contributions,
      modelVersion: HealthAgeConfig.modelVersion,
      mortalityDataset: HealthAgeConfig.mortalityDataset,
    );
  }

  static String _mapActivity(String value) {
    switch (value) {
      case 'low':
        return 'rarely';
      case 'high':
        return 'often';
      case 'very_high':
      case 'veryOften':
        return 'veryOften';
      default:
        return 'sometimes';
    }
  }

  static String _mapDiet(String value) {
    switch (value) {
      case 'unhealthy':
      case 'poor':
        return 'poor';
      case 'healthy':
        return 'healthy';
      default:
        return 'moderate';
    }
  }

  static String _mapAlcohol(String value) {
    switch (value) {
      case 'regular':
      case 'frequently':
        return 'frequently';
      case 'occasional':
      case 'socially':
        return 'socially';
      case 'rarely':
        return 'rarely';
      default:
        return 'never';
    }
  }

  static String _mapSleep(double hours) {
    if (hours < 6) return 'lessThan6';
    if (hours < 7) return 'sixToSeven';
    if (hours <= 8) return 'sevenToEight';
    return 'eightPlus';
  }

  static double _lifestyleScore({
    required String smokingKey,
    required String activityKey,
    required String dietKey,
    required String alcoholKey,
    required String sleepKey,
    required double bmi,
  }) {
    final score =
        (HealthAgeConfig.lifestyleSmokingScore[smokingKey]! * HealthAgeConfig.lifestyleWeightSmoking) +
        (HealthAgeConfig.lifestyleActivityScore[activityKey]! * HealthAgeConfig.lifestyleWeightActivity) +
        (HealthAgeConfig.lifestyleDietScore[dietKey]! * HealthAgeConfig.lifestyleWeightDiet) +
        (HealthAgeConfig.lifestyleBmiScore(bmi) * HealthAgeConfig.lifestyleWeightBmi) +
        (HealthAgeConfig.lifestyleSleepScore[sleepKey]! * HealthAgeConfig.lifestyleWeightSleep) +
        (HealthAgeConfig.lifestyleAlcoholScore[alcoholKey]! * HealthAgeConfig.lifestyleWeightAlcohol);
    return score.clamp(0, 100);
  }

  static String _lifestyleLabel(double score) {
    if (score < 40) return 'Needs significant improvement';
    if (score < 60) return 'Needs improvement';
    if (score < 75) return 'Fair';
    if (score < 90) return 'Good';
    return 'Excellent';
  }
}
