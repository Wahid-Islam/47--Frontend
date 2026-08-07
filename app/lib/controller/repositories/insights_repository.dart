import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../core/config/supabase_config.dart';
import '../../model/insights.dart';

/// Data access for the `public.insights` table (one row per user, unique
/// on `user_id`, payload stored as `jsonb`).
class InsightsRepository {
  InsightsRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<Insights?> getInsights(String userId) async {
    final row = await _client.from('insights').select().eq('user_id', userId).maybeSingle();
    if (row == null || row['payload'] == null) return null;
    return Insights.fromJson(Map<String, dynamic>.from(row['payload'] as Map));
  }

  Future<Insights> upsertInsights(String userId, Insights insights) async {
    await _client.from('insights').upsert({
      'user_id': userId,
      'payload': insights.toJson(),
      'generated_at': insights.generatedAt.toIso8601String(),
    }, onConflict: 'user_id');
    return insights;
  }
}
