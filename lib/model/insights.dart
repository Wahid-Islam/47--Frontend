import 'package:equatable/equatable.dart';

import '../core/l10n/localized.dart';
import 'action_item.dart';

class RiskItem extends Equatable {
  const RiskItem({
    required this.id,
    required this.name,
    required this.nameBm,
    required this.nationalAverage,
    required this.personalRisk,
    required this.level,
    required this.deltaVsPeers,
    this.nameZh = '',
  });

  final String id;
  final String name;
  final String nameBm;
  final String nameZh;
  final double nationalAverage;
  final double personalRisk;
  final String level; // low | medium | high
  final double deltaVsPeers;

  factory RiskItem.fromJson(Map<String, dynamic> json) {
    return RiskItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameBm: json['nameBm']?.toString() ?? json['name_bm']?.toString() ?? '',
      nameZh: json['nameZh']?.toString() ?? json['name_zh']?.toString() ?? '',
      nationalAverage:
          (json['nationalAverage'] as num?)?.toDouble() ??
          (json['national_average'] as num?)?.toDouble() ??
          0,
      personalRisk:
          (json['personalRisk'] as num?)?.toDouble() ?? (json['personal_risk'] as num?)?.toDouble() ?? 0,
      level: json['level']?.toString() ?? 'low',
      deltaVsPeers:
          (json['deltaVsPeers'] as num?)?.toDouble() ?? (json['delta_vs_peers'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameBm': nameBm,
      'nameZh': nameZh,
      'nationalAverage': nationalAverage,
      'personalRisk': personalRisk,
      'level': level,
      'deltaVsPeers': deltaVsPeers,
    };
  }

  String localizedName(String locale) =>
      localizedText(locale, en: name, bm: nameBm, zh: nameZh);

  @override
  List<Object?> get props => [id, name, nameBm, nameZh, nationalAverage, personalRisk, level, deltaVsPeers];
}

class RiskFactor extends Equatable {
  const RiskFactor({
    required this.id,
    required this.label,
    required this.labelBm,
    required this.impact,
    required this.score,
    this.labelZh = '',
  });

  final String id;
  final String label;
  final String labelBm;
  final String labelZh;
  final String impact; // low | medium | high
  final double score;

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      labelBm: json['labelBm']?.toString() ?? json['label_bm']?.toString() ?? '',
      labelZh: json['labelZh']?.toString() ?? json['label_zh']?.toString() ?? '',
      impact: json['impact']?.toString() ?? 'low',
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'labelBm': labelBm,
      'labelZh': labelZh,
      'impact': impact,
      'score': score,
    };
  }

  String localizedLabel(String locale) =>
      localizedText(locale, en: label, bm: labelBm, zh: labelZh);

  @override
  List<Object?> get props => [id, label, labelBm, labelZh, impact, score];
}

class Insights extends Equatable {
  const Insights({
    required this.disclaimer,
    required this.disclaimerBm,
    required this.actualAge,
    required this.healthAge,
    required this.lifeExpectancy,
    required this.overallRiskLevel,
    required this.overallRiskScore,
    required this.topRisk,
    required this.risks,
    required this.factors,
    required this.peerComparison,
    required this.peerComparisonBm,
    required this.topActions,
    required this.habits,
    required this.generatedAt,
    this.disclaimerZh = '',
    this.peerComparisonZh = '',
    this.peerAverageHealthAge = 0,
    this.healthAgeDelta = 0,
    this.projectedHealthAgeFollowPlan = 0,
    this.projectedHealthAgeNoChange = 0,
    this.nationalComparisonHeadline = '',
    this.nationalComparisonHeadlineBm = '',
    this.nationalComparisonHeadlineZh = '',
  });

  final String disclaimer;
  final String disclaimerBm;
  final String disclaimerZh;
  final int actualAge;
  final int healthAge;
  final double lifeExpectancy;
  final String overallRiskLevel; // low | moderate | high
  final int overallRiskScore;
  final RiskItem topRisk;
  final List<RiskItem> risks;
  final List<RiskFactor> factors;
  final String peerComparison;
  final String peerComparisonBm;
  final String peerComparisonZh;
  final List<ActionItem> topActions;
  final List<HabitCatalogItem> habits;
  final DateTime generatedAt;

  final int peerAverageHealthAge;

  final int healthAgeDelta;

  final int projectedHealthAgeFollowPlan;

  final int projectedHealthAgeNoChange;

  final String nationalComparisonHeadline;
  final String nationalComparisonHeadlineBm;
  final String nationalComparisonHeadlineZh;

