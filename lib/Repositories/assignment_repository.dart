import 'package:sqflite/sqflite.dart';

import '../Models/assignment_model.dart'; // Adjust path to your Assignment model

abstract class AssignmentRepository {

  Future<Assignment> create(String courseId, Assignment assignment,{DatabaseExecutor? txn});

  Future<List<Assignment>> readAllForCourse(String courseId);

  Future<int> update(String courseId, Assignment assignment);

  Future<int> delete(String assignmentId);
}