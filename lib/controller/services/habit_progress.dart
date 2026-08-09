/// Day-by-day risk / Health Age effect from completing daily habits.
///
/// Each completed habit today nudges risk down; consecutive strong days
/// accumulate a short momentum bonus (illustrative, not clinical).
class HabitProgressEffect {
  HabitProgressEffect._();

  /// Points of overall risk score removed (0–100 scale used by Insights).
  static double riskDropPoints({
    required int completedToday,
    required int totalToday,
    required int strongDaysLastWeek,
  }) {
    if (totalToday <= 0) return 0;
    final today = (completedToday / totalToday) * 4.0; // up to ~4 points today
    final momentum = strongDaysLastWeek.clamp(0, 7) * 0.6; // up to ~4.2 from streak
    return (today + momentum).clamp(0, 10);
  }

  /// Health Age after applying habit progress toward [actualAge].
  static int adjustedHealthAge({
    required int healthAge,
    required int actualAge,
    required int completedToday,
    required int totalToday,
    required int strongDaysLastWeek,
  }) {
    if (healthAge <= actualAge || totalToday <= 0) return healthAge;
    final gap = healthAge - actualAge;
    final todayFrac = completedToday / totalToday;
    // Today’s ticks close up to 25% of the gap; streak closes up to another 25%.
    final close = gap * (0.25 * todayFrac + 0.25 * (strongDaysLastWeek.clamp(0, 7) / 7));
    return (healthAge - close).round().clamp(actualAge, healthAge);
  }

  /// 12‑month follow-plan end still targets actual age, accelerated by progress.
  static double followPlanEnd({
    required int healthAge,
    required int actualAge,
    required double habitProgressToday,
  }) {
    final target = healthAge > actualAge ? actualAge.toDouble() : healthAge.toDouble();
    final p = habitProgressToday.clamp(0.0, 1.0);
    if (p <= 0) return healthAge.toDouble();
    final eased = 0.2 + 0.8 * p;
    return healthAge + (target - healthAge) * eased;
  }
}
