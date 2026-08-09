import '../../core/config/api_client.dart';
import '../../model/habit.dart';

/// Data access for `GET` / `PUT /api/habits/today`.
class HabitRepository {
  HabitRepository({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  String _dateKey(DateTime date) => date.toIso8601String().substring(0, 10);

  Future<HabitLogRow> getOrCreateForDate(String userId, DateTime date) async {
    final json = await _client.getJson('/api/habits/today', query: {'date': _dateKey(date)});
    if (json == null) throw ApiException(500, 'Empty habit log response');
    return HabitLogRow.fromJson(json);
  }

  Future<HabitLogRow> setCompletedIds(String userId, DateTime date, List<String> completedHabitIds) async {
    final json = await _client.putJson('/api/habits/today', {
      'date': _dateKey(date),
      'completed_habit_ids': completedHabitIds,
    });
    if (json == null) throw ApiException(500, 'Empty habit log response');
    return HabitLogRow.fromJson(json);
  }

  /// Recent logs for streak / day-by-day risk (includes today when present).
  Future<List<HabitLogRow>> listRecent({int days = 7}) async {
    final json = await _client.getJson('/api/habits/history', query: {'days': '$days'});
    if (json == null) return const [];
    final logs = json['logs'] as List? ?? const [];
    return logs.map((e) => HabitLogRow.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
}
