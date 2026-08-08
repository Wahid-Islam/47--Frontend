import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../core/config/supabase_config.dart';
import '../../model/profile.dart';
import '../services/risk_engine.dart';
import 'insights_repository.dart';
import 'profile_repository.dart';

/// Auth + onboarding bootstrap on top of Supabase Auth.
///
/// A Postgres trigger auto-creates a `profiles` row on signup, but this
/// repository still performs a safety-net upsert after register/demo
/// sign-in so the app never depends on trigger timing.
class AuthRepository {
  AuthRepository({
    supa.SupabaseClient? client,
    ProfileRepository? profileRepository,
    InsightsRepository? insightsRepository,
  }) : _client = client ?? SupabaseConfig.client,
       _profileRepository = profileRepository ?? ProfileRepository(client: client ?? SupabaseConfig.client),
       _insightsRepository =
           insightsRepository ?? InsightsRepository(client: client ?? SupabaseConfig.client);

  final supa.SupabaseClient _client;
  final ProfileRepository _profileRepository;
  final InsightsRepository _insightsRepository;

  static const String demoEmail = 'lim.weijian@healthpath.demo';
  static const String demoPassword = 'demo1234';

  Stream<supa.AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  supa.User? get currentUser => _client.auth.currentUser;

  Future<supa.AuthResponse> signIn({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<supa.AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(email: email, password: password);
    final user = response.user;
    if (user != null) {
      final existing = await _profileRepository.getProfile(user.id);
      final base = existing ?? Profile.empty(user.id, email: email);
      await _profileRepository.upsertProfile(base.copyWith(fullName: fullName, email: email));
    }
    return response;
  }

  /// Signs in as the canned demo user (creating the account on first use),
  /// applies the Lim Wei Jian profile, and recalculates + saves insights.
  Future<supa.AuthResponse> demoSignIn() async {
    supa.AuthResponse response;
    try {
      response = await signIn(email: demoEmail, password: demoPassword);
    } on supa.AuthException {
      response = await _client.auth.signUp(email: demoEmail, password: demoPassword);
    }

    final user = response.user;
    if (user != null) {
      await _bootstrapDemoProfile(user.id);
    }
    return response;
  }

  Future<void> _bootstrapDemoProfile(String userId) async {
    final existing = await _profileRepository.getProfile(userId);
    // Preserve a previously-customised demo account instead of clobbering it.
    final profile = (existing != null && existing.onboardingComplete)
        ? existing
        : await _profileRepository.upsertProfile(Profile.demo(userId, email: demoEmail));
    final insights = RiskEngine.compute(profile);
    await _insightsRepository.upsertInsights(userId, insights);
  }

  Future<void> signOut() => _client.auth.signOut();
}
