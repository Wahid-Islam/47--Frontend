// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

/// Browser Notification-based daily reminder for Flutter web.
class HabitReminderNotify {
  static Timer? _timer;

  static Future<bool> requestPermission() async {
    if (!html.Notification.supported) return false;
    final permission = html.Notification.permission;
    if (permission == 'granted') return true;
    if (permission == 'denied') return false;
    final result = await html.Notification.requestPermission();
    return result == 'granted';
  }

  static Future<void> scheduleDaily({required int hour, required int minute}) async {
    _timer?.cancel();
    void tick() {
      final now = DateTime.now();
      var next = DateTime(now.year, now.month, now.day, hour, minute);
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
      final wait = next.difference(now);
      _timer = Timer(wait, () {
        if (html.Notification.permission == 'granted') {
          html.Notification(
            'MySihat — daily habits',
            body: 'Time for today’s 4 health actions. Small steps lower your Health Age.',
          );
        }
        // Reschedule for the following day.
        scheduleDaily(hour: hour, minute: minute);
      });
    }

    tick();
  }

  static Future<void> cancel() async {
    _timer?.cancel();
    _timer = null;
  }
}
