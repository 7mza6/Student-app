
  import '../Models/Course-model.dart';

  abstract class CourseRepository {
    Future<Course> create(Course course);
    Future<List<Course>> readAll();
    Future<int> update(Course course);
    Future<int> delete(String courseId);
  }