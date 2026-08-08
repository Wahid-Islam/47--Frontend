import '../../core/config/api_client.dart';
import '../../model/profile.dart';

/// Data access for `GET` / `PUT /api/profile`.
class ProfileRepository {
  ProfileRepository({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  Future<Profile?> getProfile(String userId) async {
    final json = await _client.getJson('/api/profile');
    if (json == null) return null;
    // The API always returns the caller's profile; [userId] is kept for
    // call-site compatibility with the previous Supabase signature.
    final profile = Profile.fromJson(json);
    if (profile.id != userId && userId.isNotEmpty) {
      // Defensive: never surface another user's row if the token somehow
      // disagreed (should be impossible with the current API).
      return null;
    }
    return profile;
  }

  Future<Profile> upsertProfile(Profile profile) async {
    final json = await _client.putJson('/api/profile', profile.toJson());
    if (json == null) throw ApiException(500, 'Empty profile response');
    return Profile.fromJson(json);
  }
}
