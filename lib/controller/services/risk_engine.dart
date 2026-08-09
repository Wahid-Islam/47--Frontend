import '../../model/insights.dart';
import '../../model/profile.dart';
import 'dosm_data.dart';
import 'recommendation_engine.dart';

/// Client-side port of `backend/src/services/riskEngine.js`.
///
/// Runs entirely on-device so the mobile app no longer needs the
/// Express/Mongo API: [compute] takes a [Profile] and returns the same
/// shape of insights payload the old backend produced, ready to be
/// persisted into `public.insights.payload`.
class RiskEngine {
  RiskEngine._();

  static const Map<String, double> _activityMod = {'low': 1.25, 'moderate': 1.0, 'high': 0.82};
  static const Map<String, double> _dietMod = {'unhealthy': 1.22, 'average': 1.0, 'healthy': 0.85};

  static const String _disclaimer =
      'MySihat provides population-based statistical insights for education and prevention planning. '
      'It is not a medical diagnosis or clinical advice.';
  static const String _disclaimerBm =
      'MySihat menyediakan pandangan statistik berasaskan populasi untuk pendidikan dan perancangan '
      'pencegahan. Ia bukan diagnosis perubatan atau nasihat klinikal.';

  static String _impactLabel(double score) {
    if (score >= 0.28) return 'high';
    if (score >= 0.16) return 'medium';
    return 'low';
  }

  static String _overallLabel(double score) {
    if (score >= 0.32) return 'high';
    if (score >= 0.18) return 'moderate';
    return 'low';
  }

