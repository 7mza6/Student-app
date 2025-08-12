import 'package:sqflite/sqflite.dart';
import 'package:users/auth/Repositories/usersLocal.dart';

import '../../shared/services/network_info.dart';
import '../Repositories/userRepository.dart';
import '../Repositories/user_api.dart';
import '../models/userModel.dart';


class HybridUserRepository implements userRepository {
  final UserApi _remote = UserApi();
  final UserLocal _local = UserLocal();

  @override
  Future<user?> readUser(String username) async {
    if (await NetworkInfo.isOnline) {
      try {
        final remoteUser = await _remote.readUser(username);
        if (remoteUser != null) {
          await _local.create(remoteUser);
        }
        return remoteUser;
      } catch (e) {
        print("Network error on readUser, falling back to local. Error: $e");
        return _local.readUser(username);
      }
    } else {
      print("Offline: Reading user from local DB.");
      return _local.readUser(username);
    }
  }

  @override
  Future<user> create(user _user, {DatabaseExecutor? txn}) => _remote.create(_user);
  @override
  Future<user?> readById(String id) => _remote.readById(id);
  @override
  Future<List<user>> readAll() => _remote.readAll();
  @override
  Future<int> update(user _user) => _remote.update(_user);
  @override
  Future<int> updatePassword(user _user, String newPassword) => _remote.updatePassword(_user, newPassword);
  @override
  Future<int> delete(int id) => _remote.delete(id);
  @override
  Future<void> addToken(String userId, String token) => _remote.addToken(userId, token);
  @override
  Future<void> enrollInCourse(String userId, String courseId) => _remote.enrollInCourse(userId, courseId);
  @override
  Future<void> unenrollFromCourse(String userId, String courseId) => _remote.unenrollFromCourse(userId, courseId);
}