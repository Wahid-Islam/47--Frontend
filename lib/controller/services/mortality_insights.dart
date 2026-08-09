import 'package:flutter/material.dart';

import '../../model/insights.dart';

/// One mortality highlight card derived from the user's computed [RiskItem]s.
class MortalityKiller {
  const MortalityKiller({
    required this.id,
    required this.titleEn,
    required this.titleBm,
    required this.bodyEn,
    required this.bodyBm,
    required this.sharePercent,
    required this.metaEn,
    required this.metaBm,
    required this.icon,
  });

  final String id;
  final String titleEn;
  final String titleBm;
  final String bodyEn;
  final String bodyBm;
  final double sharePercent;
  final String metaEn;
  final String metaBm;
  final IconData icon;

  String localizedTitle(String locale) => locale == 'bm' ? titleBm : titleEn;

  String localizedBody(String locale, String ageGroup) {
    final raw = locale == 'bm' ? bodyBm : bodyEn;
    return raw.replaceAll('{group}', ageGroup);
  }

  String localizedMeta(String locale) => locale == 'bm' ? metaBm : metaEn;

  String get percentLabel => '${sharePercent.toStringAsFixed(1)}%';
}

/// Builds My Health / Learn mortality cards from live [Insights] (profile-driven).
class MortalityInsights {
  MortalityInsights._();

  static String ageGroupLabel(int age) {
    if (age < 15) return '0–14';
    if (age <= 40) return '15–40';
    if (age <= 59) return '41–59';
    return '60+';
  }

  static IconData iconFor(String causeId) {
    switch (causeId) {
      case 'cardiovascular':
        return Icons.favorite_outline;
      case 'respiratory':
        return Icons.air_outlined;
      case 'diabetes_complications':
        return Icons.bloodtype_outlined;
      case 'cancer':
        return Icons.biotech_outlined;
      default:
        return Icons.monitor_heart_outlined;
    }
  }

  /// Top causes ranked by the user's personal risk from [RiskEngine].
  static List<MortalityKiller> fromInsights(Insights insights, {int limit = 3}) {
    final group = ageGroupLabel(insights.actualAge);
    final risks = insights.risks.take(limit).toList();
    return [
      for (final risk in risks) _fromRisk(risk, group: group),
    ];
  }

  static MortalityKiller _fromRisk(RiskItem risk, {required String group}) {
    final above = risk.personalRisk > risk.nationalAverage;
    final delta = (risk.personalRisk - risk.nationalAverage).abs();
    final deltaLabel = delta.toStringAsFixed(1);
    final peerLabel = risk.nationalAverage.toStringAsFixed(1);

    final bodyEn = above
        ? 'Based on your profile, your estimated ${risk.name.toLowerCase()} signal '
              'is about $deltaLabel points above the $group peer baseline '
              '($peerLabel).'
        : 'Based on your profile, your estimated ${risk.name.toLowerCase()} signal '
              'is about $deltaLabel points below the $group peer baseline '
              '($peerLabel).';

    final bodyBm = above
        ? 'Berdasarkan profil anda, isyarat ${risk.nameBm} dianggarkan kira-kira '
              '$deltaLabel mata lebih tinggi daripada baseline rakan sebaya $group '
              '($peerLabel).'
        : 'Berdasarkan profil anda, isyarat ${risk.nameBm} dianggarkan kira-kira '
              '$deltaLabel mata lebih rendah daripada baseline rakan sebaya $group '
              '($peerLabel).';

    return MortalityKiller(
      id: risk.id,
      titleEn: risk.name,
      titleBm: risk.nameBm.isNotEmpty ? risk.nameBm : risk.name,
      bodyEn: bodyEn,
      bodyBm: bodyBm,
      // Personal risk score from questionnaire + lifestyle inputs.
      sharePercent: risk.personalRisk,
      metaEn: 'vs peers ${risk.nationalAverage.toStringAsFixed(1)}',
      metaBm: 'vs rakan sebaya ${risk.nationalAverage.toStringAsFixed(1)}',
      icon: iconFor(risk.id),
    );
  }

