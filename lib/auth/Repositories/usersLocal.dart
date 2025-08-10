import 'package:sqflite/sqflite.dart';
import 'package:users/auth/Repositories/api.dart';
import 'package:users/auth/Repositories/userRepository.dart';
import 'package:users/auth/models/userModel.dart';
import '../models/UserFields.dart';



Future<void> _createDatabase(Database db, int version) async {
  return await db.execute('''
        CREATE TABLE Users (
          ${UserFields.id} ${UserFields.idType},
          ${UserFields.email} ${UserFields.textType},
          ${UserFields.password} ${UserFields.textType},
          ${UserFields.username} ${UserFields.textType},
          ${UserFields.phone} ${UserFields.textType}
          
  );
      ''');
}


class UserDatabase extends userRepository {
  static final UserDatabase instance = UserDatabase._internal();

  static Database? _database;

  var _version = 2;

  UserDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;

    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/users.db';
    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }
  Future<user> create(user _user) async {
    final db = await instance.database;
    final id = await db.insert(UserFields.tableName, _user.toJson());
    return user.fromJson(_user.toJson(),id.toString());

  }


  Future<List<user>> readAll() async {
    final db = await instance.database;
    final result = await db.query(UserFields.tableName,);
    return result.map((json) => user.fromJson(json,json[UserFields.id].toString())).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      UserFields.tableName,
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );
  }


  Future<int> update(user note) async {
    final db = await instance.database;
    return db.update(
      UserFields.tableName,
      note.toJson(),
      where: '${UserFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }


  Future<user> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      UserFields.tableName,
      columns: UserFields.values,
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return user.fromJson(maps.first, maps.first[UserFields.id].toString());
    } else {
      throw Exception('ID $id not found');
    }
  }


  Future<user?> readUser(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      UserFields.tableName,
      columns: UserFields.values,
      where: '${UserFields.username} = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return user.fromJson(maps.first, maps.first[UserFields.id].toString());
    } else {
      return null;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${UserFields.tableName} ADD COLUMN ${UserFields.phone} Text',
      );
    }
  }
  @override
  Future<int> updatePassword(user _user, String newPassword) async {
    final db = await instance.database;
    return db.update(
      UserFields.tableName,
      {UserFields.password: newPassword},
      where: '${UserFields.id} = ?',
      whereArgs: [_user.id],
    );
  }


  Future<void> enrollInCourse(String userId, String courseId)async {}
  Future<void> unenrollFromCourse(String userId, String courseId)async {}

  Future<void> addToken(String userId, String token)async {}
  Future<user?> readById(String id)async{}

}