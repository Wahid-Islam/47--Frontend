import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config/api_client.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';
import 'auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthRepository? authRepository, ProfileRepository? profileRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      _profileRepository = profileRepository ?? ProfileRepository(),
      super(const AuthState()) {
    unawaited(_bootstrap());
  }

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  Future<void> _bootstrap() async {
    try {
      final session = await _authRepository.restoreSession();
      if (session == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated, userId: null, email: null));
        return;
      }
      await _emitAuthenticated(session);
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          userId: null,
          email: null,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _emitAuthenticated(AuthSession session) async {
    try {
      final profile = session.profile ?? await _profileRepository.getProfile(session.userId);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          userId: session.userId,
          email: session.email,
          onboardingComplete: profile?.onboardingComplete ?? false,
          busy: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          userId: session.userId,
          email: session.email,
          busy: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(busy: true, errorMessage: null));
    try {
      final session = await _authRepository.signIn(email: email, password: password);
      await _emitAuthenticated(session);
    } on ApiException catch (e) {
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
      final session = await _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      await _emitAuthenticated(session);
    } on ApiException catch (e) {
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
      final session = await _authRepository.demoSignIn();
      await _emitAuthenticated(session);
    } on ApiException catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.message));
      rethrow;
    } catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.toString()));
      rethrow;
    }
  }

  void markOnboardingComplete() {
    if (state.status == AuthStatus.authenticated) {
      emit(state.copyWith(onboardingComplete: true));
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        userId: null,
        email: null,
        onboardingComplete: false,
        busy: false,
        errorMessage: null,
      ),
    );
  }
}
