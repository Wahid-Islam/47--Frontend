import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';
import 'auth_state.dart';

export 'auth_state.dart';

/// Owns the Supabase auth session lifecycle: login, register, demo login,
/// logout, and exposes whether onboarding is complete for router redirects.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthRepository? authRepository, ProfileRepository? profileRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      _profileRepository = profileRepository ?? ProfileRepository(),
      super(const AuthState()) {
    _bootstrap();
  }

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  StreamSubscription<supa.AuthState>? _subscription;

  void _bootstrap() {
    final current = _authRepository.currentUser;
    if (current != null) {
      unawaited(_loadSession(current));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, userId: null, email: null));
    }
    _subscription = _authRepository.onAuthStateChange.listen((event) {
      final user = event.session?.user;
      if (user == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            userId: null,
            email: null,
            onboardingComplete: false,
          ),
        );
      } else {
        unawaited(_loadSession(user));
      }
    });
  }

  Future<void> _loadSession(supa.User user) async {
    try {
      final profile = await _profileRepository.getProfile(user.id);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.id,
          email: user.email,
          onboardingComplete: profile?.onboardingComplete ?? false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.id,
          email: user.email,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(busy: true, errorMessage: null));
    try {
      await _authRepository.signIn(email: email, password: password);
      emit(state.copyWith(busy: false));
    } on supa.AuthException catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.message));
      rethrow;
    } catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.toString()));
      rethrow;
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    emit(state.copyWith(busy: true, errorMessage: null));
    try {
      await _authRepository.register(email: email, password: password, fullName: fullName);
      emit(state.copyWith(busy: false));
    } on supa.AuthException catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.message));
      rethrow;
    } catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.toString()));
      rethrow;
    }
  }

  Future<void> demoLogin() async {
    emit(state.copyWith(busy: true, errorMessage: null));
    try {
      await _authRepository.demoSignIn();
      emit(state.copyWith(busy: false));
    } catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.toString()));
      rethrow;
    }
  }

  /// Called once the profile wizard finishes saving, so the router can
  /// redirect to the home shell without waiting for another DB round trip.
  void markOnboardingComplete() {
    if (state.status == AuthStatus.authenticated) {
      emit(state.copyWith(onboardingComplete: true));
    }
  }

  Future<void> logout() => _authRepository.signOut();

  @override
  Future<void> close() {
    final subscription = _subscription;
    if (subscription != null) unawaited(subscription.cancel());
    return super.close();
  }
}
