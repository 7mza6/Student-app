import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../assignment_repository.dart';
import 'app_db.dart';
import '../../Models/assignment_model.dart';

class AssignmentLocal implements AssignmentRepository {
  Future<Database> get _db async => AppDb.instance.database;

  @override
  Future<Assignment> create(String courseId, Assignment assignment,{DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    await db.insert(
      'assignments',
      {
        'id': assignment.id,
        'courseId': courseId,
        'dataJson': jsonEncode(assignment.toMap()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return assignment;
  }

  @override
  Future<List<Assignment>> readAllForCourse(String courseId) async {
    final db = await _db;
    final rows = await db.query('assignments', where: 'courseId = ?', whereArgs: [courseId]);

    return rows.map((m) {
      final json = m['dataJson'] as String? ?? '{}';
      final map = Map<String, dynamic>.from(jsonDecode(json));
      final id = m['id'] as String? ?? '';
      return Assignment.fromMap(map, id);
    }).toList();
  }

  @override
  Future<int> update(String courseId, Assignment assignment) async {
    await create(courseId, assignment);
    return 1;
  }

  @override
  Future<int> delete(String assignmentId) async {
    final db = await _db;
    return await db.delete('assignments', where: 'id = ?', whereArgs: [assignmentId]);
  }

  Future<void> upsertMany(String courseId, List<Assignment> list, {DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    final batch = db.batch();
    for (final a in list) {
      batch.insert(
        'assignments',
        { 'id': a.id, 'courseId': courseId, 'dataJson': jsonEncode(a.toMap()) },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}