  factory Insights.fromJson(Map<String, dynamic> json) {
    final risks = (json['risks'] as List? ?? const [])
        .map((e) => RiskItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Insights(
      disclaimer: json['disclaimer']?.toString() ?? '',
      disclaimerBm: json['disclaimerBm']?.toString() ?? '',
      disclaimerZh: json['disclaimerZh']?.toString() ?? '',
      actualAge: (json['actualAge'] as num?)?.toInt() ?? 0,
      healthAge: (json['healthAge'] as num?)?.toInt() ?? 0,
      lifeExpectancy: (json['lifeExpectancy'] as num?)?.toDouble() ?? 0,
      overallRiskLevel: json['overallRiskLevel']?.toString() ?? 'low',
      overallRiskScore: (json['overallRiskScore'] as num?)?.toInt() ?? 0,
      topRisk: json['topRisk'] is Map
          ? RiskItem.fromJson(Map<String, dynamic>.from(json['topRisk'] as Map))
          : (risks.isNotEmpty
                ? risks.first
                : const RiskItem(
                    id: '',
                    name: '',
                    nameBm: '',
                    nationalAverage: 0,
                    personalRisk: 0,
                    level: 'low',
                    deltaVsPeers: 0,
                  )),
      risks: risks,
      factors: (json['factors'] as List? ?? const [])
          .map((e) => RiskFactor.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      peerComparison: json['peerComparison']?.toString() ?? '',
      peerComparisonBm: json['peerComparisonBm']?.toString() ?? '',
      peerComparisonZh: json['peerComparisonZh']?.toString() ?? '',
      topActions: (json['topActions'] as List? ?? const [])
          .map((e) => ActionItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      habits: (json['habits'] as List? ?? const [])
          .map((e) => HabitCatalogItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
      peerAverageHealthAge:
          (json['peerAverageHealthAge'] as num?)?.toInt() ?? (json['actualAge'] as num?)?.toInt() ?? 0,
      healthAgeDelta:
          (json['healthAgeDelta'] as num?)?.toInt() ??
          (((json['healthAge'] as num?)?.toInt() ?? 0) - ((json['actualAge'] as num?)?.toInt() ?? 0)),
      projectedHealthAgeFollowPlan:
          (json['projectedHealthAgeFollowPlan'] as num?)?.toInt() ??
          (json['healthAge'] as num?)?.toInt() ??
          0,
      projectedHealthAgeNoChange:
          (json['projectedHealthAgeNoChange'] as num?)?.toInt() ?? (json['healthAge'] as num?)?.toInt() ?? 0,
      nationalComparisonHeadline: json['nationalComparisonHeadline']?.toString() ?? '',
      nationalComparisonHeadlineBm: json['nationalComparisonHeadlineBm']?.toString() ?? '',
      nationalComparisonHeadlineZh: json['nationalComparisonHeadlineZh']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disclaimer': disclaimer,
      'disclaimerBm': disclaimerBm,
      'disclaimerZh': disclaimerZh,
      'actualAge': actualAge,
      'healthAge': healthAge,
      'lifeExpectancy': lifeExpectancy,
      'overallRiskLevel': overallRiskLevel,
      'overallRiskScore': overallRiskScore,
      'topRisk': topRisk.toJson(),
      'risks': risks.map((e) => e.toJson()).toList(),
      'factors': factors.map((e) => e.toJson()).toList(),
      'peerComparison': peerComparison,
      'peerComparisonBm': peerComparisonBm,
      'peerComparisonZh': peerComparisonZh,
      'topActions': topActions.map((e) => e.toJson()).toList(),
      'habits': habits.map((e) => e.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
      'peerAverageHealthAge': peerAverageHealthAge,
      'healthAgeDelta': healthAgeDelta,
      'projectedHealthAgeFollowPlan': projectedHealthAgeFollowPlan,
      'projectedHealthAgeNoChange': projectedHealthAgeNoChange,
      'nationalComparisonHeadline': nationalComparisonHeadline,
      'nationalComparisonHeadlineBm': nationalComparisonHeadlineBm,
      'nationalComparisonHeadlineZh': nationalComparisonHeadlineZh,
    };
  }

  String localizedPeerComparison(String locale) =>
      localizedText(locale, en: peerComparison, bm: peerComparisonBm, zh: peerComparisonZh);

  String localizedDisclaimer(String locale) =>
      localizedText(locale, en: disclaimer, bm: disclaimerBm, zh: disclaimerZh);

  String localizedNationalComparisonHeadline(String locale) => localizedText(
    locale,
    en: nationalComparisonHeadline,
    bm: nationalComparisonHeadlineBm,
    zh: nationalComparisonHeadlineZh,
  );

  @override
  List<Object?> get props => [
    disclaimer,
    disclaimerBm,
    disclaimerZh,
    actualAge,
    healthAge,
    lifeExpectancy,
    overallRiskLevel,
    overallRiskScore,
    topRisk,
    risks,
    factors,
    peerComparison,
    peerComparisonBm,
    peerComparisonZh,
    topActions,
    habits,
    generatedAt,
    peerAverageHealthAge,
    healthAgeDelta,
    projectedHealthAgeFollowPlan,
    projectedHealthAgeNoChange,
    nationalComparisonHeadline,
    nationalComparisonHeadlineBm,
    nationalComparisonHeadlineZh,
  ];
}
