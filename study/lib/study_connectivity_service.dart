import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub; // Fixed type

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