import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../core/config/supabase_config.dart';

/// Data access for the `public.questionnaire_responses` table: an
/// append-only audit trail of every onboarding/profile-wizard submission
/// (US 1.1), kept separate from the mutable `profiles` row so historical
/// answers are never overwritten. Row Level Security scopes both insert
/// and select to `auth.uid() = user_id`.
class QuestionnaireRepository {
  QuestionnaireRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  /// Inserts one questionnaire snapshot row. [answers] is stored as-is in
  /// the `answers` jsonb column.
  Future<void> submit({required String userId, required Map<String, dynamic> answers}) async {
    await _client.from('questionnaire_responses').insert({'user_id': userId, 'answers': answers});
  }
}