  /// Learn-page cards built from the same live insights payload.
  static List<({String eyebrow, String title, String stat, String body, String source})> learnCards(
    Insights insights,
    String locale,
  ) {
    final group = ageGroupLabel(insights.actualAge);
    final top = insights.topRisk;
    final second = insights.risks.length > 1 ? insights.risks[1] : top;
    final bm = locale == 'bm';

    return [
      (
        eyebrow: bm ? 'Kumpulan umur anda · $group' : 'Your age group · $group',
        title: bm
            ? '${top.localizedName(locale)} ialah isyarat utama anda'
            : '${top.localizedName(locale)} is your top signal',
        stat: '${top.personalRisk.toStringAsFixed(1)}%',
        body: bm
            ? 'Anggaran peribadi anda ialah ${top.personalRisk.toStringAsFixed(1)} berbanding baseline '
                  'rakan sebaya ${top.nationalAverage.toStringAsFixed(1)} untuk umur $group '
                  '(Umur Kesihatan ${insights.healthAge} vs umur sebenar ${insights.actualAge}).'
            : 'Your personalised estimate is ${top.personalRisk.toStringAsFixed(1)} vs a '
                  '${top.nationalAverage.toStringAsFixed(1)} peer baseline for ages $group '
                  '(Health Age ${insights.healthAge} vs actual age ${insights.actualAge}).',
        source: bm
            ? 'Dijana daripada jawapan soal selidik anda + baseline DOSM-inspirasi'
            : 'Generated from your questionnaire answers + DOSM-inspired baselines',
      ),
      (
        eyebrow: bm ? 'Perbandingan rakan sebaya' : 'Peer comparison',
        title: bm ? 'Jurang Umur Kesihatan anda' : 'Your Health Age gap',
        stat: insights.healthAgeDelta == 0
            ? (bm ? 'Selaras' : 'Aligned')
            : '${insights.healthAgeDelta > 0 ? '+' : ''}${insights.healthAgeDelta}',
        body: bm
            ? 'Umur Kesihatan ${insights.healthAge} berbanding umur sebenar ${insights.actualAge}. '
                  'Tabiat dalam Pelan anda disasarkan untuk menutup jurang ini.'
            : 'Health Age ${insights.healthAge} versus actual age ${insights.actualAge}. '
                  'Your Roadmap habits are aimed at closing this gap.',
        source: bm ? 'Dikira semula setiap kali profil dikemas kini' : 'Recalculated whenever your profile updates',
      ),
      (
        eyebrow: bm ? 'Isyarat seterusnya' : 'Next signal',
        title: second.localizedName(locale),
        stat: '${second.personalRisk.toStringAsFixed(1)}%',
        body: bm
            ? 'Baseline rakan sebaya ${second.nationalAverage.toStringAsFixed(1)}. '
                  'Perbezaan berbanding rakan sebaya: ${second.deltaVsPeers >= 0 ? '+' : ''}${second.deltaVsPeers.toStringAsFixed(1)}.'
            : 'Peer baseline ${second.nationalAverage.toStringAsFixed(1)}. '
                  'Difference vs peers: ${second.deltaVsPeers >= 0 ? '+' : ''}${second.deltaVsPeers.toStringAsFixed(1)}.',
        source: bm ? 'Disusun mengikut risiko peribadi anda' : 'Ranked by your personal risk scores',
      ),
      (
        eyebrow: bm ? 'Cara membaca ini' : 'How to read this',
        title: bm
            ? 'Data populasi ialah konteks, bukan diagnosis'
            : 'Population data is context, not a diagnosis',
        stat: '',
        body: bm
            ? 'MySihat menggabungkan jawapan profil anda dengan baseline kematian Malaysia '
                  'untuk menjadikan statistik lebih bermakna secara peribadi. Ia bukan diagnosis perubatan.'
            : 'MySihat combines your profile answers with Malaysian mortality baselines '
                  'to make statistics personally meaningful. It is not a medical diagnosis.',
        source: insights.localizedDisclaimer(locale),
      ),
    ];
  }
}
