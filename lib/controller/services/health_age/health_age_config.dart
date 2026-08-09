/// Prototype Health Age coefficients (Model v1.0).
///
/// These multipliers are **configurable development parameters**, not
/// published clinical hazard ratios. Keep them here — never scatter magic
/// numbers through the calculation logic.
class HealthAgeConfig {
  const HealthAgeConfig._();

  static const String modelVersion = '1.0';
  static const String mortalityDataset = 'DOSM Abridged Life Tables Malaysia 2023';
  static const String mortalityVersion = '2023';

  /// UX/model safeguards (PDF §29).
  static const int minAgeDelta = -10;
  static const int maxAgeDelta = 15;

  /// Relative-risk clamp (PDF §20).
  /// Floor kept closer to 1 so protective lifestyles stay near chronological age
  /// (PDF Test 1: healthy reference must not produce an extreme younger age).
  static const double minRelativeRisk = 0.70;
  static const double maxRelativeRisk = 3.50;

  static const Map<String, double> smoking = {
    'never': 1.00,
    'former': 1.20,
    'current': 2.00,
  };

  static const Map<String, double> physicalActivity = {
    'rarely': 1.00,
    'sometimes': 0.75,
    'often': 0.55,
    'veryOften': 0.45,
  };

  static const Map<String, double> diet = {
    'poor': 1.00,
    'moderate': 0.85,
    'healthy': 0.70,
  };

  static const Map<String, double> alcohol = {
    'never': 1.00,
    'rarely': 1.00,
    'socially': 1.02,
    'frequently': 1.15,
  };

  static const Map<String, double> hypertension = {
    'no': 1.00,
    'yes': 1.15,
  };

  static const Map<String, double> diabetes = {
    'no': 1.00,
    'yes': 1.25,
  };

  static const Map<String, double> sleep = {
    'lessThan6': 1.12,
    'sixToSeven': 1.03,
    'sevenToEight': 1.00,
    'eightPlus': 1.08,
  };

  /// Correlation dampening in log-risk space (PDF §19).
  static const double correlationPairFactor = 0.90;
  static const double correlationTripleFactor = 0.80;

  // Lifestyle score component weights (PDF §33) — sum to 1.0.
  static const double lifestyleWeightSmoking = 0.30;
  static const double lifestyleWeightActivity = 0.20;
  static const double lifestyleWeightDiet = 0.15;
  static const double lifestyleWeightBmi = 0.15;
  static const double lifestyleWeightSleep = 0.10;
  static const double lifestyleWeightAlcohol = 0.10;

  static const Map<String, double> lifestyleSmokingScore = {
    'never': 100,
    'former': 60,
    'current': 0,
  };

  static const Map<String, double> lifestyleActivityScore = {
    'rarely': 0,
    'sometimes': 50,
    'often': 80,
    'veryOften': 100,
  };

  static const Map<String, double> lifestyleDietScore = {
    'poor': 0,
    'moderate': 60,
    'healthy': 100,
  };

  static const Map<String, double> lifestyleAlcoholScore = {
    'never': 100,
    'rarely': 100,
    'socially': 95,
    'frequently': 65,
  };

  static const Map<String, double> lifestyleSleepScore = {
    'lessThan6': 40,
    'sixToSeven': 85,
    'sevenToEight': 100,
    'eightPlus': 75,
  };

  static double bmiMultiplier(double bmi) {
    if (bmi < 18.5) return 1.05;
    if (bmi < 25) return 1.00;
    if (bmi < 30) return 1.05;
    if (bmi < 35) return 1.12;
    if (bmi < 40) return 1.18;
    return 1.25;
  }

  static double lifestyleBmiScore(double bmi) {
    if (bmi < 18.5) return 70;
    if (bmi < 25) return 100;
    if (bmi < 30) return 75;
    if (bmi < 35) return 50;
    if (bmi < 40) return 30;
    return 10;
  }
}
