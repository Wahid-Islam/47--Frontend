import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

const Object _unset = Object();

/// State for [AuthCubit]. Tracks the Supabase session plus the
/// `onboarding_complete` flag (read from the user's profile) so `go_router`
/// can redirect between onboarding, the profile wizard, and the home shell.
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.email,
    this.onboardingComplete = false,
    this.busy = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? userId;
  final String? email;
  final bool onboardingComplete;
  final bool busy;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated && userId != null;

  AuthState copyWith({
    AuthStatus? status,
    Object? userId = _unset,
    Object? email = _unset,
    bool? onboardingComplete,
    bool? busy,
    Object? errorMessage = _unset,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: identical(userId, _unset) ? this.userId : userId as String?,
      email: identical(email, _unset) ? this.email : email as String?,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      busy: busy ?? this.busy,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, userId, email, onboardingComplete, busy, errorMessage];
}
