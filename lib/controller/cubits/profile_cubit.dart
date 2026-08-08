import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/profile.dart';
import '../repositories/profile_repository.dart';
import 'profile_state.dart';

export 'profile_state.dart';

/// Loads and saves the current user's [Profile]. Insights recalculation
/// after a profile save is orchestrated by the calling screen via
/// [InsightsCubit.recalculate] to keep cubits independently testable.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository(),
      super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> load(String userId) async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    try {
      final profile = await _repository.getProfile(userId) ?? Profile.empty(userId);
      emit(state.copyWith(status: ProfileStatus.ready, profile: profile));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()));
    }
  }

  Future<Profile?> save(Profile updated) async {
    emit(state.copyWith(status: ProfileStatus.saving, errorMessage: null));
    try {
      final saved = await _repository.upsertProfile(updated);
      emit(state.copyWith(status: ProfileStatus.ready, profile: saved));
      return saved;
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()));
      return null;
    }
  }

  Future<void> updateLocale(String userId, String locale) async {
    final current = state.profile;
    if (current == null || current.id != userId || current.locale == locale) return;
    try {
      final saved = await _repository.upsertProfile(current.copyWith(locale: locale));
      emit(state.copyWith(profile: saved));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void clear() => emit(const ProfileState());
}
