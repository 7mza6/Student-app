import 'package:firebase_database/firebase_database.dart';
import '../Models/Course-model.dart';
import 'course_repository.dart';

class CourseApi extends CourseRepository {
  static final FirebaseDatabase database = FirebaseDatabase.instance;
  final DatabaseReference _coursesRef = database.ref('courses');

  @override
  Future<Course> create(Course course) async {
    final newRef = _coursesRef.push();
    await newRef.set(course.toMap());

    return Course(
      id: newRef.key,
      icon: course.icon,
      title: course.title,
      status: course.status,
      progress: course.progress,
      teacherId: course.teacherId,
      enrolledStudents: course.enrolledStudents,
    );
  }

  @override
  Future<List<Course>> readAll() async {
    final List<Course> courses = [];
    try {
      final snapshot = await _coursesRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((courseId, courseData) {
          final courseMap = Map<String, dynamic>.from(courseData);
          courses.add(Course.fromMap(courseMap, courseId));
        });
      }
    } catch (e) {
      print('Error reading all courses: $e');
    }
    return courses;
  }

  @override
  Future<int> update(Course course) async {
    if (course.id == null || course.id!.isEmpty) {
      print('Error: Course ID is null or empty, cannot update.');
      return 0;
    }
    try {
      await _coursesRef.child(course.id!).update(course.toMap());
      return 1;
    } catch (e) {
      print('Error updating course ${course.id}: $e');
      return 0;
    }
  }

  @override
  Future<int> delete(String courseId) async {
    try {
      await _coursesRef.child(courseId).remove();
      return 1;
    } catch (e) {
      print('Error deleting course $courseId: $e');
      return 0;
    }
  }
}