import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../auth/models/UserFields.dart';

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    print("Creating database version $version...");
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT,
        username TEXT,
        password TEXT, -- Included from the start for new users
        phone TEXT,
        fullName TEXT,
        age INTEGER,
        enrolledCoursesJson TEXT,
        notificationSettingsJson TEXT,
        tokensJson TEXT
      );
    ''');

    await db.execute('CREATE TABLE courses(...)');
    await db.execute('CREATE TABLE assignments(...)');
    await db.execute('CREATE TABLE exams(...)');
    await db.execute('CREATE TABLE submissions(...)');
    await db.execute('CREATE TABLE notifications(...)');
    print("Database created successfully.");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion...");
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN ${UserFields.password} TEXT');
      } catch (e) {
        print("Error during v2 migration: $e");
      }
    }
  }
}