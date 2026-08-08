import 'package:equatable/equatable.dart';

import '../../model/insights.dart';

enum InsightsStatus { initial, loading, ready, error }

const Object _unset = Object();

class InsightsState extends Equatable {
  const InsightsState({this.status = InsightsStatus.initial, this.insights, this.errorMessage});

  final InsightsStatus status;
  final Insights? insights;
  final String? errorMessage;

  InsightsState copyWith({InsightsStatus? status, Object? insights = _unset, Object? errorMessage = _unset}) {
    return InsightsState(
      status: status ?? this.status,
      insights: identical(insights, _unset) ? this.insights : insights as Insights?,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, insights, errorMessage];
}
