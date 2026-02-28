import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../models/medicine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'medicine_reminders',
          channelName: 'Medicine Reminders',
          channelDescription: 'Reminders to take your medicine',
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          criticalAlerts: true,
        ),
      ],
      debug: false,
    );

    await AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Badge,
        NotificationPermission.Vibration,
        NotificationPermission.CriticalAlert,
        NotificationPermission.PreciseAlarms,
      ],
    );
  }

  Future<List<int>> scheduleMedicineNotifications(Medicine medicine) async {
    final List<int> ids = [];
    final now = DateTime.now();
    DateTime current =
        medicine.startDate.isBefore(now) ? now : medicine.startDate;
    int idCounter = DateTime.now().millisecondsSinceEpoch % 10000;

    final scheduleEnd =
        medicine.endDate.isBefore(current.add(const Duration(days: 7)))
            ? medicine.endDate
            : current.add(const Duration(days: 7));

    while (current.isBefore(scheduleEnd) ||
        current.isAtSameMomentAs(scheduleEnd)) {
      for (final timeStr in medicine.times) {
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final scheduledDate = DateTime(
          current.year,
          current.month,
          current.day,
          hour,
          minute,
        );

        if (scheduledDate.isAfter(DateTime.now())) {
          final id = idCounter++;
          try {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: id,
                channelKey: 'medicine_reminders',
                title: '💊 Time for ${medicine.name}',
                body:
                    '${medicine.dosage}${medicine.instructions.isNotEmpty ? " — ${medicine.instructions}" : ""}',
                notificationLayout: NotificationLayout.Default,
                category: NotificationCategory.Alarm,
                wakeUpScreen: true,
                fullScreenIntent: true,
                autoDismissible: false,
                criticalAlert: true,
              ),
              actionButtons: [
                NotificationActionButton(
                  key: 'TAKEN',
                  label: '✅ Mark Taken',
                  autoDismissible: true,
                ),
                NotificationActionButton(
                  key: 'SNOOZE',
                  label: '⏰ Snooze 10min',
                  autoDismissible: true,
                ),
              ],
              schedule: NotificationCalendar(
                year: scheduledDate.year,
                month: scheduledDate.month,
                day: scheduledDate.day,
                hour: scheduledDate.hour,
                minute: scheduledDate.minute,
                second: 0,
                millisecond: 0,
                preciseAlarm: true,
                allowWhileIdle: true,
              ),
            );
            ids.add(id);
          } catch (e) {
            // continue scheduling others if one fails
          }
        }
      }
      current = current.add(const Duration(days: 1));
    }
    return ids;
  }

  Future<void> cancelMedicineNotifications(List<int> ids) async {
    for (final id in ids) {
      try {
        await AwesomeNotifications().cancel(id);
      } catch (_) {}
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
    } catch (_) {}
  }
}
