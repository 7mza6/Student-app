import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../Models/assignment_model.dart';
import '../Repositories/assignment_repository.dart';
import '../services/network_info.dart';
import 'local/assignment_local.dart';

class AssignmentApi implements AssignmentRepository {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  final _local = AssignmentLocal();
  final _uuid = const Uuid();

  DatabaseReference _ref(String courseId) => _database.ref('courses/$courseId/assignments');

  @override
  Future<Assignment> create(String courseId, Assignment assignment,{DatabaseExecutor? txn}) async {
    final assignmentWithId = assignment.id.isEmpty
        ? assignment.copyWith(id: _uuid.v4())
        : assignment;

    await _local.create(courseId, assignmentWithId);

    if (await NetworkInfo.isOnline) {
      try {
        await _ref(courseId).child(assignmentWithId.id).set(assignment.toMap());
      } catch (e) {
        print("Network error on Assignment create, saved locally. Error: $e");
      }
    }
    return assignmentWithId;
  }

  @override
  Future<List<Assignment>> readAllForCourse(String courseId) async {
    if (await NetworkInfo.isOnline) {
      try {
        final List<Assignment> remoteAssignments = [];
        final snapshot = await _ref(courseId).get();
        if (snapshot.exists && snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          data.forEach((id, assignmentData) {
            final map = Map<String, dynamic>.from(assignmentData);
            remoteAssignments.add(Assignment.fromMap(map, id));
          });
        }
        await _local.upsertMany(courseId, remoteAssignments);
        return remoteAssignments;
      } catch (e) {
        print("Network error on Assignment readAll, falling back to local. Error: $e");
        return _local.readAllForCourse(courseId);
      }
    } else {
      print("Offline: Reading all Assignments for course from local DB.");
      return _local.readAllForCourse(courseId);
    }
  }

  @override
  Future<int> update(String courseId, Assignment assignment) async {
    final localResult = await _local.update(courseId, assignment);
    if (await NetworkInfo.isOnline) {
      try {
        await _ref(courseId).child(assignment.id).update(assignment.toMap());
      } catch (e) {
        print("Network error on Assignment update, saved locally. Error: $e");
      }
    }
    return localResult;
  }

  @override
  Future<int> delete(String assignmentId) async {
    return await _local.delete(assignmentId);
  }
}