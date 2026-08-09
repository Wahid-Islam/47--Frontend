import 'package:equatable/equatable.dart';

/// Immutable domain model mirroring the `public.profiles` table.
///
/// Column names in Postgres are snake_case; [fromJson]/[toJson] translate
/// between that wire format and this Dart model by hand (no code
/// generation), as required for the MVC "Model" layer.
class Profile extends Equatable {
  const Profile({
    required this.id,
    this.email,
    this.fullName = '',
    this.age = 48,
    this.gender = 'male',
    this.state = 'Wilayah Persekutuan Kuala Lumpur',
    this.activityLevel = 'moderate',
    this.dietHabit = 'average',
    this.smoking = false,
    this.heightCm = 170,
    this.weightKg = 70,
    this.bmi = 24,
    this.alcohol = 'none',
    this.sleepHours = 7,
    this.highBloodPressure = false,
    this.onboardingComplete = false,
    this.locale = 'en',
    this.activeActionIds = const [],
  });

  final String id;
  final String? email;
  final String fullName;
  final int age;
  final String gender; // male | female | other
  final String state;
  final String activityLevel; // low | moderate | high
  final String dietHabit; // unhealthy | average | healthy
  final bool smoking;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final String alcohol; // none | occasional | regular
  final double sleepHours;
  final bool highBloodPressure;
  final bool onboardingComplete;
  final String locale; // en | bm
  final List<String> activeActionIds;

  /// BMI from height (cm) and weight (kg). Returns null when inputs are unusable.
  static double? bmiFromHeightWeight(double heightCm, double weightKg) {
    if (heightCm <= 0 || weightKg <= 0) return null;
    final metres = heightCm / 100;
    return weightKg / (metres * metres);
  }

  factory Profile.empty(String id, {String? email}) => Profile(id: id, email: email);

  /// Seed profile used by the "Try demo" flow: Lim Wei Jian, 48, low
  /// activity, unhealthy diet, smoker, BMI ~27.4.
  factory Profile.demo(String id, {String? email}) => Profile(
    id: id,
    email: email ?? 'lim.weijian@healthpath.demo',
    fullName: 'Lim Wei Jian',
    age: 48,
    gender: 'male',
    state: 'Wilayah Persekutuan Kuala Lumpur',
    activityLevel: 'low',
    dietHabit: 'unhealthy',
    smoking: true,
    heightCm: 170,
    weightKg: 79.2,
    bmi: 27.4,
    alcohol: 'occasional',
    sleepHours: 5.5,
    highBloodPressure: true,
    onboardingComplete: true,
    locale: 'en',
    activeActionIds: const ['bp_screening', 'walk_20', 'swap_drinks'],
  );

  factory Profile.fromJson(Map<String, dynamic> json) {
    final height = (json['height_cm'] as num?)?.toDouble() ?? 170;
    final weight = (json['weight_kg'] as num?)?.toDouble() ?? 70;
    final storedBmi = (json['bmi'] as num?)?.toDouble();
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name']?.toString() ?? '',
      age: (json['age'] as num?)?.toInt() ?? 48,
      gender: json['gender']?.toString() ?? 'male',
      state: json['state']?.toString() ?? 'Wilayah Persekutuan Kuala Lumpur',
      activityLevel: json['activity_level']?.toString() ?? 'moderate',
      dietHabit: json['diet_habit']?.toString() ?? 'average',
      smoking: json['smoking'] as bool? ?? false,
      heightCm: height,
      weightKg: weight,
      bmi: storedBmi ?? bmiFromHeightWeight(height, weight) ?? 24,
      alcohol: json['alcohol']?.toString() ?? 'none',
      sleepHours: (json['sleep_hours'] as num?)?.toDouble() ?? 7,
      highBloodPressure: json['high_blood_pressure'] as bool? ?? false,
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      locale: json['locale']?.toString() ?? 'en',
      activeActionIds: (json['active_action_ids'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'state': state,
      'activity_level': activityLevel,
      'diet_habit': dietHabit,
      'smoking': smoking,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi': bmi,
      'alcohol': alcohol,
      'sleep_hours': sleepHours,
      'high_blood_pressure': highBloodPressure,
      'onboarding_complete': onboardingComplete,
      'locale': locale,
      'active_action_ids': activeActionIds,
    };
  }

  Profile copyWith({
    String? id,
    String? email,
    String? fullName,
    int? age,
    String? gender,
    String? state,
    String? activityLevel,
    String? dietHabit,
    bool? smoking,
    double? heightCm,
    double? weightKg,
    double? bmi,
    String? alcohol,
    double? sleepHours,
    bool? highBloodPressure,
    bool? onboardingComplete,
    String? locale,
    List<String>? activeActionIds,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      state: state ?? this.state,
      activityLevel: activityLevel ?? this.activityLevel,
      dietHabit: dietHabit ?? this.dietHabit,
      smoking: smoking ?? this.smoking,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmi: bmi ?? this.bmi,
      alcohol: alcohol ?? this.alcohol,
      sleepHours: sleepHours ?? this.sleepHours,
      highBloodPressure: highBloodPressure ?? this.highBloodPressure,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      locale: locale ?? this.locale,
      activeActionIds: activeActionIds ?? this.activeActionIds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    age,
    gender,
    state,
    activityLevel,
    dietHabit,
    smoking,
    heightCm,
    weightKg,
    bmi,
    alcohol,
    sleepHours,
    highBloodPressure,
    onboardingComplete,
    locale,
    activeActionIds,
  ];
}
