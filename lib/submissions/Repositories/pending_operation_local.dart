import 'package:sqflite/sqflite.dart';
import '../../shared/Repositories/app_db.dart';
import '../models/pending_operation_model.dart';

class PendingOperationLocal {
  Future<Database> get _db async => AppDb.instance.database;

  Future<void> create(PendingOperation op,{DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    await db.insert('pending_operations', op.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PendingOperation>> readAll() async {
    final db = await _db;
    final rows = await db.query('pending_operations', orderBy: 'createdAt ASC');
    return rows.map(PendingOperation.fromMap).toList();
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('pending_operations', where: 'id = ?', whereArgs: [id]);
  }
}