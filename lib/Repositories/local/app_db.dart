// lib/Repositories/local/app_db.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  static final AppDb instance = AppDb._();
  AppDb._();
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = join(dir, 'student_offline.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _create,
    );
    return _db!;
  }

  Future<void> _create(Database db, int v) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY, email TEXT, username TEXT, phone TEXT,
        fullName TEXT, age INTEGER, enrolledCoursesJson TEXT,
        notificationSettingsJson TEXT, tokensJson TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE courses(
        id TEXT PRIMARY KEY, icon TEXT, title TEXT, status TEXT,
        progress REAL, teacherId TEXT, enrolledStudentsJson TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE assignments(
        id TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        dataJson TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE exams(
        id TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        dataJson TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE submissions(
        id TEXT PRIMARY KEY, courseId TEXT NOT NULL, taskId TEXT NOT NULL,
        type TEXT NOT NULL, studentId TEXT NOT NULL, content TEXT,
        submittedAt INTEGER NOT NULL, grade REAL, answersJson TEXT,
        UNIQUE(courseId, taskId, type, studentId)
      );
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id TEXT PRIMARY KEY, userId TEXT NOT NULL, title TEXT, body TEXT,
        timestamp INTEGER NOT NULL, isRead INTEGER NOT NULL
      );
    ''');
  }
}