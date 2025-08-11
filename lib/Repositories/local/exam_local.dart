import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'app_db.dart';
import '../../Repositories/exam_repository.dart';
import '../../Models/exam_model.dart';

class ExamLocal implements ExamRepository {
  Future<Database> get _db async => AppDb.instance.database;

  @override
  Future<Exam> create(String courseId, Exam exam,{DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    await db.insert(
      'exams',
      { 'id': exam.id, 'courseId': courseId, 'dataJson': jsonEncode(exam.toMap()) },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return exam;
  }

  @override
  Future<List<Exam>> readAllForCourse(String courseId) async {
    final db = await _db;
    final rows = await db.query('exams', where: 'courseId = ?', whereArgs: [courseId]);
    return rows.map((m) {
      final map = Map<String, dynamic>.from(jsonDecode(m['dataJson'] as String));
      return Exam.fromMap(map, m['id'] as String);
    }).toList();
  }

  @override
  Future<int> update(String courseId, Exam exam) async {
    await create(courseId, exam);
    return 1;
  }

  @override
  Future<int> delete(String examId) async {
    final db = await _db;
    return await db.delete('exams', where: 'id = ?', whereArgs: [examId]);
  }

  Future<void> upsertMany(String courseId, List<Exam> exams, {DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    final batch = db.batch();
    for (final e in exams) {
      batch.insert(
        'exams',
        { 'id': e.id, 'courseId': courseId, 'dataJson': jsonEncode(e.toMap()) },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}