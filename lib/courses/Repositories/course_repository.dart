
  import 'package:sqflite/sqflite.dart';

import '../Models/Course-model.dart';

  abstract class CourseRepository {
    Future<Course> create(Course course,{DatabaseExecutor? txn});
    Future<List<Course>> readAll();
    Future<int> update(Course course);
    Future<int> delete(String courseId);
  }