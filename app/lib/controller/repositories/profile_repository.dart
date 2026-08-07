import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../core/config/supabase_config.dart';
import '../../model/profile.dart';

/// Data access for the `public.profiles` table. Row Level Security scopes
/// every query to `auth.uid()`, so callers only ever see their own row.
class ProfileRepository {
  ProfileRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<Profile?> getProfile(String userId) async {
    final row = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (row == null) return null;
    return Profile.fromJson(row);
  }

  Future<Profile> upsertProfile(Profile profile) async {
    final row = await _client.from('profiles').upsert(profile.toJson()).select().single();
    return Profile.fromJson(row);
  }
}
