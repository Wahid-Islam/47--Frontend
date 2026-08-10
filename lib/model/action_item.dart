import 'package:equatable/equatable.dart';

import '../core/l10n/localized.dart';

class ActionCta extends Equatable {
  const ActionCta({
    required this.type,
    required this.label,
    required this.labelBm,
    this.labelZh = '',
  });

  /// 'clinic' | 'habit'
  final String type;
  final String label;
  final String labelBm;
  final String labelZh;

  factory ActionCta.fromJson(Map<String, dynamic> json) {
    return ActionCta(
      type: json['type']?.toString() ?? 'habit',
      label: json['label']?.toString() ?? '',
      labelBm: json['labelBm']?.toString() ?? json['label_bm']?.toString() ?? '',
      labelZh: json['labelZh']?.toString() ?? json['label_zh']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    'labelBm': labelBm,
    'labelZh': labelZh,
  };

  String localizedLabel(String locale) =>
      localizedText(locale, en: label, bm: labelBm, zh: labelZh);

  @override
  List<Object?> get props => [type, label, labelBm, labelZh];
}

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
    this.titleZh = '',
    this.descriptionZh = '',
    this.priorityScore,
  });

  final String id;
  final String title;
  final String titleBm;
  final String titleZh;
  final String description;
  final String descriptionBm;
  final String descriptionZh;
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
      titleZh: json['titleZh']?.toString() ?? json['title_zh']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionBm: json['descriptionBm']?.toString() ?? json['description_bm']?.toString() ?? '',
      descriptionZh: json['descriptionZh']?.toString() ?? json['description_zh']?.toString() ?? '',
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
      'titleZh': titleZh,
      'description': description,
      'descriptionBm': descriptionBm,
      'descriptionZh': descriptionZh,
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
      titleZh: titleZh,
      description: description,
      descriptionBm: descriptionBm,
      descriptionZh: descriptionZh,
      category: category,
      impact: impact,
      timeMinutes: timeMinutes,
      targets: targets,
      habitIds: habitIds,
      cta: cta,
      priorityScore: priorityScore ?? this.priorityScore,
    );
  }

  String localizedTitle(String locale) =>
      localizedText(locale, en: title, bm: titleBm, zh: titleZh);

  String localizedDescription(String locale) =>
      localizedText(locale, en: description, bm: descriptionBm, zh: descriptionZh);

  @override
  List<Object?> get props => [
    id,
    title,
    titleBm,
    titleZh,
    description,
    descriptionBm,
    descriptionZh,
    category,
    impact,
    timeMinutes,
    targets,
    habitIds,
    cta,
    priorityScore,
  ];
}

class HabitCatalogItem extends Equatable {
  const HabitCatalogItem({
    required this.id,
    required this.title,
    required this.titleBm,
    this.titleZh = '',
  });

  final String id;
  final String title;
  final String titleBm;
  final String titleZh;

  factory HabitCatalogItem.fromJson(Map<String, dynamic> json) {
    return HabitCatalogItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleBm: json['titleBm']?.toString() ?? json['title_bm']?.toString() ?? '',
      titleZh: json['titleZh']?.toString() ?? json['title_zh']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'titleBm': titleBm,
    'titleZh': titleZh,
  };

  String localizedTitle(String locale) =>
      localizedText(locale, en: title, bm: titleBm, zh: titleZh);

  @override
  List<Object?> get props => [id, title, titleBm, titleZh];
}
