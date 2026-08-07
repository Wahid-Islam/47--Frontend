import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../core/config/supabase_config.dart';
import '../../model/clinic.dart';

/// Data access for the public `public.clinics` table (readable by anyone,
/// including anonymous/unauthenticated users, per RLS policy).
class ClinicRepository {
  ClinicRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<List<Clinic>> getClinics() async {
    final rows = await _client.from('clinics').select();
    return (rows as List).map((r) => Clinic.fromJson(Map<String, dynamic>.from(r as Map))).toList();
  }
}
