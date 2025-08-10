import '../models/userModel.dart';

abstract class userRepository {
  Future<user> create(user _user);
  Future<user?> readUser(String username);
  Future<user?> readById(String id);
  Future<List<user>> readAll();
  Future<int> update(user _user);
  Future<int> updatePassword(user _user, String newPassword);
  Future<int> delete(int id);
  Future<void> addToken(String userId, String token);
  Future<void> enrollInCourse(String userId, String courseId);
  Future<void> unenrollFromCourse(String userId, String courseId);
}