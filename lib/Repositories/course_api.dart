import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';

import 'package:uuid/uuid.dart';
import '../Models/Course-model.dart';
import '../services/network_info.dart';
import 'course_repository.dart';
import 'local/courseLocal.dart';

class CourseApi implements CourseRepository {
  static final FirebaseDatabase database = FirebaseDatabase.instance;
  final DatabaseReference _coursesRef = database.ref('courses');

  final _local = CourseLocal();
  final _uuid = const Uuid();

  @override
  Future<Course> create(Course course,{DatabaseExecutor? txn}) async {
    final courseWithId = course.id == null || course.id!.isEmpty
        ? course.copyWith(id: _uuid.v4())
        : course;

    await _local.create(courseWithId);

    if (await NetworkInfo.isOnline) {
      try {
        await _coursesRef.child(courseWithId.id!).set(course.toMap());
      } catch (e) {
        print("Network error on Course create, saved locally. Error: $e");
      }
    }
    return courseWithId;
  }

  @override
  Future<List<Course>> readAll() async {
    if (await NetworkInfo.isOnline) {
      try {
        final List<Course> remoteCourses = [];
        final snapshot = await _coursesRef.get();
        if (snapshot.exists && snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          data.forEach((courseId, courseData) {
            final courseMap = Map<String, dynamic>.from(courseData);
            remoteCourses.add(Course.fromMap(courseMap, courseId));
          });
        }
        await _local.upsertMany(remoteCourses);
        return remoteCourses;
      } catch (e) {
        print("Network error on Course readAll, falling back to local. Error: $e");
        return _local.readAll();
      }
    } else {
      print("Offline: Reading all Courses from local DB.");
      return _local.readAll();
    }
  }

  @override
  Future<int> update(Course course) async {
    final localResult = await _local.update(course);
    if (await NetworkInfo.isOnline) {
      try {
        if (course.id != null) {
          await _coursesRef.child(course.id!).update(course.toMap());
        }
      } catch (e) {
        print("Network error on Course update, saved locally. Error: $e");
      }
    }
    return localResult;
  }

  @override
  Future<int> delete(String courseId) async {
    final localResult = await _local.delete(courseId);
    if (await NetworkInfo.isOnline) {
      try {
        await _coursesRef.child(courseId).remove();
      } catch (e) {
        print("Network error on Course delete, deleted locally. Error: $e");
      }
    }
    return localResult;
  }
}