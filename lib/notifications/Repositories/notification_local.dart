import 'package:sqflite/sqflite.dart';
import '../../shared/Repositories/app_db.dart';
import '../models/notification_model.dart';
import 'notification_repository.dart';

class NotificationLocal implements NotificationRepository {
  Future<Database> get _db async => AppDb.instance.database;

  Map<String, Object?> _toDb(String userId, NotificationModel n) => {
    'id': n.id, 'userId': userId, 'title': n.title, 'body': n.body,
    'timestamp': n.timestamp.millisecondsSinceEpoch, 'isRead': n.isRead ? 1 : 0,
  };

  NotificationModel _fromDb(Map<String, Object?> m) => NotificationModel(
    id: m['id'] as String?,
    title: (m['title'] as String?) ?? '',
    body: (m['body'] as String?) ?? '',
    timestamp: DateTime.fromMillisecondsSinceEpoch((m['timestamp'] as int?) ?? 0),
    isRead: (m['isRead'] as int?) == 1,
  );

  @override
  Future<NotificationModel> create(String userId, NotificationModel n,{DatabaseExecutor? txn}) async {
    final db = await _db;
    await db.insert('notifications', _toDb(userId, n), conflictAlgorithm: ConflictAlgorithm.replace);
    return n;
  }

  @override
  Future<List<NotificationModel>> readAllForUser(String userId) async {
    final db = await _db;
    final rows = await db.query('notifications', where: 'userId=?', whereArgs: [userId], orderBy: 'timestamp DESC');
    return rows.map(_fromDb).toList();
  }

  @override
  Future<int> update(String userId, NotificationModel n,{DatabaseExecutor? txn}) async {
    final db = await _db;
    return db.update('notifications', _toDb(userId, n), where: 'id=? AND userId=?', whereArgs: [n.id, userId]);
  }

  @override
  Future<int> delete(String userId, String id) async {
    final db = await _db;
    return db.delete('notifications', where: 'id=? AND userId=?', whereArgs: [id, userId]);
  }

  Future<void> upsertMany(String userId, List<NotificationModel> notifications, {DatabaseExecutor? txn}) async {
    final db = txn ?? await _db;
    final batch = db.batch();
    for (final n in notifications) {
      batch.insert('notifications', _toDb(userId, n), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}