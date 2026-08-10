import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/habit.dart';
import '../../model/insights.dart';
import '../../model/profile.dart';
import '../repositories/habit_repository.dart';
import '../repositories/insights_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/recommendations_repository.dart';
import '../services/habit_progress.dart';
import '../services/habit_reminder_service.dart';
import '../services/recommendation_engine.dart';
import 'habits_state.dart';

export 'habits_state.dart';

/// Today's 4 personalised habits, risk drop, and reminders.
class HabitsCubit extends Cubit<HabitsState> {
  HabitsCubit({
    HabitRepository? habitRepository,
    InsightsRepository? insightsRepository,
    ProfileRepository? profileRepository,
    RecommendationsRepository? recommendationsRepository,
  }) : _habitRepository = habitRepository ?? HabitRepository(),
       _insightsRepository = insightsRepository ?? InsightsRepository(),
       _profileRepository = profileRepository ?? ProfileRepository(),
       _recommendationsRepository = recommendationsRepository ?? RecommendationsRepository(),
       super(const HabitsState());

  final HabitRepository _habitRepository;
  final InsightsRepository _insightsRepository;
  final ProfileRepository _profileRepository;
  final RecommendationsRepository _recommendationsRepository;

  String? _userId;
  HabitLogRow? _log;
  Insights? _insights;
  Profile? _profile;
  List<HabitLogRow> _recent = const [];
  List<HabitRecommendation>? _recommendedHabits;
  String _coachNote = '';
  String _coachNoteBm = '';
  String _coachNoteZh = '';

