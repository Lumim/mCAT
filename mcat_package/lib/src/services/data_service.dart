import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/task_record.dart';
import 'connectivity_service.dart';

class DataService {
  static const String _boxName = 'mcat_results';
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  late Box<TaskRecord> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskRecordAdapter());
    _box = await Hive.openBox<TaskRecord>(_boxName);
    ConnectivityService().startListening(_syncIfOnline);
  }

  Future<void> saveTask(String taskType, Map<String, dynamic> data) async {
    final record = TaskRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskType: taskType,
      timestamp: DateTime.now(),
      data: data,
    );
    await _box.put(record.id, record);
    await _syncIfOnline();
  }

  Future<List<TaskRecord>> getAllRecords() async =>
      _box.values.toList().cast<TaskRecord>();

  Future<void> _syncIfOnline() async {
    final online = await ConnectivityService().isConnected();
    if (!online) return;
    for (final record in _box.values) {
      await _firestore
          .collection('mcat_results')
          .doc(record.id)
          .set(record.toJson());
    }
  }
}
