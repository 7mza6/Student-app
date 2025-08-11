import 'package:sqflite/sqflite.dart';

import '../Models/exam_model.dart'; // Adjust path to your Exam model


abstract class ExamRepository {

  Future<Exam> create(String courseId, Exam exam,{DatabaseExecutor? txn});

  Future<List<Exam>> readAllForCourse(String courseId);

  Future<int> update(String courseId, Exam exam);

  Future<int> delete(String examId);
}