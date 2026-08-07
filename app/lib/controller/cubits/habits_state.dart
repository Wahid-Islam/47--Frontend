import 'package:equatable/equatable.dart';

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
    this.errorMessage,
  });

  final HabitsStatus status;
  final List<HabitItem> items;
  final int completedCount;
  final int totalCount;
  final String motivation;
  final String motivationBm;
  final String? errorMessage;

  String localizedMotivation(String locale) =>
      locale == 'bm' && motivationBm.isNotEmpty ? motivationBm : motivation;

  HabitsState copyWith({
    HabitsStatus? status,
    List<HabitItem>? items,
    int? completedCount,
    int? totalCount,
    String? motivation,
    String? motivationBm,
    String? errorMessage,
  }) {
    return HabitsState(
      status: status ?? this.status,
      items: items ?? this.items,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      motivation: motivation ?? this.motivation,
      motivationBm: motivationBm ?? this.motivationBm,
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
    errorMessage,
  ];
}
