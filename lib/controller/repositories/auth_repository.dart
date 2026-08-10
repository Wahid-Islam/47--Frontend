import '../../core/config/api_client.dart';
import '../../model/profile.dart';
import '../services/risk_engine.dart';
import 'insights_repository.dart';
import 'profile_repository.dart';

class AuthRepository {
  AuthRepository({
    ApiClient? client,
    ProfileRepository? profileRepository,
    InsightsRepository? insightsRepository,
  }) : _client = client ?? apiClient,
       _profileRepository = profileRepository ?? ProfileRepository(client: client ?? apiClient),
       _insightsRepository =
           insightsRepository ?? InsightsRepository(client: client ?? apiClient);

  final ApiClient _client;
  final ProfileRepository _profileRepository;
  final InsightsRepository _insightsRepository;

  static const String demoEmail = 'lim.weijian@healthpath.demo';
  static const String demoPassword = 'demo1234';

  Future<AuthSession?> restoreSession() async {
    if (!_client.hasToken) return null;
    try {
      final json = await _client.getJson('/api/auth/me');
      if (json == null) return null;
      return AuthSession.fromJson(json);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _client.clearToken();
        return null;
      }
      rethrow;
    }
  }

  Future<AuthSession> signIn({required String email, required String password}) async {
    final json = await _client.postJson('/api/auth/login', {
      'email': email,
      'password': password,
    });
    return _persistSession(json);
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final json = await _client.postJson('/api/auth/register', {
      'email': email,
      'password': password,
      'full_name': fullName,
    });
    return _persistSession(json);
  }

  Future<AuthSession> demoSignIn() async {
    final json = await _client.postJson('/api/auth/demo');
    final session = await _persistSession(json);

    final existing = await _profileRepository.getProfile(session.userId);
    final profile = existing ?? Profile.demo(session.userId, email: demoEmail);
    final insights = RiskEngine.compute(profile);
    await _insightsRepository.upsertInsights(session.userId, insights);

    return session;
  }

  Future<void> signOut() => _client.clearToken();

  Future<AuthSession> _persistSession(Map<String, dynamic>? json) async {
    if (json == null) throw ApiException(500, 'Empty auth response');
    final token = json['token']?.toString();
    if (token == null || token.isEmpty) throw ApiException(500, 'Auth response missing token');
    await _client.setToken(token);
    return AuthSession.fromJson(json);
  }
}

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    this.profile,
  });

  final String userId;
  final String email;
  final Profile? profile;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = Map<String, dynamic>.from(json['user'] as Map? ?? const {});
    final profileJson = json['profile'];
    return AuthSession(
      userId: user['id']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      profile: profileJson is Map
          ? Profile.fromJson(Map<String, dynamic>.from(profileJson))
          : null,
    );
  }
}
