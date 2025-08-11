import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../Repositories/local/pending_operation_local.dart';
import '../Repositories/submission_api.dart'; // To call the actual API
import '../Models/submission_model.dart';
import '../services/network_info.dart';

class SyncService {
  final _pendingOpLocal = PendingOperationLocal();
  final _submissionApi = SubmissionApi();

  // A simple flag to prevent multiple syncs from running at once.
  static bool _isSyncing = false;

  void startListening() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        print("Network connection detected. Attempting to sync pending operations...");
        processPendingOperations();
      }
    });
  }

  Future<void> processPendingOperations() async {
    if (_isSyncing || !(await NetworkInfo.isOnline)) return;
    _isSyncing = true;

    final pendingOps = await _pendingOpLocal.readAll();
    if (pendingOps.isEmpty) {
      print("No pending operations to sync.");
      _isSyncing = false;
      return;
    }

    print("Found ${pendingOps.length} pending operations. Starting sync...");
    for (final op in pendingOps) {
      bool success = false;
      try {
        if (op.type == 'create_submission') {
          final payload = jsonDecode(op.payload) as Map<String, dynamic>;
          final courseId = payload['courseId'] as String;
          final taskId = payload['taskId'] as String;
          final type = payload['type'] as String;
          final submission = Submission.fromMap(payload['submission'], '');

          await _submissionApi.create(courseId, taskId, type, submission);
          success = true;
        }

      } catch (e) {
        print("Failed to sync operation ID ${op.id}. Error: $e");
      }

      if (success) {
        await _pendingOpLocal.delete(op.id!);
        print("Successfully synced and removed operation ID ${op.id}.");
      }
    }

    print("Sync process finished.");
    _isSyncing = false;
  }
}