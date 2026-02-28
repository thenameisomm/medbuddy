// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 0;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      id: fields[0] as String?,
      name: fields[1] as String,
      dosage: fields[2] as String,
      times: (fields[3] as List).cast<String>(),
      color: fields[4] as String,
      instructions: fields[5] as String? ?? '',
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime,
      notificationIds: (fields[8] as List?)?.cast<int>(),
      isActive: fields[9] as bool? ?? true,
    )..id = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.times)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.instructions)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.notificationIds)
      ..writeByte(9)
      ..write(obj.isActive);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class MedicineLogAdapter extends TypeAdapter<MedicineLog> {
  @override
  final int typeId = 1;

  @override
  MedicineLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineLog(
      id: fields[0] as String?,
      medicineId: fields[1] as String,
      medicineName: fields[2] as String,
      scheduledTime: fields[3] as DateTime,
      takenTime: fields[4] as DateTime?,
      status: fields[5] as LogStatus,
      dosage: fields[6] as String,
    )..id = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, MedicineLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicineId)
      ..writeByte(2)
      ..write(obj.medicineName)
      ..writeByte(3)
      ..write(obj.scheduledTime)
      ..writeByte(4)
      ..write(obj.takenTime)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.dosage);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class LogStatusAdapter extends TypeAdapter<LogStatus> {
  @override
  final int typeId = 2;

  @override
  LogStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LogStatus.pending;
      case 1:
        return LogStatus.taken;
      case 2:
        return LogStatus.missed;
      case 3:
        return LogStatus.skipped;
      default:
        return LogStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, LogStatus obj) {
    switch (obj) {
      case LogStatus.pending:
        writer.writeByte(0);
        break;
      case LogStatus.taken:
        writer.writeByte(1);
        break;
      case LogStatus.missed:
        writer.writeByte(2);
        break;
      case LogStatus.skipped:
        writer.writeByte(3);
        break;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