  static Insights compute(Profile profile) {
    final age = profile.age;
    final gender = profile.gender == 'female' ? 'female' : 'male';
    final activity = profile.activityLevel;
    final diet = profile.dietHabit;
    final smoking = profile.smoking;
    final bmi = profile.bmi;
    final highBp = profile.highBloodPressure;

    final alcohol = profile.alcohol;
    final sleepHours = profile.sleepHours;

    final lifestyleMultiplier =
        (_activityMod[activity] ?? 1.0) *
        (_dietMod[diet] ?? 1.0) *
        (smoking ? 1.35 : 1.0) *
        (bmi >= 30 ? 1.2 : (bmi >= 25 ? 1.1 : 1.0)) *
        (highBp ? 1.18 : 1.0) *
        (alcohol == 'regular' ? 1.15 : alcohol == 'occasional' ? 1.05 : 1.0) *
        (sleepHours < 6 ? 1.12 : sleepHours < 7 ? 1.05 : sleepHours > 9 ? 1.04 : 1.0);

    final risks = DosmData.causes.map((cause) {
      final base = DosmData.baselineRate(cause.id, gender, age);
      final personal = (base * lifestyleMultiplier).clamp(0.03, 0.75);
      return RiskItem(
        id: cause.id,
        name: cause.name,
        nameBm: cause.nameBm,
        nationalAverage: (base * 1000).round() / 10,
        personalRisk: (personal * 1000).round() / 10,
        level: _impactLabel(personal),
        deltaVsPeers: ((personal - base) * 1000).round() / 10,
      );
    }).toList()..sort((a, b) => b.personalRisk.compareTo(a.personalRisk));

    final topRisk = risks.first;
    final overallScore = risks.fold<double>(0, (sum, r) => sum + r.personalRisk) / risks.length / 100;

    var healthAgeOffset = 0;
    if (activity == 'low') healthAgeOffset += 3;
    if (activity == 'high') healthAgeOffset -= 2;
    if (diet == 'unhealthy') healthAgeOffset += 2;
    if (diet == 'healthy') healthAgeOffset -= 1;
    if (smoking) healthAgeOffset += 5;
    if (bmi >= 30) {
      healthAgeOffset += 3;
    } else if (bmi >= 25) {
      healthAgeOffset += 1;
    }
    if (highBp) healthAgeOffset += 2;
    if (alcohol == 'regular') {
      healthAgeOffset += 3;
    } else if (alcohol == 'occasional') {
      healthAgeOffset += 1;
    }
    if (sleepHours < 6) {
      healthAgeOffset += 2;
    } else if (sleepHours < 7) {
      healthAgeOffset += 1;
    } else if (sleepHours > 9) {
      healthAgeOffset += 1;
    }
    healthAgeOffset += ((topRisk.personalRisk - topRisk.nationalAverage) / 4).round();

    final healthAge = (age + healthAgeOffset).clamp(age - 8, age + 15).toInt();
    final lifeExpectancy = DosmData.nationalLifeExpectancy[gender] ?? 75.0;

    final factors = <RiskFactor>[
      RiskFactor(
        id: 'physical_inactivity',
        label: 'Physical Inactivity',
        labelBm: 'Kurang Aktiviti Fizikal',
        impact: activity == 'low'
            ? 'high'
            : activity == 'moderate'
            ? 'medium'
            : 'low',
        score: activity == 'low'
            ? 0.85
            : activity == 'moderate'
            ? 0.45
            : 0.15,
      ),
      RiskFactor(
        id: 'blood_pressure',
        label: 'High Blood Pressure',
        labelBm: 'Tekanan Darah Tinggi',
        impact: highBp ? 'high' : 'low',
        score: highBp ? 0.8 : 0.2,
      ),
      RiskFactor(
        id: 'age_factor',
        label: 'Age Factor',
        labelBm: 'Faktor Umur',
        impact: age >= 55
            ? 'high'
            : age >= 45
            ? 'medium'
            : 'low',
        score: ((age - 35) / 35).clamp(0.1, 0.95).toDouble(),
      ),
      RiskFactor(
        id: 'bmi',
        label: 'BMI',
        labelBm: 'BMI',
        impact: bmi >= 30
            ? 'high'
            : bmi >= 25
            ? 'medium'
            : 'low',
        score: ((bmi - 18) / 20).clamp(0.1, 0.95).toDouble(),
      ),
      RiskFactor(
        id: 'smoking',
        label: 'Smoking',
        labelBm: 'Merokok',
        impact: smoking ? 'high' : 'low',
        score: smoking ? 0.9 : 0.1,
      ),
      RiskFactor(
        id: 'diet',
        label: 'Dietary Habits',
        labelBm: 'Tabiat Pemakanan',
        impact: diet == 'unhealthy'
            ? 'high'
            : diet == 'average'
            ? 'medium'
            : 'low',
        score: diet == 'unhealthy'
            ? 0.8
            : diet == 'average'
            ? 0.45
            : 0.2,
      ),
      RiskFactor(
        id: 'alcohol',
        label: 'Alcohol',
        labelBm: 'Alkohol',
        impact: alcohol == 'regular'
            ? 'high'
            : alcohol == 'occasional'
            ? 'medium'
            : 'low',
        score: alcohol == 'regular'
            ? 0.75
            : alcohol == 'occasional'
            ? 0.4
            : 0.1,
      ),
      RiskFactor(
        id: 'sleep',
        label: 'Sleep',
        labelBm: 'Tidur',
        impact: sleepHours < 6 || sleepHours > 9
            ? 'high'
            : sleepHours < 7
            ? 'medium'
            : 'low',
        score: sleepHours < 6
            ? 0.8
            : sleepHours < 7
            ? 0.5
            : sleepHours > 9
            ? 0.55
            : 0.2,
      ),
    ]..sort((a, b) => b.score.compareTo(a.score));

    final peerComparison = _buildPeerText(topRisk, gender, age);
    final peerComparisonBm = _buildPeerTextBm(topRisk, gender, age);

    final rankedActions = RecommendationEngine.rankActions(profile: profile, risks: risks).take(3).toList();
    final daySeed = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final habitRecs = RecommendationEngine.recommendDailyHabits(
      profile: profile,
      risks: risks,
      daySeed: daySeed,
    );
    final habits = habitRecs.map((r) => r.habit).toList();

    // MVP demographic baseline: the average-lifestyle peer in the same
    // chronological age band has a Health Age close to their actual age,
    // so the peer/national average Health Age defaults to `age`.
    final peerAverageHealthAge = age;
    final healthAgeDelta = healthAge - age;
    // Following the plan moves Health Age down toward chronological age
    // (never pretending to go younger than actual age in the 12‑month view).
    final projectedHealthAgeFollowPlan = healthAge > age ? age : healthAge;
    final projectedHealthAgeNoChange = (healthAge + 8 < age + 15 ? healthAge + 8 : age + 15);

    final nationalComparisonHeadline = _buildNationalHeadline(
      healthAge,
      peerAverageHealthAge,
      topRisk,
      gender: gender,
      isBm: false,
    );
    final nationalComparisonHeadlineBm = _buildNationalHeadline(
      healthAge,
      peerAverageHealthAge,
      topRisk,
      gender: gender,
      isBm: true,
    );

    return Insights(
      disclaimer: _disclaimer,
      disclaimerBm: _disclaimerBm,
      actualAge: age,
      healthAge: healthAge,
      lifeExpectancy: lifeExpectancy,
      overallRiskLevel: _overallLabel(overallScore),
      overallRiskScore: (overallScore * 100).round(),
      topRisk: topRisk,
      risks: risks,
      factors: factors,
      peerComparison: peerComparison,
      peerComparisonBm: peerComparisonBm,
      topActions: rankedActions,
      habits: habits,
      generatedAt: DateTime.now().toUtc(),
      peerAverageHealthAge: peerAverageHealthAge,
      healthAgeDelta: healthAgeDelta,
      projectedHealthAgeFollowPlan: projectedHealthAgeFollowPlan,
      projectedHealthAgeNoChange: projectedHealthAgeNoChange,
      nationalComparisonHeadline: nationalComparisonHeadline,
      nationalComparisonHeadlineBm: nationalComparisonHeadlineBm,
    );
  }

