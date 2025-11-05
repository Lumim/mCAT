import 'package:hive/hive.dart';
part 'task_record.g.dart';

@HiveType(typeId: 1)
class TaskRecord {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String taskType; // e.g. "word_recall"
  @HiveField(2)
  final DateTime timestamp;
  @HiveField(3)
  final Map<String, dynamic> data; // flexible payload

  TaskRecord({
    required this.id,
    required this.taskType,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskType': taskType,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
      };

  factory TaskRecord.fromJson(Map<String, dynamic> json) => TaskRecord(
        id: json['id'],
        taskType: json['taskType'],
        timestamp: DateTime.parse(json['timestamp']),
        data: Map<String, dynamic>.from(json['data']),
      );
}
