import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/app_strings.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      read: json['read'] == true,
    );
  }
}

/// Local inbox of past in-app / reminder notifications (newest first).
class NotificationInbox {
  NotificationInbox._();

  static const _storageKey = 'hp_notification_inbox';
  static const _maxItems = 40;

  static Future<List<AppNotification>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
    }
  }

  static Future<void> add({
    required String title,
    required String body,
    String? id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await list();
    final item = AppNotification(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      createdAt: DateTime.now(),
    );
    final next = [item, ...existing].take(_maxItems).toList();
    await prefs.setString(_storageKey, jsonEncode(next.map((e) => e.toJson()).toList()));
  }

  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await list();
    if (existing.isEmpty) return;
    final next = existing.map((e) => e.copyWith(read: true)).toList();
    await prefs.setString(_storageKey, jsonEncode(next.map((e) => e.toJson()).toList()));
  }

  static Future<int> unreadCount() async {
    final items = await list();
    return items.where((e) => !e.read).length;
  }

  /// Convenience: record a localized reminder notification in the inbox.
  static Future<void> addReminderFired({String locale = 'en'}) async {
    await add(
      title: AppStrings.t('reminderNotifyTitle', locale),
      body: AppStrings.t('reminderNotifyBody', locale),
      id: 'reminder_${DateTime.now().toIso8601String()}',
    );
  }
}
