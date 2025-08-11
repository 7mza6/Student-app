import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:users/auth/Repositories/userRepository.dart';
import '../../Repositories/local/app_db.dart';
import '../models/userModel.dart';


class UserLocal implements userRepository {
  Future<Database> get _db async => AppDb.instance.database;

  Map<String, Object?> _toDb(user u) => {
    'id': u.id.toString(),
    'email': u.email,
    'username': u.username,
    'phone': u.phone,
    'fullName': u.fullName,
    'age': u.age,
    'enrolledCoursesJson': jsonEncode(u.enrolledCourses),
    'notificationSettingsJson': jsonEncode(u.notificationSettings),
    'tokensJson': jsonEncode(u.tokens),
  };

  user _fromDb(Map<String, Object?> m) {
    return user(
      id: int.tryParse(m['id'] as String? ?? '0'),
      email: m['email'] as String?,
      username: m['username'] as String?,
      phone: m['phone'] as String?,
      fullName: m['fullName'] as String?,
      age: m['age'] as int?,
      enrolledCourses: m['enrolledCoursesJson'] != null ? List<String>.from(jsonDecode(m['enrolledCoursesJson'] as String)) : [],
      notificationSettings: m['notificationSettingsJson'] != null ? Map<String, bool>.from(jsonDecode(m['notificationSettingsJson'] as String)) : null,
      tokens: m['tokensJson'] != null ? List<String>.from(jsonDecode(m['tokensJson'] as String)) : [],
      password: '',
    );
  }

  // --- CORRECTED IMPLEMENTATION of `create` ---
  @override
  Future<user> create(user _user, {DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    await db.insert('users', _toDb(_user),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return _user;
  }

  // --- No changes needed below this line for the lock issue ---

  @override
  Future<user?> readById(String id) async {
    final db = await _db;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isNotEmpty ? _fromDb(rows.first) : null;
  }

  @override
  Future<user?> readUser(String username) async {
    final db = await _db;
    final rows = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    return rows.isNotEmpty ? _fromDb(rows.first) : null;
  }

  @override
  Future<List<user>> readAll() async {
    final db = await _db;
    final rows = await db.query('users');
    return rows.map(_fromDb).toList();
  }

  @override
  Future<int> update(user _user) async {
    final db = await _db;
    return await db.update('users', _toDb(_user),
        where: 'id = ?', whereArgs: [_user.id.toString()]);
  }

  @override
  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete('users', where: 'id = ?', whereArgs: [id.toString()]);
  }

  @override
  Future<void> addToken(String userId, String token) async {
    final existingUser = await readById(userId);
    if (existingUser != null && !existingUser.tokens.contains(token)) {
      final updatedTokens = List<String>.from(existingUser.tokens)..add(token);
      await update(existingUser.copyWith(tokens: updatedTokens));
    }
  }

  @override
  Future<void> enrollInCourse(String userId, String courseId) async {
    final existingUser = await readById(userId);
    if (existingUser != null && !existingUser.enrolledCourses.contains(courseId)) {
      final updatedCourses = List<String>.from(existingUser.enrolledCourses)..add(courseId);
      await update(existingUser.copyWith(enrolledCourses: updatedCourses));
    }
  }

  @override
  Future<void> unenrollFromCourse(String userId, String courseId) async {
    final existingUser = await readById(userId);
    if (existingUser != null && existingUser.enrolledCourses.contains(courseId)) {
      final updatedCourses = List<String>.from(existingUser.enrolledCourses)..remove(courseId);
      await update(existingUser.copyWith(enrolledCourses: updatedCourses));
    }
  }

  @override
  Future<int> updatePassword(user _user, String newPassword) {
    return Future.value(1);
  }
}