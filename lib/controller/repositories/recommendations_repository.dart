import '../../core/config/api_client.dart';
import '../../core/l10n/localized.dart';
import '../../model/action_item.dart';
import '../services/recommendation_engine.dart';

class RecommendationsResult {
  const RecommendationsResult({
    required this.habits,
    this.coachNote = '',
    this.coachNoteBm = '',
    this.coachNoteZh = '',
  });

  final List<HabitRecommendation> habits;
  final String coachNote;
  final String coachNoteBm;
  final String coachNoteZh;

  String localizedCoachNote(String locale) =>
      localizedText(locale, en: coachNote, bm: coachNoteBm, zh: coachNoteZh);
}

class RecommendationsRepository {
  RecommendationsRepository({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  Future<RecommendationsResult?> fetch() async {
    try {
      final json = await _client.getJson('/api/recommendations/rf');
      if (json == null) return null;
      return _parse(json);
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 500) return null;
      rethrow;
    }
  }

  RecommendationsResult _parse(Map<String, dynamic> json) {
    final habitsRaw = json['habits'] as List? ?? const [];
    final habits = <HabitRecommendation>[];
    for (final raw in habitsRaw) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final id = map['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      habits.add(
        HabitRecommendation(
          habit: HabitCatalogItem(
            id: id,
            title: map['title']?.toString() ?? id,
            titleBm: map['title_bm']?.toString() ?? map['titleBm']?.toString() ?? map['title']?.toString() ?? id,
            titleZh: map['title_zh']?.toString() ?? map['titleZh']?.toString() ?? '',
          ),
          score: (map['score'] as num?)?.toDouble() ?? 1,
          reasonEn: map['reason']?.toString() ?? '',
          reasonBm: map['reason_bm']?.toString() ?? map['reasonBm']?.toString() ?? '',
          reasonZh: map['reason_zh']?.toString() ?? map['reasonZh']?.toString() ?? '',
          category: map['category']?.toString() ?? 'HABIT',
        ),
      );
    }
    return RecommendationsResult(
      habits: habits.take(4).toList(),
      coachNote: json['coach_note']?.toString() ?? '',
      coachNoteBm: json['coach_note_bm']?.toString() ?? '',
      coachNoteZh: json['coach_note_zh']?.toString() ?? '',
    );
  }
}
