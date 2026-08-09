/// Non-web stub: reminders are stored but OS notifications are unavailable.
class HabitReminderNotify {
  static Future<bool> requestPermission() async => false;

  static Future<void> scheduleDaily({required int hour, required int minute}) async {}

  static Future<void> cancel() async {}
}
