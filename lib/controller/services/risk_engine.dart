import '../../model/insights.dart';
import '../../model/profile.dart';
import 'dosm_data.dart';
import 'health_age/health_age_model.dart';
import 'recommendation_engine.dart';

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
  static const String _disclaimerZh =
      'MySihat 根据您报告的生活方式与马来西亚死亡数据，提供教育性的人群健康年龄估计。'
      '它不是医学诊断、生物年龄测量，也不是对个人寿命的预测。';

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
        nameZh: cause.nameZh,
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
            labelZh: f.labelZh,
            impact: f.impact,
            score: f.score,
          ),
        )
        .toList();

    final peerComparison = _buildPeerText(topRisk, gender, age, locale: 'en');
    final peerComparisonBm = _buildPeerText(topRisk, gender, age, locale: 'bm');
    final peerComparisonZh = _buildPeerText(topRisk, gender, age, locale: 'zh');

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
      locale: 'en',
      riskIndex: relativeRisk,
      lifestyleScore: health.lifestyleScore,
    );
    final nationalComparisonHeadlineBm = _buildNationalHeadline(
      healthAge,
      peerAverageHealthAge,
      topRisk,
      gender: gender,
      locale: 'bm',
      riskIndex: relativeRisk,
      lifestyleScore: health.lifestyleScore,
    );
    final nationalComparisonHeadlineZh = _buildNationalHeadline(
      healthAge,
      peerAverageHealthAge,
      topRisk,
      gender: gender,
      locale: 'zh',
      riskIndex: relativeRisk,
      lifestyleScore: health.lifestyleScore,
    );

    return Insights(
      disclaimer: _disclaimer,
      disclaimerBm: _disclaimerBm,
      disclaimerZh: _disclaimerZh,
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
      peerComparisonZh: peerComparisonZh,
      topActions: rankedActions,
      habits: habits,
      generatedAt: DateTime.now().toUtc(),
      peerAverageHealthAge: peerAverageHealthAge,
      healthAgeDelta: healthAgeDelta,
      projectedHealthAgeFollowPlan: projectedHealthAgeFollowPlan,
      projectedHealthAgeNoChange: projectedHealthAgeNoChange,
      nationalComparisonHeadline: nationalComparisonHeadline,
      nationalComparisonHeadlineBm: nationalComparisonHeadlineBm,
      nationalComparisonHeadlineZh: nationalComparisonHeadlineZh,
    );
  }

  static String _buildNationalHeadline(
    int healthAge,
    int peerAverageHealthAge,
    RiskItem topRisk, {
    required String gender,
    required String locale,
    required double riskIndex,
    required double lifestyleScore,
  }) {
    final delta = healthAge - peerAverageHealthAge;
    if (locale == 'bm') {
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
    if (locale == 'zh') {
      final sex = gender == 'female' ? '女性' : '男性';
      final relation = delta > 0
          ? '高出实际年龄 $delta 岁'
          : delta < 0
          ? '低于实际年龄 ${delta.abs()} 岁'
          : '与实际年龄一致';
      final riskName = topRisk.nameZh.isNotEmpty ? topRisk.nameZh : topRisk.name;
      return '您的健康年龄（$healthAge）相对同龄$sex的实际年龄（$peerAverageHealthAge）$relation。'
          '模型调整后风险指数为 ${riskIndex.toStringAsFixed(2)}'
          '（生活方式评分 ${lifestyleScore.round()}/100）。主要示意风险$riskName为 ${topRisk.personalRisk}%，'
          '对比平均 ${topRisk.nationalAverage}%。';
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

  static String _buildPeerText(RiskItem topRisk, String gender, int age, {required String locale}) {
    final bandStart = (age ~/ 10) * 10;
    final abs = topRisk.deltaVsPeers.abs();
    if (locale == 'bm') {
      final sex = gender == 'female' ? 'wanita' : 'lelaki';
      final direction = topRisk.deltaVsPeers >= 0 ? 'lebih tinggi' : 'lebih rendah';
      return 'Berbanding $sex Malaysia lain berumur $bandStart-${bandStart + 9}, anggaran risiko '
          '${topRisk.nameBm.toLowerCase()} anda kira-kira $abs mata peratusan $direction daripada purata '
          'demografi (${topRisk.nationalAverage}%).';
    }
    if (locale == 'zh') {
      final sex = gender == 'female' ? '女性' : '男性';
      final direction = topRisk.deltaVsPeers >= 0 ? '高于' : '低于';
      final riskName = topRisk.nameZh.isNotEmpty ? topRisk.nameZh : topRisk.name;
      return '与 $bandStart–${bandStart + 9} 岁的其他马来西亚$sex相比，您的$riskName估计风险约$direction人口平均 '
          '${topRisk.nationalAverage}% 约 $abs 个百分点。';
    }
    final sex = gender == 'female' ? 'women' : 'men';
    final direction = topRisk.deltaVsPeers >= 0 ? 'higher' : 'lower';
    return 'Compared with other Malaysian $sex aged $bandStart-${bandStart + 9}, your estimated '
        '${topRisk.name.toLowerCase()} risk is about $abs percentage points $direction than the demographic '
        'average (${topRisk.nationalAverage}%).';
  }
}
