import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../shared/Repositories/app_db.dart';
import 'submission_repository.dart';
import '../models/submission_model.dart';

class SubmissionLocal implements SubmissionRepository {
  Future<Database> get _db async => AppDb.instance.database;

  Map<String, Object?> _toDb(String courseId, String taskId, String type, Submission s) => {
    'id': s.id, 'courseId': courseId, 'taskId': taskId, 'type': type,
    'studentId': s.studentId, 'content': s.content,
    'submittedAt': s.submittedAt.millisecondsSinceEpoch, 'grade': s.grade,
    'answersJson': s.answers != null ? jsonEncode(s.answers) : null,
  };

  Submission _fromDb(Map<String, Object?> m) => Submission(
    id: m['id'] as String?,
    studentId: (m['studentId'] as String?) ?? '',
    content: (m['content'] as String?) ?? '',
    submittedAt: DateTime.fromMillisecondsSinceEpoch((m['submittedAt'] as int?) ?? 0),
    grade: (m['grade'] as num?)?.toDouble(),
    answers: (m['answersJson'] as String?) != null
        ? Map<String, dynamic>.from(jsonDecode(m['answersJson'] as String)) : null,
  );

  @override
  Future<Submission> create(String courseId, String taskId, String type, Submission s,{DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    await db.insert('submissions', _toDb(courseId, taskId, type, s), conflictAlgorithm: ConflictAlgorithm.replace);
    return s;
  }

  @override
  Future<List<Submission>> readAllForTask(String courseId, String taskId, String type) async {
    final db = await _db;
    final rows = await db.query('submissions', where: 'courseId=? AND taskId=? AND type=?', whereArgs: [courseId, taskId, type], orderBy: 'submittedAt DESC');
    return rows.map(_fromDb).toList();
  }

  @override
  Future<Submission?> readForStudent(String courseId, String taskId, String type, String studentId) async {
    final db = await _db;
    final rows = await db.query('submissions', where: 'courseId=? AND taskId=? AND type=? AND studentId=?', whereArgs: [courseId, taskId, type, studentId], limit: 1);
    return rows.isNotEmpty ? _fromDb(rows.first) : null;
  }

  @override
  Future<int> update(String courseId, String taskId, String type, Submission s) async {
    final db = await _db;
    return db.update('submissions', _toDb(courseId, taskId, type, s), where: 'id=?', whereArgs: [s.id]);
  }

  @override
  Future<int> delete(String courseId, String taskId, String type, String submissionId) async {
    final db = await _db;
    return db.delete('submissions', where: 'id=?', whereArgs: [submissionId]);
  }

  Future<void> upsertMany(String courseId, String taskId, String type, List<Submission> submissions, {DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    final batch = db.batch();
    for (final s in submissions) {
      batch.insert('submissions', _toDb(courseId, taskId, type, s), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}