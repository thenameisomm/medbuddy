import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';
import 'notification_service.dart';

class MedicineService {
  static const String _medicineBox = 'medicines';
  static const String _logBox = 'medicine_logs';

  static Box<Medicine>? _medicines;
  static Box<MedicineLog>? _logs;

  static Future<void> init() async {
    _medicines = await Hive.openBox<Medicine>(_medicineBox);
    _logs = await Hive.openBox<MedicineLog>(_logBox);
  }

  static Box<Medicine> get medicines => _medicines!;
  static Box<MedicineLog> get logs => _logs!;

  // ─── Medicines ───────────────────────────────────────────────

  static Future<void> addMedicine(Medicine medicine) async {
    // Schedule notifications and store IDs
    final ids =
        await NotificationService().scheduleMedicineNotifications(medicine);
    medicine.notificationIds = ids;
    await _medicines!.put(medicine.id, medicine);

    // Pre-create log entries for today
    _createTodayLogs(medicine);
  }

  static Future<void> updateMedicine(Medicine medicine) async {
    // Cancel old notifications
    await NotificationService()
        .cancelMedicineNotifications(medicine.notificationIds);

    // Reschedule
    final ids =
        await NotificationService().scheduleMedicineNotifications(medicine);
    medicine.notificationIds = ids;
    await medicine.save();
  }

  static Future<void> deleteMedicine(String id) async {
    final medicine = _medicines!.get(id);
    if (medicine != null) {
      await NotificationService()
          .cancelMedicineNotifications(medicine.notificationIds);
      await medicine.delete();
    }

    // Remove related logs
    final toDelete = _logs!.values
        .where((l) => l.medicineId == id)
        .map((l) => l.id)
        .toList();
    for (final logId in toDelete) {
      await _logs!.delete(logId);
    }
  }

  static List<Medicine> getAllMedicines() {
    return _medicines!.values.where((m) => m.isActive).toList();
  }

  // ─── Logs ────────────────────────────────────────────────────

  static void _createTodayLogs(Medicine medicine) {
    final today = DateTime.now();
    for (final timeStr in medicine.times) {
      final parts = timeStr.split(':');
      final scheduled = DateTime(
        today.year,
        today.month,
        today.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // Only create if within medicine date range and not already exists
      if (scheduled.isAfter(medicine.startDate.subtract(const Duration(days: 1))) &&
          scheduled.isBefore(medicine.endDate.add(const Duration(days: 1)))) {
        final log = MedicineLog(
          medicineId: medicine.id,
          medicineName: medicine.name,
          scheduledTime: scheduled,
          status: LogStatus.pending,
          dosage: medicine.dosage,
        );
        _logs!.put(log.id, log);
      }
    }
  }

  static void ensureTodayLogs() {
    final medicines = getAllMedicines();
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    for (final med in medicines) {
      for (final timeStr in med.times) {
        final parts = timeStr.split(':');
        final scheduled = DateTime(
          today.year,
          today.month,
          today.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        // Check if log already exists for this time today
        final exists = _logs!.values.any((l) =>
            l.medicineId == med.id &&
            l.scheduledTime.year == today.year &&
            l.scheduledTime.month == today.month &&
            l.scheduledTime.day == today.day &&
            l.scheduledTime.hour == scheduled.hour &&
            l.scheduledTime.minute == scheduled.minute);

        if (!exists &&
            scheduled.isAfter(
                med.startDate.subtract(const Duration(days: 1))) &&
            scheduled
                .isBefore(med.endDate.add(const Duration(days: 1)))) {
          final log = MedicineLog(
            medicineId: med.id,
            medicineName: med.name,
            scheduledTime: scheduled,
            status: LogStatus.pending,
            dosage: med.dosage,
          );
          _logs!.put(log.id, log);
        }
      }
    }

    // Mark past pending logs as missed
    final now = DateTime.now();
    for (final log in _logs!.values) {
      if (log.status == LogStatus.pending &&
          log.scheduledTime.isBefore(now.subtract(const Duration(minutes: 30)))) {
        log.status = LogStatus.missed;
        log.save();
      }
    }
  }

  static List<MedicineLog> getLogsForDate(DateTime date) {
    return _logs!.values
        .where((l) =>
            l.scheduledTime.year == date.year &&
            l.scheduledTime.month == date.month &&
            l.scheduledTime.day == date.day)
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  static Future<void> markAsTaken(String logId) async {
    final log = _logs!.get(logId);
    if (log != null) {
      log.status = LogStatus.taken;
      log.takenTime = DateTime.now();
      await log.save();
    }
  }

  static Future<void> markAsSkipped(String logId) async {
    final log = _logs!.get(logId);
    if (log != null) {
      log.status = LogStatus.skipped;
      await log.save();
    }
  }

  // ─── Stats ───────────────────────────────────────────────────

  static Map<String, dynamic> getWeeklyStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekLogs = _logs!.values
        .where((l) => l.scheduledTime.isAfter(weekAgo))
        .toList();

    final total = weekLogs.length;
    final taken = weekLogs.where((l) => l.status == LogStatus.taken).length;
    final missed = weekLogs.where((l) => l.status == LogStatus.missed).length;
    final skipped = weekLogs.where((l) => l.status == LogStatus.skipped).length;

    return {
      'total': total,
      'taken': taken,
      'missed': missed,
      'skipped': skipped,
      'adherence': total > 0 ? (taken / total * 100).roundToDouble() : 0.0,
    };
  }

  static List<Map<String, dynamic>> getDailyAdherence({int days = 30}) {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLogs = getLogsForDate(date);
      final total = dayLogs.length;
      final taken = dayLogs.where((l) => l.status == LogStatus.taken).length;

      result.add({
        'date': date,
        'total': total,
        'taken': taken,
        'adherence': total > 0 ? taken / total : 0.0,
      });
    }

    return result;
  }
}
