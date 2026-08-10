import '../../core/config/api_client.dart';
import '../../model/clinic.dart';

class ClinicRepository {
  ClinicRepository({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  Future<List<Clinic>> getClinics() async {
    final json = await _client.getJson('/api/clinics');
    final rows = json?['clinics'] as List? ?? const [];
    return rows.map((r) => Clinic.fromJson(Map<String, dynamic>.from(r as Map))).toList();
  }
}
