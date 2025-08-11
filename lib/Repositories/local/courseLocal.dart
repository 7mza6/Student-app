import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'app_db.dart';
import '../../Repositories/course_repository.dart';
import '../../Models/Course-model.dart';

class CourseLocal implements CourseRepository {
  Future<Database> get _db async => AppDb.instance.database;

  Map<String, Object?> _toDb(Course c) => {
    'id': c.id,
    'icon': c.icon,
    'title': c.title,
    'status': c.status.name,
    'progress': c.progress,
    'teacherId': c.teacherId,
    'enrolledStudentsJson': jsonEncode(c.enrolledStudents),
  };

  Course _fromDb(Map<String, Object?> m) {
    final enrolled = m['enrolledStudentsJson'] != null
        ? List<String>.from(jsonDecode(m['enrolledStudentsJson'] as String))
        : <String>[];
    final statusStr = (m['status'] as String?) ?? 'upcoming';
    final status = CourseStatus.values.firstWhere((e) => e.name == statusStr, orElse: () => CourseStatus.upcoming);

    return Course(
      id: m['id'] as String?,
      icon: (m['icon'] as String?) ?? '📚',
      title: (m['title'] as String?) ?? 'Untitled Course',
      status: status,
      progress: (m['progress'] as num?)?.toDouble() ?? 0.0,
      teacherId: (m['teacherId'] as String?) ?? '',
      enrolledStudents: enrolled,
    );
  }

  @override
  Future<Course> create(Course course,{DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    await db.insert('courses', _toDb(course),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return course;
  }

  @override
  Future<List<Course>> readAll() async {
    final db = await _db;
    final rows = await db.query('courses', orderBy: 'title');
    return rows.map(_fromDb).toList();
  }

  @override
  Future<int> update(Course course) async {
    final db = await _db;
    return db.update('courses', _toDb(course),
        where: 'id = ?', whereArgs: [course.id]);
  }

  @override
  Future<int> delete(String courseId) async {
    final db = await _db;
    return db.delete('courses', where: 'id = ?', whereArgs: [courseId]);
  }

  Future<void> upsertMany(List<Course> courses, {DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    final batch = db.batch();
    for(final course in courses) {
      batch.insert('courses', _toDb(course), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}