import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:users/auth/Repositories/userRepository.dart';
import '../../Repositories/local/app_db.dart';
import '../models/userModel.dart';
import '../models/UserFields.dart';

class UserLocal implements userRepository {
  Future<Database> get _db async => AppDb.instance.database;

  Map<String, Object?> _toDb(user u) => {
    UserFields.id: u.id.toString(),
    UserFields.email: u.email,
    UserFields.username: u.username,
    UserFields.password: u.password,
    UserFields.phone: u.phone,
    UserFields.fullName: u.fullName,
    UserFields.age: u.age,
    'enrolledCoursesJson': jsonEncode(u.enrolledCourses),
    'notificationSettingsJson': jsonEncode(u.notificationSettings),
    'tokensJson': jsonEncode(u.tokens),
  };

  user _fromDb(Map<String, Object?> m) {
    return user(
      id: int.tryParse(m[UserFields.id] as String? ?? '0'),
      email: m[UserFields.email] as String?,
      username: m[UserFields.username] as String?,
      password: m[UserFields.password] as String?,
      phone: m[UserFields.phone] as String?,
      fullName: m[UserFields.fullName] as String?,
      age: m[UserFields.age] as int?,
      enrolledCourses: m['enrolledCoursesJson'] != null ? List<String>.from(jsonDecode(m['enrolledCoursesJson'] as String)) : [],
      notificationSettings: m['notificationSettingsJson'] != null ? Map<String, bool>.from(jsonDecode(m['notificationSettingsJson'] as String)) : null,
      tokens: m['tokensJson'] != null ? List<String>.from(jsonDecode(m['tokensJson'] as String)) : [],
    );
  }

  @override
  Future<user> create(user _user, {DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    await db.insert('users', _toDb(_user),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return _user;
  }

  @override
  Future<user?> readById(String id) async {
    final db = await _db;
    final rows = await db.query('users', where: '${UserFields.id} = ?', whereArgs: [id], limit: 1);
    return rows.isNotEmpty ? _fromDb(rows.first) : null;
  }

  @override
  Future<user?> readUser(String username) async {
    final db = await _db;
    final rows = await db.query('users', where: '${UserFields.username} = ?', whereArgs: [username], limit: 1);
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
        where: '${UserFields.id} = ?', whereArgs: [_user.id.toString()]);
  }

  @override
  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete('users', where: '${UserFields.id} = ?', whereArgs: [id.toString()]);
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
  Future<int> updatePassword(user _user, String newPassword) async {
    final db = await _db;
    return await db.update(
      'users',
      {UserFields.password: newPassword},
      where: '${UserFields.id} = ?',
      whereArgs: [_user.id.toString()],
    );
  }
}