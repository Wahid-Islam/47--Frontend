import 'package:shared_preferences/shared_preferences.dart';

import 'habit_reminder_notify.dart';

/// Stores and applies a daily reminder for roadmap habits.
class HabitReminderService {
  HabitReminderService._();

  static const _enabledKey = 'habit_reminder_enabled';
  static const _hourKey = 'habit_reminder_hour';
  static const _minuteKey = 'habit_reminder_minute';

  static Future<({bool enabled, int hour, int minute})> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      enabled: prefs.getBool(_enabledKey) ?? false,
      hour: prefs.getInt(_hourKey) ?? 9,
      minute: prefs.getInt(_minuteKey) ?? 0,
    );
  }

  static Future<void> save({required bool enabled, required int hour, required int minute}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);
    if (enabled) {
      await HabitReminderNotify.requestPermission();
      await HabitReminderNotify.scheduleDaily(hour: hour, minute: minute);
    } else {
      await HabitReminderNotify.cancel();
    }
  }
}
