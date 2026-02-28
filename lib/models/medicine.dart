import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String dosage; // e.g. "500mg", "1 tablet"

  @HiveField(3)
  late List<String> times; // e.g. ["08:00", "14:00", "21:00"]

  @HiveField(4)
  late String color; // hex color for pill card

  @HiveField(5)
  late String instructions; // e.g. "After meals", "With water"

  @HiveField(6)
  late DateTime startDate;

  @HiveField(7)
  late DateTime endDate;

  @HiveField(8)
  late List<int> notificationIds;

  @HiveField(9)
  late bool isActive;

  Medicine({
    String? id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.color,
    this.instructions = '',
    required this.startDate,
    required this.endDate,
    List<int>? notificationIds,
    this.isActive = true,
  }) {
    this.id = id ?? const Uuid().v4();
    this.notificationIds = notificationIds ?? [];
  }
}

@HiveType(typeId: 1)
class MedicineLog extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String medicineId;

  @HiveField(2)
  late String medicineName;

  @HiveField(3)
  late DateTime scheduledTime;

  @HiveField(4)
  late DateTime? takenTime;

  @HiveField(5)
  late LogStatus status;

  @HiveField(6)
  late String dosage;

  MedicineLog({
    String? id,
    required this.medicineId,
    required this.medicineName,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    required this.dosage,
  }) {
    this.id = id ?? const Uuid().v4();
  }
}

@HiveType(typeId: 2)
enum LogStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  taken,
  @HiveField(2)
  missed,
  @HiveField(3)
  skipped,
}
