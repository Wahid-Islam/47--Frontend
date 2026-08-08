import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/habit.dart';
import '../../model/insights.dart';
import '../repositories/habit_repository.dart';
import '../repositories/insights_repository.dart';
import '../services/action_catalog.dart';
import 'habits_state.dart';

export 'habits_state.dart';

/// Loads/creates today's habit log and derives the "today's habits" view
/// model by combining it with the planned habits from the latest insights
/// (falling back to the first 4 catalog habits when there are no insights
/// yet).
class HabitsCubit extends Cubit<HabitsState> {
  HabitsCubit({HabitRepository? habitRepository, InsightsRepository? insightsRepository})
    : _habitRepository = habitRepository ?? HabitRepository(),
      _insightsRepository = insightsRepository ?? InsightsRepository(),
      super(const HabitsState());

  final HabitRepository _habitRepository;
  final InsightsRepository _insightsRepository;

  String? _userId;
  HabitLogRow? _log;
  Insights? _insights;

  Future<void> loadToday(String userId, {DateTime? date}) async {
    _userId = userId;
    final day = date ?? DateTime.now();
    emit(state.copyWith(status: HabitsStatus.loading, errorMessage: null));
    try {
      final log = await _habitRepository.getOrCreateForDate(userId, day);
      final insights = await _insightsRepository.getInsights(userId);
      _log = log;
      _insights = insights;
      _emit(log, insights);
    } catch (e) {
      emit(state.copyWith(status: HabitsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> refreshToday() async {
    final userId = _userId;
    if (userId != null) await loadToday(userId);
  }

  Future<void> toggle(String habitId, {bool? completed}) async {
    final userId = _userId;
    final log = _log;
    if (userId == null || log == null) return;
    final ids = log.completedHabitIds.toSet();
    final shouldComplete = completed ?? !ids.contains(habitId);
    if (shouldComplete) {
      ids.add(habitId);
    } else {
      ids.remove(habitId);
    }
    try {
      final updated = await _habitRepository.setCompletedIds(userId, log.logDate, ids.toList());
      _log = updated;
      _emit(updated, _insights);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _emit(HabitLogRow log, Insights? insights) {
    final planned = (insights != null && insights.habits.isNotEmpty)
        ? insights.habits
        : ActionCatalog.habits.take(4).toList();
    final completedSet = log.completedHabitIds.toSet();
    final items = planned
        .map((h) => HabitItem(catalogItem: h, completed: completedSet.contains(h.id)))
        .toList();
    final completedCount = items.where((i) => i.completed).length;
    final total = items.length;

    String motivation;
    String motivationBm;
    if (completedCount == 0) {
      motivation = 'Small steps today protect your independence tomorrow.';
      motivationBm = 'Langkah kecil hari ini melindungi kebebasan anda esok.';
    } else if (total > 0 && completedCount == total) {
      motivation = 'Excellent! You completed every habit today.';
      motivationBm = 'Cemerlang! Anda melengkapkan semua tabiat hari ini.';
    } else {
      motivation = 'Great progress! Keep it up!';
      motivationBm = 'Kemajuan hebat! Teruskan!';
    }

    emit(
      state.copyWith(
        status: HabitsStatus.ready,
        items: items,
        completedCount: completedCount,
        totalCount: total,
        motivation: motivation,
        motivationBm: motivationBm,
      ),
    );
  }

  void clear() {
    _userId = null;
    _log = null;
    _insights = null;
    emit(const HabitsState());
  }
}
