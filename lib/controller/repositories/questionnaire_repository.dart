import '../../core/config/api_client.dart';

/// Append-only questionnaire audit trail via `POST /api/questionnaire`.
class QuestionnaireRepository {
  QuestionnaireRepository({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  Future<void> submit({required String userId, required Map<String, dynamic> answers}) async {
    await _client.postJson('/api/questionnaire', {'answers': answers});
  }
}
