import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/task_record.dart';
import 'connectivity_service.dart';

class DataService {
  static const String _boxName = 'mcat_results';
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  late Box<TaskRecord> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _deviceId;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskRecordAdapter());
    _box = await Hive.openBox<TaskRecord>(_boxName);
    ConnectivityService().startListening(_syncIfOnline);
  }

  // Get or create persistent device ID
  Future<String> get _getDeviceId async {
    _deviceId ??= await _getOrCreateDeviceId();
    return _deviceId!;
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('device_id');

    if (storedId == null) {
      storedId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', storedId);
    }

    return storedId;
  }

  // Generate unique key for device + task type combination
  String _generateKey(String deviceId, String taskType) {
    return '${deviceId}_$taskType';
  }

  // ✅ MAIN METHOD: Save or update task data
  Future<void> saveTask(String taskType, Map<String, dynamic> data) async {
    final deviceId = await _getDeviceId;
    final key = _generateKey(deviceId, taskType);

    final record = TaskRecord(
      id: key, // Use composite key as ID
      taskType: taskType,
      timestamp: DateTime.now(),
      data: data,
    );

    await _box.put(key, record); // Auto creates or updates
    await _syncIfOnline();
  }

  // Get task data for current device
  Future<TaskRecord?> getTask(String taskType) async {
    final deviceId = await _getDeviceId;
    final key = _generateKey(deviceId, taskType);
    return _box.get(key);
  }

  // Check if task exists for current device
  Future<bool> hasTask(String taskType) async {
    final deviceId = await _getDeviceId;
    final key = _generateKey(deviceId, taskType);
    return _box.containsKey(key);
  }

  // Get all records for current device
  Future<List<TaskRecord>> getAllRecords() async {
    final deviceId = await _getDeviceId;
    return _box.values
        .where((record) => record.id.startsWith(deviceId))
        .toList()
        .cast<TaskRecord>();
  }

  // Get all records (including from other devices if any)
  Future<List<TaskRecord>> getAllRecordsAllDevices() async =>
      _box.values.toList().cast<TaskRecord>();

  Future<void> _syncIfOnline() async {
    final online = await ConnectivityService().isConnected();
    if (!online) return;

    for (final record in _box.values) {
      try {
        await _firestore
            .collection('mcat_results')
            .doc(record.id) // Use the composite key as document ID
            .set(record.toJson());
      } catch (e) {
        print('Sync error for record ${record.id}: $e');
      }
    }
  }

  // Clear all data for current device
  Future<void> clearDeviceData() async {
    final deviceId = await _getDeviceId;
    final keysToDelete =
        _box.keys.where((key) => key.toString().startsWith(deviceId)).toList();

    await _box.deleteAll(keysToDelete);
  }

  // Get device ID for debugging
  Future<String> getDeviceId() => _getDeviceId;
}
