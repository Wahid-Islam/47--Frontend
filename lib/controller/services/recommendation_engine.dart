import '../../model/action_item.dart';
import '../../model/insights.dart';
import '../../model/profile.dart';
import 'action_catalog.dart';

/// One recommended daily habit with an explainable score.
class HabitRecommendation {
  const HabitRecommendation({
    required this.habit,
    required this.score,
    required this.reasonEn,
    required this.reasonBm,
    required this.category,
  });

  final HabitCatalogItem habit;
  final double score;
  final String reasonEn;
  final String reasonBm;
  final String category;

  String localizedReason(String locale) => locale == 'bm' && reasonBm.isNotEmpty ? reasonBm : reasonEn;
}

/// Ensemble ("random-forest style") habit recommender.
///
/// Several lightweight decision trees vote on each habit from the user's
/// questionnaire features and top risks. This is **not** a generative LLM —
/// Random Forest and LLMs are different tools. For structured profile inputs,
/// an ensemble ranker is the right fit; explanations are rule-derived.
class RecommendationEngine {
  RecommendationEngine._();

  static const int dailyHabitCount = 4;

  /// Exactly [dailyHabitCount] habits for today, personalised to [profile].
  ///
  /// [daySeed] (e.g. day-of-year) gently rotates lower-priority habits so the
  /// daily list can refresh while still matching the user's risk profile.
  static List<HabitRecommendation> recommendDailyHabits({
    required Profile profile,
    required List<RiskItem> risks,
    int daySeed = 0,
  }) {
    final topRiskIds = risks.take(2).map((r) => r.id).toSet();
    final scored = <HabitRecommendation>[
      for (final habit in ActionCatalog.habits)
        _scoreHabit(habit, profile: profile, topRiskIds: topRiskIds, daySeed: daySeed),
    ]..sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      // Stable daily rotation among near-ties.
      final aRot = (a.habit.id.hashCode ^ daySeed) & 0xffff;
      final bRot = (b.habit.id.hashCode ^ daySeed) & 0xffff;
      return aRot.compareTo(bRot);
    });

    final picked = <HabitRecommendation>[];
    final seen = <String>{};
    for (final rec in scored) {
      if (rec.score <= 0) continue;
      if (!seen.add(rec.habit.id)) continue;
      picked.add(rec);
      if (picked.length >= dailyHabitCount) break;
    }

    // Guarantee 4 slots even for very healthy profiles.
    if (picked.length < dailyHabitCount) {
      for (final habit in ActionCatalog.habits) {
        if (seen.contains(habit.id)) continue;
        picked.add(
          HabitRecommendation(
            habit: habit,
            score: 0.5,
            reasonEn: 'A simple daily anchor to keep momentum.',
            reasonBm: 'Sauh harian mudah untuk kekalkan momentum.',
            category: _categoryFor(habit.id),
          ),
        );
        seen.add(habit.id);
        if (picked.length >= dailyHabitCount) break;
      }
    }
    return picked.take(dailyHabitCount).toList();
  }

  static List<ActionItem> rankActions({
    required Profile profile,
    required List<RiskItem> risks,
  }) {
    final topIds = risks.take(2).map((r) => r.id).toSet();
    final scored =
        ActionCatalog.actions.map((action) {
          var votes = 0.0;
          // Tree 1 — impact prior
          votes += action.impact == 'high'
              ? 3
              : action.impact == 'medium'
              ? 2
              : 1;
          // Tree 2 — targets top risks
          if (action.targets.any(topIds.contains)) votes += 3;
          // Tree 3 — lifestyle match
          if (action.id == 'quit_support') votes += profile.smoking ? 5 : -6;
          if (action.id == 'walk_20' && profile.activityLevel == 'low') votes += 3;
          if (action.id == 'walk_20' && profile.activityLevel == 'moderate') votes += 1;
          if ((action.id == 'swap_drinks' || action.id == 'brown_rice') && profile.dietHabit == 'unhealthy') {
            votes += 3;
          }
          if (action.id == 'hydrate' && (profile.dietHabit != 'healthy' || profile.alcohol != 'none')) {
            votes += 1.5;
          }
          if (action.id == 'sleep_7' && (profile.sleepHours < 7 || profile.sleepHours > 9)) votes += 3;
          if (action.id == 'bp_screening' && (profile.highBloodPressure || profile.age >= 45)) votes += 2;
          if (action.id == 'blood_sugar' && (profile.bmi >= 25 || profile.dietHabit == 'unhealthy')) {
            votes += 2;
          }
          if (action.id == 'swap_drinks' && profile.alcohol == 'regular') votes += 1;
          return action.copyWith(priorityScore: votes.round());
        }).where((a) => (a.priorityScore ?? 0) > 0).toList()
          ..sort((a, b) => (b.priorityScore ?? 0).compareTo(a.priorityScore ?? 0));
    return scored;
  }

  static HabitRecommendation _scoreHabit(
    HabitCatalogItem habit, {
    required Profile profile,
    required Set<String> topRiskIds,
    required int daySeed,
  }) {
    var votes = 0.0;
    var reasonEn = 'Matched to your overall health profile.';
    var reasonBm = 'Disesuaikan dengan profil kesihatan keseluruhan anda.';

    void adopt(String en, String bm, double weight) {
      if (weight <= 0) return;
      votes += weight;
      if (weight >= 2) {
        reasonEn = en;
        reasonBm = bm;
      }
    }

    // --- ensemble trees (feature splits) ---
    switch (habit.id) {
      case 'walk_20':
        if (profile.activityLevel == 'low') {
          adopt('Your activity level is low — daily walking is a top lever.', 'Tahap aktiviti anda rendah — berjalan harian ialah tuas utama.', 4);
        } else if (profile.activityLevel == 'moderate') {
          adopt('Keep building on moderate activity with a daily walk.', 'Teruskan aktiviti sederhana dengan berjalan harian.', 2);
        } else {
          votes += 0.4;
        }
        if (topRiskIds.contains('cardiovascular') || topRiskIds.contains('diabetes_complications')) {
          votes += 2;
        }
      case 'smoke_free_day':
        if (profile.smoking) {
          adopt('Smoking strongly raises your Health Age — stay smoke-free today.', 'Merokok menaikkan Umur Kesihatan dengan kuat — kekal tanpa asap hari ini.', 6);
        } else {
          votes -= 3;
        }
        if (topRiskIds.contains('respiratory') || topRiskIds.contains('cancer')) votes += 1.5;
      case 'no_sugary_drink':
      case 'brown_rice_meal':
        if (profile.dietHabit == 'unhealthy') {
          adopt('Diet is a high-impact factor in your result — one better food choice today.', 'Pemakanan berimpak tinggi dalam keputusan anda — satu pilihan makanan lebih baik hari ini.', 4);
        } else if (profile.dietHabit == 'average') {
          adopt('A small diet upgrade supports your metabolic risk.', 'Peningkatan pemakanan kecil menyokong risiko metabolik anda.', 2);
        } else {
          votes += 0.3;
        }
        if (topRiskIds.contains('diabetes_complications')) votes += 2;
      case 'drink_water':
        adopt('Hydration helps replace sugary drinks and supports daily energy.', 'Penghidratan membantu ganti minuman bergula dan menyokong tenaga harian.', 1.2);
        if (profile.dietHabit != 'healthy') votes += 0.8;
        if (profile.alcohol != 'none') votes += 0.6;
      case 'sleep_7':
        if (profile.sleepHours < 7 || profile.sleepHours > 9) {
          adopt(
            'Your sleep hours are outside the 7–9 window — protect tonight’s sleep.',
            'Jam tidur anda di luar julat 7–9 — lindungi tidur malam ini.',
            4,
          );
        } else {
          votes += 0.5;
        }
      case 'check_bp_reminder':
        if (profile.highBloodPressure || profile.age >= 45 || topRiskIds.contains('cardiovascular')) {
          adopt(
            'Blood-pressure awareness matters for your age and heart risk.',
            'Kesedaran tekanan darah penting untuk umur dan risiko jantung anda.',
            3,
          );
        } else {
          votes += 0.4;
        }
      default:
        votes += 0.2;
    }

    // Tiny day-based jitter so the 3rd/4th habit can rotate across days.
    votes += ((habit.id.hashCode + daySeed) % 7) * 0.05;

    return HabitRecommendation(
      habit: habit,
      score: votes,
      reasonEn: reasonEn,
      reasonBm: reasonBm,
      category: _categoryFor(habit.id),
    );
  }

  static String _categoryFor(String habitId) {
    switch (habitId) {
      case 'walk_20':
        return 'ACTIVITY';
      case 'sleep_7':
        return 'SLEEP';
      case 'no_sugary_drink':
      case 'brown_rice_meal':
      case 'drink_water':
        return 'DIET';
      case 'smoke_free_day':
        return 'SMOKING';
      case 'check_bp_reminder':
        return 'SCREENING';
      default:
        return 'HABIT';
    }
  }
}
