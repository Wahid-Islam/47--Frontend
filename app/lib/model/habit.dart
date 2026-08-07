import 'package:equatable/equatable.dart';

import 'action_item.dart';

/// Immutable domain model mirroring one row of `public.habit_logs`.
class HabitLogRow extends Equatable {
  const HabitLogRow({required this.userId, required this.logDate, this.completedHabitIds = const []});

  final String userId;
  final DateTime logDate;
  final List<String> completedHabitIds;

  factory HabitLogRow.fromJson(Map<String, dynamic> json) {
    return HabitLogRow(
      userId: json['user_id']?.toString() ?? '',
      logDate: DateTime.tryParse(json['log_date']?.toString() ?? '') ?? DateTime.now(),
      completedHabitIds:
          (json['completed_habit_ids'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'log_date': logDate.toIso8601String().substring(0, 10),
      'completed_habit_ids': completedHabitIds,
    };
  }

  HabitLogRow copyWith({List<String>? completedHabitIds}) {
    return HabitLogRow(
      userId: userId,
      logDate: logDate,
      completedHabitIds: completedHabitIds ?? this.completedHabitIds,
    );
  }

  @override
  List<Object?> get props => [userId, logDate, completedHabitIds];
}

/// A single habit row rendered on the Progress screen: a catalog entry
/// combined with today's completed state.
class HabitItem extends Equatable {
  const HabitItem({required this.catalogItem, required this.completed});

  final HabitCatalogItem catalogItem;
  final bool completed;

  String get id => catalogItem.id;

  String localizedTitle(String locale) => catalogItem.localizedTitle(locale);

  @override
  List<Object?> get props => [catalogItem, completed];
}

/// View-ready aggregate for "today's habits", combining the planned habit
/// list (derived from the latest insights) with the day's completion log.
class HabitsToday extends Equatable {
  const HabitsToday({
    required this.date,
    this.items = const [],
    this.completedCount = 0,
    this.totalCount = 0,
    this.motivation = '',
    this.motivationBm = '',
  });

  final DateTime date;
  final List<HabitItem> items;
  final int completedCount;
  final int totalCount;
  final String motivation;
  final String motivationBm;

  String localizedMotivation(String locale) =>
      locale == 'bm' && motivationBm.isNotEmpty ? motivationBm : motivation;

  @override
  List<Object?> get props => [date, items, completedCount, totalCount, motivation, motivationBm];
}
