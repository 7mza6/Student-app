
import 'package:flutter/material.dart';
import '../Models/Course-model.dart';
import '../Repositories/courseLocal.dart';
import '../Repositories/course_api.dart';




Future<List<Course>> _fetchCoursesFromDatabase() async {
  // Simulate a network delay of 1.5 seconds
  await Future.delayed(const Duration(milliseconds: 1500));

  // This is where you would query your database and map the results
  // to a List<Course>. We return hardcoded data for this example.
  return [
    Course(
      icon: '⚙️',
      title: 'Advanced React Development: Hooks & Context API',
      status: CourseStatus.inProgress,
      progress: 0.75,
    ),
    Course(
      icon: '👨‍💻',
      title: 'Full-Stack Web with Node.js & Express',
      status: CourseStatus.completed,
      progress: 1.0,
    ),
    Course(
      icon: '🤖',
      title: 'Introduction to Machine Learning with Python',
      status: CourseStatus.inProgress,
      progress: 0.20,
    ),
    Course(
      icon: '📊',
      title: 'Data Science Fundamentals: Statistics & Visualization',
      status: CourseStatus.upcoming,
      progress: 0.0,
    ),
    Course(
      icon: '☁️',
      title: 'Cloud Computing Essentials: AWS & Azure',
      status: CourseStatus.overdue,
      progress: 0.50,
    ),
  ];
}


Future<List<Course>> fetchCoursesFromDatabase() async {
  final CourseApi courseApi = CourseApi();
  try {
    final List<Course> courses = await courseApi.readAll();
    print("Successfully fetched ${courses.length} courses.");
    return courses;
  } catch (e) {
    print("An error occurred while fetching courses from the API: $e");
    return []; // Return an empty list to avoid UI errors.
  }
}


Future<void> insertTestData() async {
  print("--- Starting Test Data Insertion ---");

  final CourseApi courseApi = CourseApi();

  final List<Course> testCourses = [
    Course(
      icon: '⚙️',
      title: 'Advanced React Development: Hooks & Context API',
      status: CourseStatus.inProgress,
      progress: 0.75,
    ),
    Course(
      icon: '👨‍💻',
      title: 'Full-Stack Web with Node.js & Express',
      status: CourseStatus.completed,
      progress: 1.0,
    ),
    Course(
      icon: '🤖',
      title: 'Introduction to Machine Learning with Python',
      status: CourseStatus.inProgress,
      progress: 0.20,
    ),
    Course(
      icon: '📊',
      title: 'Data Science Fundamentals: Statistics & Visualization',
      status: CourseStatus.upcoming,
      progress: 0.0,
    ),
    Course(
      icon: '☁️',
      title: 'Cloud Computing Essentials: AWS & Azure',
      status: CourseStatus.overdue,
      progress: 0.50,
    ),
  ];

  // Loop through the list and create each course in Firebase.
  for (final course in testCourses) {
    try {
      final createdCourse = await courseApi.create(course);
      print("SUCCESS: Created course '${createdCourse.title}' with ID: ${createdCourse.id}");
    } catch (e) {
      print("ERROR: Failed to create course '${course.title}'. Reason: $e");
    }
  }

  print("--- Test Data Insertion Complete ---");
}

