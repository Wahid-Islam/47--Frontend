import 'dart:math' as math;

/// Absolute adult ranges plus BMI-derived dynamic bounds for height/weight.
class BodyMeasures {
  BodyMeasures._();

  static const double minHeightCm = 120;
  static const double maxHeightCm = 220;
  static const double minWeightKg = 35;
  static const double maxWeightKg = 200;
  static const double minBmi = 10;
  static const double maxBmi = 60;

  static double bmi(double heightCm, double weightKg) {
    final metres = heightCm / 100;
    return weightKg / (metres * metres);
  }

  static double roundBmi(double heightCm, double weightKg) =>
      (bmi(heightCm, weightKg) * 10).roundToDouble() / 10;

  /// Weight window for a given height: absolute range ∩ BMI 10–60.
  static ({double min, double max}) weightBoundsForHeight(double heightCm) {
    final h = heightCm.clamp(minHeightCm, maxHeightCm);
    final metres = h / 100;
    final m2 = metres * metres;
    final fromBmiMin = minBmi * m2;
    final fromBmiMax = maxBmi * m2;
    final min = math.max(minWeightKg, fromBmiMin);
    final max = math.min(maxWeightKg, fromBmiMax);
    if (min <= max) return (min: min, max: max);
    return (min: minWeightKg, max: maxWeightKg);
  }

  /// Height window for a given weight: absolute range ∩ BMI 10–60.
  static ({double min, double max}) heightBoundsForWeight(double weightKg) {
    final w = weightKg.clamp(minWeightKg, maxWeightKg);
    // BMI = w / (h/100)^2 → h = 100 * sqrt(w / bmi)
    final fromBmiMin = 100 * math.sqrt(w / maxBmi); // high BMI → shorter height
    final fromBmiMax = 100 * math.sqrt(w / minBmi);
    final min = math.max(minHeightCm, fromBmiMin);
    final max = math.min(maxHeightCm, fromBmiMax);
    if (min <= max) return (min: min, max: max);
    return (min: minHeightCm, max: maxHeightCm);
  }

  static bool isValidBody(double heightCm, double weightKg) {
    if (heightCm < minHeightCm || heightCm > maxHeightCm) return false;
    if (weightKg < minWeightKg || weightKg > maxWeightKg) return false;
    final value = bmi(heightCm, weightKg);
    return value >= minBmi && value <= maxBmi;
  }

  static double clampWeightForHeight(double heightCm, double weightKg) {
    final bounds = weightBoundsForHeight(heightCm);
    return weightKg.clamp(bounds.min, bounds.max);
  }

  static double clampHeightForWeight(double heightCm, double weightKg) {
    final bounds = heightBoundsForWeight(weightKg);
    return heightCm.clamp(bounds.min, bounds.max);
  }
}
