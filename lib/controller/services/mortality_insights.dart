import 'package:flutter/material.dart';

import '../../core/l10n/localized.dart';
import '../../model/insights.dart';

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
    this.titleZh = '',
    this.bodyZh = '',
    this.metaZh = '',
  });

  final String id;
  final String titleEn;
  final String titleBm;
  final String titleZh;
  final String bodyEn;
  final String bodyBm;
  final String bodyZh;
  final double sharePercent;
  final String metaEn;
  final String metaBm;
  final String metaZh;
  final IconData icon;

  String localizedTitle(String locale) =>
      localizedText(locale, en: titleEn, bm: titleBm, zh: titleZh);

  String localizedBody(String locale, String ageGroup) {
    final raw = localizedText(locale, en: bodyEn, bm: bodyBm, zh: bodyZh);
    return raw.replaceAll('{group}', ageGroup);
  }

  String localizedMeta(String locale) =>
      localizedText(locale, en: metaEn, bm: metaBm, zh: metaZh);

  String get percentLabel => '${sharePercent.toStringAsFixed(1)}%';
}

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
    final nameZh = risk.nameZh.isNotEmpty ? risk.nameZh : risk.name;

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

    final bodyZh = above
        ? '根据您的资料，您的$nameZh信号估计比 $group 同龄基线（$peerLabel）高出约 $deltaLabel 分。'
        : '根据您的资料，您的$nameZh信号估计比 $group 同龄基线（$peerLabel）低出约 $deltaLabel 分。';

    return MortalityKiller(
      id: risk.id,
      titleEn: risk.name,
      titleBm: risk.nameBm.isNotEmpty ? risk.nameBm : risk.name,
      titleZh: nameZh,
      bodyEn: bodyEn,
      bodyBm: bodyBm,
      bodyZh: bodyZh,
      sharePercent: risk.personalRisk,
      metaEn: 'vs peers ${risk.nationalAverage.toStringAsFixed(1)}',
      metaBm: 'vs rakan sebaya ${risk.nationalAverage.toStringAsFixed(1)}',
      metaZh: '对比同龄 ${risk.nationalAverage.toStringAsFixed(1)}',
      icon: iconFor(risk.id),
    );
  }

  static List<({String eyebrow, String title, String stat, String body, String source})> learnCards(
    Insights insights,
    String locale,
  ) {
    final group = ageGroupLabel(insights.actualAge);
    final top = insights.topRisk;
    final second = insights.risks.length > 1 ? insights.risks[1] : top;
    final topName = top.localizedName(locale);
    final secondName = second.localizedName(locale);

    String t({required String en, required String bm, required String zh}) =>
        localizedText(locale, en: en, bm: bm, zh: zh);

    return [
      (
        eyebrow: t(en: 'Your age group · $group', bm: 'Kumpulan umur anda · $group', zh: '您的年龄组 · $group'),
        title: t(
          en: '$topName is your top signal',
          bm: '$topName ialah isyarat utama anda',
          zh: '$topName 是您的主要信号',
        ),
        stat: '${top.personalRisk.toStringAsFixed(1)}%',
        body: t(
          en:
              'Your personalised estimate is ${top.personalRisk.toStringAsFixed(1)} vs a '
              '${top.nationalAverage.toStringAsFixed(1)} peer baseline for ages $group '
              '(Health Age ${insights.healthAge} vs actual age ${insights.actualAge}).',
          bm:
              'Anggaran peribadi anda ialah ${top.personalRisk.toStringAsFixed(1)} berbanding baseline '
              'rakan sebaya ${top.nationalAverage.toStringAsFixed(1)} untuk umur $group '
              '(Umur Kesihatan ${insights.healthAge} vs umur sebenar ${insights.actualAge}).',
          zh:
              '您的个性化估计为 ${top.personalRisk.toStringAsFixed(1)}，对比 $group 岁同龄基线 '
              '${top.nationalAverage.toStringAsFixed(1)}'
              '（健康年龄 ${insights.healthAge} vs 实际年龄 ${insights.actualAge}）。',
        ),
        source: t(
          en: 'Generated from your questionnaire answers + DOSM-inspired baselines',
          bm: 'Dijana daripada jawapan soal selidik anda + baseline DOSM-inspirasi',
          zh: '根据您的问卷回答与 DOSM 启发的基线生成',
        ),
      ),
      (
        eyebrow: t(en: 'Peer comparison', bm: 'Perbandingan rakan sebaya', zh: '同龄比较'),
        title: t(en: 'Your Health Age gap', bm: 'Jurang Umur Kesihatan anda', zh: '您的健康年龄差距'),
        stat: insights.healthAgeDelta == 0
            ? t(en: 'Aligned', bm: 'Selaras', zh: '一致')
            : '${insights.healthAgeDelta > 0 ? '+' : ''}${insights.healthAgeDelta}',
        body: t(
          en:
              'Health Age ${insights.healthAge} versus actual age ${insights.actualAge}. '
              'Your Roadmap habits are aimed at closing this gap.',
          bm:
              'Umur Kesihatan ${insights.healthAge} berbanding umur sebenar ${insights.actualAge}. '
              'Tabiat dalam Pelan anda disasarkan untuk menutup jurang ini.',
          zh:
              '健康年龄 ${insights.healthAge} 对比实际年龄 ${insights.actualAge}。'
              '计划中的习惯旨在缩小这一差距。',
        ),
        source: t(
          en: 'Recalculated whenever your profile updates',
          bm: 'Dikira semula setiap kali profil dikemas kini',
          zh: '资料更新时会重新计算',
        ),
      ),
      (
        eyebrow: t(en: 'Next signal', bm: 'Isyarat seterusnya', zh: '下一个信号'),
        title: secondName,
        stat: '${second.personalRisk.toStringAsFixed(1)}%',
        body: t(
          en:
              'Peer baseline ${second.nationalAverage.toStringAsFixed(1)}. '
              'Difference vs peers: ${second.deltaVsPeers >= 0 ? '+' : ''}${second.deltaVsPeers.toStringAsFixed(1)}.',
          bm:
              'Baseline rakan sebaya ${second.nationalAverage.toStringAsFixed(1)}. '
              'Perbezaan berbanding rakan sebaya: ${second.deltaVsPeers >= 0 ? '+' : ''}${second.deltaVsPeers.toStringAsFixed(1)}.',
          zh:
              '同龄基线 ${second.nationalAverage.toStringAsFixed(1)}。'
              '与同龄差异：${second.deltaVsPeers >= 0 ? '+' : ''}${second.deltaVsPeers.toStringAsFixed(1)}。',
        ),
        source: t(
          en: 'Ranked by your personal risk scores',
          bm: 'Disusun mengikut risiko peribadi anda',
          zh: '按您的个人风险分数排序',
        ),
      ),
      (
        eyebrow: t(en: 'How to read this', bm: 'Cara membaca ini', zh: '如何解读'),
        title: t(
          en: 'Population data is context, not a diagnosis',
          bm: 'Data populasi ialah konteks, bukan diagnosis',
          zh: '人群数据是背景，不是诊断',
        ),
        stat: '',
        body: t(
          en:
              'MySihat combines your profile answers with Malaysian mortality baselines '
              'to make statistics personally meaningful. It is not a medical diagnosis.',
          bm:
              'MySihat menggabungkan jawapan profil anda dengan baseline kematian Malaysia '
              'untuk menjadikan statistik lebih bermakna secara peribadi. Ia bukan diagnosis perubatan.',
          zh: 'MySihat 将您的资料回答与马来西亚死亡基线结合，使统计对个人更有意义。这不是医学诊断。',
        ),
        source: insights.localizedDisclaimer(locale),
      ),
    ];
  }
}
