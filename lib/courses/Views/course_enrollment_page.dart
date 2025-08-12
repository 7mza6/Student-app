import 'package:flutter/material.dart';
import '../Models/Course-model.dart';
import '../Viewmodels/Courses-Model.dart';
import 'course_enrollment_card.dart';

class CourseEnrollmentPage extends StatefulWidget {
  const CourseEnrollmentPage({super.key});

  @override
  State<CourseEnrollmentPage> createState() => _CourseEnrollmentPageState();
}

class _CourseEnrollmentPageState extends State<CourseEnrollmentPage> {
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    _coursesFuture = fetchUnenrolledCourses();
  }

  void _onEnrollmentSuccess() {
    setState(() {
      _loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enroll in a New Course"),
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("An error occurred: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "There are no new courses available for enrollment, or you have already enrolled in all of them.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final courses = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(12.0),
            itemCount: courses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return CourseEnrollmentCard(
                course: courses[index],
                onEnrollmentSuccess: _onEnrollmentSuccess,
              );
            },
          );
        },
      ),
    );
  }
}