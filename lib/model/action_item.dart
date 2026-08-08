import 'package:equatable/equatable.dart';

/// Call-to-action metadata attached to an [ActionItem], e.g. "book a
/// clinic visit" vs. "track a daily habit".
class ActionCta extends Equatable {
  const ActionCta({required this.type, required this.label, required this.labelBm});

  /// 'clinic' | 'habit'
  final String type;
  final String label;
  final String labelBm;

  factory ActionCta.fromJson(Map<String, dynamic> json) {
    return ActionCta(
      type: json['type']?.toString() ?? 'habit',
      label: json['label']?.toString() ?? '',
      labelBm: json['labelBm']?.toString() ?? json['label_bm']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'label': label, 'labelBm': labelBm};

  String localizedLabel(String locale) => locale == 'bm' && labelBm.isNotEmpty ? labelBm : label;

  @override
  List<Object?> get props => [type, label, labelBm];
}

/// A recommended preventive action (from the static catalog or a computed
/// insights payload's `topActions`).
class ActionItem extends Equatable {
  const ActionItem({
    required this.id,
    required this.title,
    required this.titleBm,
    required this.description,
    required this.descriptionBm,
    required this.category,
    required this.impact,
    required this.timeMinutes,
    required this.targets,
    required this.habitIds,
    required this.cta,
    this.priorityScore,
  });

  final String id;
  final String title;
  final String titleBm;
  final String description;
  final String descriptionBm;
  final String category;
  final String impact; // low | medium | high
  final int timeMinutes;
  final List<String> targets;
  final List<String> habitIds;
  final ActionCta cta;
  final int? priorityScore;

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleBm: json['titleBm']?.toString() ?? json['title_bm']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionBm: json['descriptionBm']?.toString() ?? json['description_bm']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      impact: json['impact']?.toString() ?? 'medium',
      timeMinutes: (json['timeMinutes'] as num?)?.toInt() ?? (json['time_minutes'] as num?)?.toInt() ?? 0,
      targets: (json['targets'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      habitIds:
          (json['habitIds'] as List?)?.map((e) => e.toString()).toList() ??
          (json['habit_ids'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      cta: json['cta'] is Map
          ? ActionCta.fromJson(Map<String, dynamic>.from(json['cta'] as Map))
          : const ActionCta(type: 'habit', label: '', labelBm: ''),
      priorityScore: (json['priorityScore'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleBm': titleBm,
      'description': description,
      'descriptionBm': descriptionBm,
      'category': category,
      'impact': impact,
      'timeMinutes': timeMinutes,
      'targets': targets,
      'habitIds': habitIds,
      'cta': cta.toJson(),
      if (priorityScore != null) 'priorityScore': priorityScore,
    };
  }

  ActionItem copyWith({int? priorityScore}) {
    return ActionItem(
      id: id,
      title: title,
      titleBm: titleBm,
      description: description,
      descriptionBm: descriptionBm,
      category: category,
      impact: impact,
      timeMinutes: timeMinutes,
      targets: targets,
      habitIds: habitIds,
      cta: cta,
      priorityScore: priorityScore ?? this.priorityScore,
    );
  }

  String localizedTitle(String locale) => locale == 'bm' && titleBm.isNotEmpty ? titleBm : title;

  String localizedDescription(String locale) =>
      locale == 'bm' && descriptionBm.isNotEmpty ? descriptionBm : description;

  @override
  List<Object?> get props => [
    id,
    title,
    titleBm,
    description,
    descriptionBm,
    category,
    impact,
    timeMinutes,
    targets,
    habitIds,
    cta,
    priorityScore,
  ];
}

/// A single entry from the daily habit catalog (e.g. "Walk 20 minutes").
class HabitCatalogItem extends Equatable {
  const HabitCatalogItem({required this.id, required this.title, required this.titleBm});

  final String id;
  final String title;
  final String titleBm;

  factory HabitCatalogItem.fromJson(Map<String, dynamic> json) {
    return HabitCatalogItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleBm: json['titleBm']?.toString() ?? json['title_bm']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'titleBm': titleBm};

  String localizedTitle(String locale) => locale == 'bm' && titleBm.isNotEmpty ? titleBm : title;

  @override
  List<Object?> get props => [id, title, titleBm];
}
