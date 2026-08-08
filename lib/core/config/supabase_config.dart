import 'package:supabase_flutter/supabase_flutter.dart';

/// Central configuration for the Supabase backend.
///
/// The anon (publishable) key is safe to ship in a client application: all
/// data access is protected by Postgres Row Level Security policies defined
/// on the `profiles`, `insights`, `habit_logs` and `clinics` tables. See
/// `docs/DATABASE.md` for the schema and policy reference.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://loqwoiizinnshwrgaunj.supabase.co';

  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxvcXdvaWl6aW5uc2h3cmdhdW5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU3NDE2NTIsImV4cCI6MjEwMTMxNzY1Mn0.2_CiQUTYSj2C2zdg8FBJxf1EJ32Ad4--lsw1d8lVAo4';

  /// Initializes the Supabase client. Must be called once before [runApp].
  static Future<void> initialize() {
    return Supabase.initialize(url: url, publishableKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
