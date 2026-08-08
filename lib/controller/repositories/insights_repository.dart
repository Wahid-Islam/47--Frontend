import '../../core/config/api_client.dart';
import '../../model/insights.dart';

/// Data access for `GET` / `PUT /api/insights`.
class InsightsRepository {
  InsightsRepository({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  Future<Insights?> getInsights(String userId) async {
    final json = await _client.getJson('/api/insights');
    if (json == null || json['payload'] == null) return null;
    return Insights.fromJson(Map<String, dynamic>.from(json['payload'] as Map));
  }

  Future<Insights> upsertInsights(String userId, Insights insights) async {
    await _client.putJson('/api/insights', {
      'payload': insights.toJson(),
      'generated_at': insights.generatedAt.toIso8601String(),
    });
    return insights;
  }
}
