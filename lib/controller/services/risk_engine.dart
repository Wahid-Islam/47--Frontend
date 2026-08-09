import '../../model/insights.dart';
import '../../model/profile.dart';
import 'dosm_data.dart';
import 'health_age/health_age_model.dart';
import 'recommendation_engine.dart';

/// On-device insights engine.
///
/// Health Age follows the Model v1.0 mortality-equivalence specification
/// (log-risk index × Malaysian `nmx` baseline → equivalent age).
/// Cause-of-death cards remain educational DOSM-inspired illustrations
/// scaled by the same relative risk index.
class RiskEngine {
  RiskEngine._();

  static const String _disclaimer =
      'MySihat provides educational, population-based Health Age estimates using '
      'your reported lifestyle and Malaysian mortality data. It is not a medical '
      'diagnosis, biological-age measurement, or prediction of individual lifespan.';
  static const String _disclaimerBm =
      'MySihat menyediakan anggaran Umur Kesihatan berasaskan populasi untuk '
      'pendidikan menggunakan gaya hidup yang anda laporkan dan data kematian Malaysia. '
      'Ia bukan diagnosis perubatan, ukuran umur biologi, atau ramalan jangka hayat individu.';

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
    final health = HealthAgeModel.calculate(profile);
    final relativeRisk = health.riskIndex;

    final risks = DosmData.causes.map((cause) {
      final base = DosmData.baselineRate(cause.id, gender, age);
      final personal = (base * relativeRisk).clamp(0.03, 0.75);
      return RiskItem(
        id: cause.id,
        name: cause.name,
        nameBm: cause.nameBm,
        nationalAverage: (base * 1000).round() / 10,
        personalRisk: (personal * 1000).round() / 10,
        level: _impactLabel(personal),
        deltaVsPeers: ((personal - base) * 1000).round() / 10,
      );
    }).toList()
      ..sort((a, b) => b.personalRisk.compareTo(a.personalRisk));

    final topRisk = risks.first;
    final overallScore = risks.fold<double>(0, (sum, r) => sum + r.personalRisk) / risks.length / 100;

    final factors = health.factorContributions
        .where((f) => f.id != 'diabetes' || f.multiplier > 1.0)
        .map(
          (f) => RiskFactor(
            id: f.id,
            label: f.label,
            labelBm: f.labelBm,
            impact: f.impact,
            score: f.score,
          ),
        )
        .toList();

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

    final peerAverageHealthAge = age;
    final healthAge = health.healthAge;
    final healthAgeDelta = health.healthAgeDifference;
    final projectedHealthAgeFollowPlan = healthAge > age ? age : healthAge;
    final projectedHealthAgeNoChange = (healthAge + 8 < age + 15 ? healthAge + 8 : age + 15);

    final lifeExpectancy = DosmData.nationalLifeExpectancy[gender] ?? 75.0;

    final nationalComparisonHeadline = _buildNationalHeadline(
      healthAge,
      peerAverageHealthAge,
      topRisk,
      gender: gender,
      isBm: false,
      riskIndex: relativeRisk,
      lifestyleScore: health.lifestyleScore,
    );
    final nationalComparisonHeadlineBm = _buildNationalHeadline(
      healthAge,
      peerAverageHealthAge,
      topRisk,
      gender: gender,
      isBm: true,
      riskIndex: relativeRisk,
      lifestyleScore: health.lifestyleScore,
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
    required double riskIndex,
    required double lifestyleScore,
  }) {
    final delta = healthAge - peerAverageHealthAge;
    if (isBm) {
      final sex = gender == 'female' ? 'wanita' : 'lelaki';
      final relation = delta > 0
          ? '$delta tahun lebih tinggi daripada'
          : delta < 0
          ? '${delta.abs()} tahun lebih rendah daripada'
          : 'sama dengan';
      return 'Umur Kesihatan anda ($healthAge) adalah $relation umur sebenar ($peerAverageHealthAge) untuk $sex '
          'seusia anda. Indeks risiko terlaras model ialah ${riskIndex.toStringAsFixed(2)} '
          '(skor gaya hidup ${lifestyleScore.round()}/100). Risiko utama, ${topRisk.nameBm.toLowerCase()}, '
          'ialah ${topRisk.personalRisk}% berbanding purata ${topRisk.nationalAverage}%.';
    }
    final sex = gender == 'female' ? 'women' : 'men';
    final relation = delta > 0
        ? '$delta years higher than'
        : delta < 0
        ? '${delta.abs()} years lower than'
        : 'in line with';
    return 'Your Health Age ($healthAge) is $relation your chronological age ($peerAverageHealthAge) for $sex your age. '
        'The model’s adjusted risk index is ${riskIndex.toStringAsFixed(2)} '
        '(lifestyle score ${lifestyleScore.round()}/100). Your top illustrated risk, '
        '${topRisk.name.toLowerCase()}, sits at ${topRisk.personalRisk}% vs ${topRisk.nationalAverage}%.';
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
