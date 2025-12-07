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

  //  ADD: Performance optimizations
  final _syncQueue = <TaskRecord>[];
  Timer? _syncTimer;
  bool _isSyncing = false;
  Completer<void>? _initCompleter;

  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();

    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TaskRecordAdapter());
      }
      _box = await Hive.openBox<TaskRecord>(_boxName);
      ConnectivityService().startListening(_syncIfOnline);
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      rethrow;
    }
  }

  // OPTIMIZED: Get or create persistent device ID (cached)
  Future<String> get _getDeviceId async {
    _deviceId ??= await _getOrCreateDeviceId();
    return _deviceId!;
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('device_id');

    if (storedId == null) {
      storedId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      unawaited(prefs.setString('device_id', storedId)); // Don't await
    }

    return storedId;
  }

  String _generateKey(String deviceId, String taskType) {
    return '${deviceId}_$taskType';
  }

  //  OPTIMIZED: Save task without blocking UI
  Future<void> saveTask(String taskType, Map<String, dynamic> data) async {
    // Ensure initialization is complete
    if (_initCompleter != null) {
      await _initCompleter!.future;
    }

    final deviceId = await _getDeviceId;
    final key = _generateKey(deviceId, taskType);

    final record = TaskRecord(
      id: key,
      taskType: taskType,
      timestamp: DateTime.now(),
      data: data,
    );

    //  FAST: Save to Hive immediately (local storage is quick)
    await _box.put(key, record);

    //  OPTIMIZED: Queue for Firebase sync (non-blocking)
    _queueForSync(record);

    return; // Return immediately without waiting for sync
  }

  //  NEW: Queue system for Firebase syncs
  void _queueForSync(TaskRecord record) {
    _syncQueue.add(record);

    // Debounce sync calls - wait for multiple saves
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 1000), _processSyncQueue);
  }

  //  NEW: Process sync queue in background
  Future<void> _processSyncQueue() async {
    if (_isSyncing || _syncQueue.isEmpty) return;

    _isSyncing = true;
    final online = await ConnectivityService().isConnected();

    if (!online) {
      _isSyncing = false;
      return;
    }

    final recordsToSync = List<TaskRecord>.from(_syncQueue);
    _syncQueue.clear();

    try {
      //  OPTIMIZED: Use batch write for multiple records
      final batch = _firestore.batch();

      for (final record in recordsToSync) {
        final docRef = _firestore.collection('mcat_results').doc(record.id);
        batch.set(docRef, record.toJson());
      }

      await batch.commit();
      print(' Synced ${recordsToSync.length} records to Firebase');
    } catch (e) {
      print('xError Sync error: $e');
      // Re-add failed records to queue for retry
      _syncQueue.addAll(recordsToSync);
    } finally {
      _isSyncing = false;
    }
  }

  // Get task data for current device
  Future<TaskRecord?> getTask(String taskType) async {
    if (_initCompleter != null) {
      await _initCompleter!.future;
    }

    final deviceId = await _getDeviceId;
    final key = _generateKey(deviceId, taskType);
    return _box.get(key);
  }

  // Check if task exists for current device
  Future<bool> hasTask(String taskType) async {
    if (_initCompleter != null) {
      await _initCompleter!.future;
    }

    final deviceId = await _getDeviceId;
    final key = _generateKey(deviceId, taskType);
    return _box.containsKey(key);
  }

  // Get all records for current device
  Future<List<TaskRecord>> getAllRecords() async {
    if (_initCompleter != null) {
      await _initCompleter!.future;
    }

    final deviceId = await _getDeviceId;
    return _box.values
        .where((record) => record.id.startsWith(deviceId))
        .toList()
        .cast<TaskRecord>();
  }

  // Get all records (including from other devices if any)
  Future<List<TaskRecord>> getAllRecordsAllDevices() async {
    if (_initCompleter != null) {
      await _initCompleter!.future;
    }

    return _box.values.toList().cast<TaskRecord>();
  }

  //  OPTIMIZED: Background sync with batch operations
  Future<void> _syncIfOnline() async {
    if (_isSyncing) return;

    final online = await ConnectivityService().isConnected();
    if (!online) return;

    final unsyncedRecords = _box.values
        .where((record) => !_syncQueue.any((queued) => queued.id == record.id))
        .toList();

    if (unsyncedRecords.isNotEmpty) {
      _syncQueue.addAll(unsyncedRecords);
      unawaited(_processSyncQueue()); // Don't await
    }
  }

  // Clear all data for current device
  Future<void> clearDeviceData() async {
    if (_initCompleter != null) {
      await _initCompleter!.future;
    }

    final deviceId = await _getDeviceId;
    final keysToDelete =
        _box.keys.where((key) => key.toString().startsWith(deviceId)).toList();

    await _box.deleteAll(keysToDelete);
    _syncQueue.removeWhere((record) => record.id.startsWith(deviceId));
  }

  // Get device ID for debugging
  Future<String> getDeviceId() => _getDeviceId;

  //  NEW: Manual sync trigger
  Future<void> forceSync() async {
    await _processSyncQueue();
  }

  //  NEW: Dispose method
  void dispose() {
    _syncTimer?.cancel();
    _syncQueue.clear();
  }
}
