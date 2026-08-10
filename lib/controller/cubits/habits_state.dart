import 'package:equatable/equatable.dart';

import '../../core/l10n/localized.dart';
import '../../model/habit.dart';

enum HabitsStatus { initial, loading, ready, error }

class HabitsState extends Equatable {
  const HabitsState({
    this.status = HabitsStatus.initial,
    this.items = const [],
    this.completedCount = 0,
    this.totalCount = 0,
    this.motivation = '',
    this.motivationBm = '',
    this.motivationZh = '',
    this.riskDropPoints = 0,
    this.adjustedHealthAge = 0,
    this.baseHealthAge = 0,
    this.actualAge = 0,
    this.strongDaysLastWeek = 0,
    this.reminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.errorMessage,
  });

  final HabitsStatus status;
  final List<HabitItem> items;
  final int completedCount;
  final int totalCount;
  final String motivation;
  final String motivationBm;
  final String motivationZh;

  /// Illustrative overall-risk points dropped from today's ticks + streak.
  final double riskDropPoints;

  /// Health Age after applying habit progress toward actual age.
  final int adjustedHealthAge;
  final int baseHealthAge;
  final int actualAge;
  final int strongDaysLastWeek;

  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final String? errorMessage;

  double get habitProgress => totalCount == 0 ? 0 : completedCount / totalCount;

  String localizedMotivation(String locale) =>
      localizedText(locale, en: motivation, bm: motivationBm, zh: motivationZh);

  HabitsState copyWith({
    HabitsStatus? status,
    List<HabitItem>? items,
    int? completedCount,
    int? totalCount,
    String? motivation,
    String? motivationBm,
    String? motivationZh,
    double? riskDropPoints,
    int? adjustedHealthAge,
    int? baseHealthAge,
    int? actualAge,
    int? strongDaysLastWeek,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? errorMessage,
  }) {
    return HabitsState(
      status: status ?? this.status,
      items: items ?? this.items,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      motivation: motivation ?? this.motivation,
      motivationBm: motivationBm ?? this.motivationBm,
      motivationZh: motivationZh ?? this.motivationZh,
      riskDropPoints: riskDropPoints ?? this.riskDropPoints,
      adjustedHealthAge: adjustedHealthAge ?? this.adjustedHealthAge,
      baseHealthAge: baseHealthAge ?? this.baseHealthAge,
      actualAge: actualAge ?? this.actualAge,
      strongDaysLastWeek: strongDaysLastWeek ?? this.strongDaysLastWeek,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    completedCount,
    totalCount,
    motivation,
    motivationBm,
    motivationZh,
    riskDropPoints,
    adjustedHealthAge,
    baseHealthAge,
    actualAge,
    strongDaysLastWeek,
    reminderEnabled,
    reminderHour,
    reminderMinute,
    errorMessage,
  ];
}
