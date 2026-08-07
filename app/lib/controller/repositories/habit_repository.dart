import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../core/config/supabase_config.dart';
import '../../model/habit.dart';

/// Data access for the `public.habit_logs` table: one row per user per
/// calendar day, holding the list of completed habit ids for that day.
class HabitRepository {
  HabitRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  String _dateKey(DateTime date) => date.toIso8601String().substring(0, 10);

  Future<HabitLogRow> getOrCreateForDate(String userId, DateTime date) async {
    final key = _dateKey(date);
    final existing = await _client
        .from('habit_logs')
        .select()
        .eq('user_id', userId)
        .eq('log_date', key)
        .maybeSingle();
    if (existing != null) return HabitLogRow.fromJson(existing);

    final inserted = await _client
        .from('habit_logs')
        .insert({'user_id': userId, 'log_date': key, 'completed_habit_ids': <String>[]})
        .select()
        .single();
    return HabitLogRow.fromJson(inserted);
  }

  Future<HabitLogRow> setCompletedIds(String userId, DateTime date, List<String> completedHabitIds) async {
    final key = _dateKey(date);
    final row = await _client
        .from('habit_logs')
        .update({'completed_habit_ids': completedHabitIds})
        .eq('user_id', userId)
        .eq('log_date', key)
        .select()
        .single();
    return HabitLogRow.fromJson(row);
  }
}
