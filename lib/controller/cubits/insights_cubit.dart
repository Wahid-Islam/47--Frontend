import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/profile.dart';
import '../../model/insights.dart';
import '../repositories/insights_repository.dart';
import '../services/risk_engine.dart';
import 'insights_state.dart';

export 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit({InsightsRepository? repository})
    : _repository = repository ?? InsightsRepository(),
      super(const InsightsState());

  final InsightsRepository _repository;

  Future<void> load(String userId) async {
    emit(state.copyWith(status: InsightsStatus.loading, errorMessage: null));
    try {
      final insights = await _repository.getInsights(userId);
      emit(state.copyWith(status: InsightsStatus.ready, insights: insights));
    } catch (e) {
      emit(state.copyWith(status: InsightsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<Insights?> recalculate(Profile profile) async {
    emit(state.copyWith(status: InsightsStatus.loading, errorMessage: null));
    try {
      final computed = RiskEngine.compute(profile);
      final saved = await _repository.upsertInsights(profile.id, computed);
      emit(state.copyWith(status: InsightsStatus.ready, insights: saved));
      return saved;
    } catch (e) {
      emit(state.copyWith(status: InsightsStatus.error, errorMessage: e.toString()));
      return null;
    }
  }

  void clear() => emit(const InsightsState());
}