  Future<void> loadToday(String userId, {DateTime? date}) async {
    _userId = userId;
    final day = date ?? DateTime.now();
    emit(state.copyWith(status: HabitsStatus.loading, errorMessage: null));
    try {
      final results = await Future.wait([
        _habitRepository.getOrCreateForDate(userId, day),
        _insightsRepository.getInsights(userId),
        _profileRepository.getProfile(userId),
        _habitRepository.listRecent(days: 7),
        HabitReminderService.load(),
      ]);
      _log = results[0] as HabitLogRow;
      _insights = results[1] as Insights?;
      _profile = results[2] as Profile?;
      _recent = results[3] as List<HabitLogRow>;
      final reminder = results[4] as ({bool enabled, int hour, int minute});

      _emit(
        _log!,
        reminderEnabled: reminder.enabled,
        reminderHour: reminder.hour,
        reminderMinute: reminder.minute,
      );
      await _loadRecommendations();
    } catch (e) {
      emit(state.copyWith(status: HabitsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> refreshToday() async {
    final userId = _userId;
    if (userId != null) await loadToday(userId);
  }

  Future<void> _loadRecommendations() async {
    final log = _log;
    if (log == null) return;
    try {
      final result = await _recommendationsRepository.fetch();
      if (result == null || result.habits.length < 4) return;
      _recommendedHabits = result.habits;
      _coachNote = result.coachNote;
      _coachNoteBm = result.coachNoteBm;
      _coachNoteZh = result.coachNoteZh;
      _emit(log);
    } catch (_) {
      // Keep local recommendations if the backend call is unavailable.
    }
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
      _recent = [
        updated,
        ..._recent.where(
          (r) =>
              r.logDate.toIso8601String().substring(0, 10) !=
              updated.logDate.toIso8601String().substring(0, 10),
        ),
      ];
      _emit(updated);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> setReminder({required bool enabled, int? hour, int? minute}) async {
    final h = hour ?? state.reminderHour;
    final m = minute ?? state.reminderMinute;
    await HabitReminderService.save(enabled: enabled, hour: h, minute: m);
    emit(state.copyWith(reminderEnabled: enabled, reminderHour: h, reminderMinute: m));
  }

  void _emit(
    HabitLogRow log, {
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    final insights = _insights;
    final profile = _profile;
    final daySeed = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;

    final local = (profile != null && insights != null)
        ? RecommendationEngine.recommendDailyHabits(
            profile: profile,
            risks: insights.risks,
            daySeed: daySeed,
          )
        : const <HabitRecommendation>[];

    final planned = (_recommendedHabits != null && _recommendedHabits!.length >= 4)
        ? _recommendedHabits!
        : local.isNotEmpty
        ? local
        : (insights?.habits ?? const [])
              .take(RecommendationEngine.dailyHabitCount)
              .map(
                (h) => HabitRecommendation(
                  habit: h,
                  score: 1,
                  reasonEn: 'From your latest Health Age plan.',
                  reasonBm: 'Dari pelan Umur Kesihatan terkini anda.',
                  reasonZh: '来自您最新的健康年龄计划。',
                  category: 'HABIT',
                ),
              )
              .toList();

    final completedSet = log.completedHabitIds.toSet();
    final items = [
      for (final rec in planned.take(RecommendationEngine.dailyHabitCount))
        HabitItem(
          catalogItem: rec.habit,
          completed: completedSet.contains(rec.habit.id),
          reasonEn: rec.reasonEn,
          reasonBm: rec.reasonBm,
          reasonZh: rec.reasonZh,
          category: rec.category,
        ),
    ];
    final completedCount = items.where((i) => i.completed).length;
    final total = items.length;

    final strongDays = _countStrongDays(totalPlan: total);
    final baseHealth = insights?.healthAge ?? 0;
    final actual = insights?.actualAge ?? profile?.age ?? 0;
    final riskDrop = HabitProgressEffect.riskDropPoints(
      completedToday: completedCount,
      totalToday: total,
      strongDaysLastWeek: strongDays,
    );
    final adjusted = HabitProgressEffect.adjustedHealthAge(
      healthAge: baseHealth,
      actualAge: actual,
      completedToday: completedCount,
      totalToday: total,
      strongDaysLastWeek: strongDays,
    );

    String motivation;
    String motivationBm;
    String motivationZh;
    if (_coachNote.isNotEmpty && completedCount == 0) {
      motivation = _coachNote;
      motivationBm = _coachNoteBm.isNotEmpty ? _coachNoteBm : _coachNote;
      motivationZh = _coachNoteZh.isNotEmpty ? _coachNoteZh : _coachNote;
    } else if (completedCount == 0) {
      motivation = 'Complete today’s 4 actions — each tick lowers your risk signal.';
      motivationBm = 'Lengkapkan 4 tindakan hari ini — setiap tanda menurunkan isyarat risiko.';
      motivationZh = '完成今天的 4 项行动 — 每勾一项都会降低风险信号。';
    } else if (total > 0 && completedCount == total) {
      motivation = 'All 4 done — risk dropped about ${riskDrop.toStringAsFixed(1)} points today.';
      motivationBm = 'Keempat-empat selesai — risiko turun kira-kira ${riskDrop.toStringAsFixed(1)} mata hari ini.';
      motivationZh = '四项全部完成 — 今日风险约下降 ${riskDrop.toStringAsFixed(1)} 分。';
    } else {
      motivation =
          '$completedCount of $total done — risk down ~${riskDrop.toStringAsFixed(1)} pts (Health Age → $adjusted).';
      motivationBm =
          '$completedCount daripada $total selesai — risiko turun ~${riskDrop.toStringAsFixed(1)} mata (Umur Kesihatan → $adjusted).';
      motivationZh =
          '已完成 $completedCount / $total — 风险约下降 ${riskDrop.toStringAsFixed(1)} 分（健康年龄 → $adjusted）。';
    }

    emit(
      state.copyWith(
        status: HabitsStatus.ready,
        items: items,
        completedCount: completedCount,
        totalCount: total,
        motivation: motivation,
        motivationBm: motivationBm,
        motivationZh: motivationZh,
        riskDropPoints: riskDrop,
        adjustedHealthAge: adjusted,
        baseHealthAge: baseHealth,
        actualAge: actual,
        strongDaysLastWeek: strongDays,
        reminderEnabled: reminderEnabled ?? state.reminderEnabled,
        reminderHour: reminderHour ?? state.reminderHour,
        reminderMinute: reminderMinute ?? state.reminderMinute,
      ),
    );
  }

  int _countStrongDays({required int totalPlan}) {
    if (totalPlan <= 0) return 0;
    var count = 0;
    for (final log in _recent) {
      final done = log.completedHabitIds.length;
      if (done >= totalPlan || done >= RecommendationEngine.dailyHabitCount) count += 1;
    }
    return count;
  }

  void clear() {
    _userId = null;
    _log = null;
    _insights = null;
    _profile = null;
    _recent = const [];
    _recommendedHabits = null;
    _coachNote = '';
    _coachNoteBm = '';
    _coachNoteZh = '';
    emit(const HabitsState());
  }
}