  static String _buildNationalHeadline(
    int healthAge,
    int peerAverageHealthAge,
    RiskItem topRisk, {
    required String gender,
    required bool isBm,
  }) {
    final delta = healthAge - peerAverageHealthAge;
    if (isBm) {
      final sex = gender == 'female' ? 'wanita' : 'lelaki';
      final relation = delta > 0
          ? '$delta tahun lebih tinggi daripada'
          : delta < 0
          ? '${delta.abs()} tahun lebih rendah daripada'
          : 'sama dengan';
      return 'Umur Kesihatan anda ($healthAge) adalah $relation purata kebangsaan ($peerAverageHealthAge) untuk $sex '
          'seusia anda. Risiko utama anda, ${topRisk.nameBm.toLowerCase()}, ialah ${topRisk.personalRisk}% '
          'berbanding purata kebangsaan ${topRisk.nationalAverage}%.';
    }
    final sex = gender == 'female' ? 'women' : 'men';
    final relation = delta > 0
        ? '$delta years higher than'
        : delta < 0
        ? '${delta.abs()} years lower than'
        : 'in line with';
    return 'Your Health Age ($healthAge) is $relation the national average ($peerAverageHealthAge) for $sex your age. '
        'Your top risk, ${topRisk.name.toLowerCase()}, sits at ${topRisk.personalRisk}% vs a national average of '
        '${topRisk.nationalAverage}%.';
  }

  static String _buildPeerText(RiskItem topRisk, String gender, int age) {
    final sex = gender == 'female' ? 'women' : 'men';
    final direction = topRisk.deltaVsPeers >= 0 ? 'higher' : 'lower';
    final abs = topRisk.deltaVsPeers.abs();
    final bandStart = (age ~/ 10) * 10;
    return 'Compared with other Malaysian $sex aged $bandStart-${bandStart + 9}, your estimated '
        '${topRisk.name.toLowerCase()} risk is about $abs percentage points $direction than the demographic '
        'average (${topRisk.nationalAverage}%).';
  }

  static String _buildPeerTextBm(RiskItem topRisk, String gender, int age) {
    final sex = gender == 'female' ? 'wanita' : 'lelaki';
    final direction = topRisk.deltaVsPeers >= 0 ? 'lebih tinggi' : 'lebih rendah';
    final abs = topRisk.deltaVsPeers.abs();
    final bandStart = (age ~/ 10) * 10;
    return 'Berbanding $sex Malaysia lain berumur $bandStart-${bandStart + 9}, anggaran risiko '
        '${topRisk.nameBm.toLowerCase()} anda kira-kira $abs mata peratusan $direction daripada purata '
        'demografi (${topRisk.nationalAverage}%).';
  }

}

