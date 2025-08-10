import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/Views/submission_page.dart';
import 'package:users/Views/submission_view_page.dart';
import 'package:users/Views/task_card.dart';
import '../Viewmodels/task_view_model.dart';

class SubmissionsViewBody extends StatefulWidget {
  final String courseId;
  final String studentId;

  const SubmissionsViewBody({
    super.key,
    required this.courseId,
    required this.studentId,
  });


  @override
  State<SubmissionsViewBody> createState() => _SubmissionsViewBodyState();
}

class _SubmissionsViewBodyState extends State<SubmissionsViewBody> {
  late Future<Map<String, List<TaskWithSubmission>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = fetchTasksAndSubmissions(
      courseId: widget.courseId,
      studentId: widget.studentId,
    );
  }

  void _refreshData() {
    setState(() {
      _tasksFuture = fetchTasksAndSubmissions(
        courseId: widget.courseId,
        studentId: widget.studentId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submissions"),),
      body: FutureBuilder<Map<String, List<TaskWithSubmission>>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading tasks: ${snapshot.error}"));
          }
          if (!snapshot.hasData || (snapshot.data!['assignments']!.isEmpty && snapshot.data!['exams']!.isEmpty)) {
            return const Center(child: Text("No assignments or exams for this course."));
          }

          final assignments = snapshot.data!['assignments']!;
          final exams = snapshot.data!['exams']!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Assignments", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (assignments.isEmpty)
                  const Text("No assignments found.", style: TextStyle(color: Colors.grey)),
                ...assignments.map((task) => TaskCard(
                  courseId: widget.courseId,
                  type: 'assignments',
                  taskWithSubmission: task,
                  onSubmitted: _refreshData,
                )),

                const SizedBox(height: 24),

                const Text("Exams", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (exams.isEmpty)
                  const Text("No exams found.", style: TextStyle(color: Colors.grey)),
                ...exams.map((task) => TaskCard(
                courseId: widget.courseId,
                type: 'exams',
                taskWithSubmission: task,
                onSubmitted: _refreshData,
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}





