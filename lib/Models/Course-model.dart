import 'package:flutter/material.dart';

enum CourseStatus {
  inProgress,
  completed,
  upcoming,
  overdue,
}

class Course {
  final String? id;
  final String icon;
  final String title;
  final CourseStatus status;
  final double progress;
  final String teacherId;
  final List<String> enrolledStudents;

  const Course({
    this.id,
    required this.icon,
    required this.title,
    required this.status,
    required this.progress,
    required this.teacherId,
    this.enrolledStudents = const [],
  });

  Course copyWith({
    String? icon,
    String? title,
    CourseStatus? status,
    double? progress,
    String? teacherId,
    List<String>? enrolledStudents,
  }) {
    return Course(
        id: this.id,
        icon: icon ?? this.icon,
        title: title ?? this.title,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        teacherId: teacherId ?? this.teacherId,
        enrolledStudents: enrolledStudents ?? this.enrolledStudents);
  }

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    List<String> students = [];
    if (map['enrolledStudents'] != null) {
      final studentsMap = map['enrolledStudents'] as Map<dynamic, dynamic>;
      students = studentsMap.keys.cast<String>().toList();
    }

    return Course(
      id: id,
      icon: map['icon'] as String? ?? '📚',
      title: map['title'] as String? ?? 'Untitled Course',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      status: CourseStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => CourseStatus.upcoming,
      ),
      teacherId: map['teacherId'] as String? ?? '',
      enrolledStudents: students,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, bool> studentsMap = {
      for (var studentId in enrolledStudents) studentId: true
    };

    return {
      'icon': icon,
      'title': title,
      'progress': progress,
      'status': status.name,
      'teacherId': teacherId,
      'enrolledStudents': studentsMap,
    };
  }
}