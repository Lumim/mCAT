// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskRecordAdapter extends TypeAdapter<TaskRecord> {
  @override
  final int typeId = 1;

  @override
  TaskRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskRecord(
      id: fields[0] as String,
      taskType: fields[1] as String,
      timestamp: fields[2] as DateTime,
      data: (fields[3] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, TaskRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskType)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
