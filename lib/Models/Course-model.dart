import 'package:flutter/material.dart';

// The enum defines the possible states for a course.
enum CourseStatus {
  inProgress,
  completed,
  upcoming,
  overdue,
}

// The Course Model, adapted for Firebase.
class Course {
  final String? id; // Firebase keys are Strings.
  final String icon;
  final String title;
  final CourseStatus status;
  final double progress;

  const Course({
    this.id,
    required this.icon,
    required this.title,
    required this.status,
    required this.progress,
  });

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    return Course(
      id: id,
      icon: map['icon'] as String,
      title: map['title'] as String,
      progress: (map['progress'] as num).toDouble(),
      status: CourseStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => CourseStatus.upcoming,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'title': title,
      'progress': progress,
      'status': status.name, // Store enum as a string
    };
  }
}