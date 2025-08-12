import 'package:flutter/material.dart';
import 'package:users/shared/Views/simple_graded_card.dart';
import 'package:users/shared/Views/theam.dart';
import '../Viewmodels/task_view_model.dart';
import '../../courses/Models/Course-model.dart';

class GradedWorkByCoursePage extends StatefulWidget {
  const GradedWorkByCoursePage({super.key});

  @override
  State<GradedWorkByCoursePage> createState() => _GradedWorkByCoursePageState();
}

class _GradedWorkByCoursePageState extends State<GradedWorkByCoursePage> {
  late Future<Map<Course, Map<String, List<TaskWithSubmission>>>> _gradedTasksFuture;

  @override
  void initState() {
    super.initState();
    _loadGradedTasks();
  }

  void _loadGradedTasks() {
    _gradedTasksFuture = fetchAllGradedTasksByCourse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Graded Work"),
      ),
      body: FutureBuilder<Map<Course, Map<String, List<TaskWithSubmission>>>>(
        future: _gradedTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading graded work: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "You have no graded assignments or exams yet.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final allTasksMap = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: allTasksMap.keys.length,
            itemBuilder: (context, index) {
              final course = allTasksMap.keys.elementAt(index);
              final tasks = allTasksMap[course]!;
              final assignments = tasks['assignments']!;
              final exams = tasks['exams']!;

              return _buildCourseSection(
                course: course,
                assignments: assignments,
                exams: exams,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseSection({
    required Course course,
    required List<TaskWithSubmission> assignments,
    required List<TaskWithSubmission> exams,
  }) {
    return Card(
      shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
      color: ThemeMode.light == getThemeMode()
          ? Color(0xFFDDECFF)
          : Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(course.icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            if (assignments.isNotEmpty) ...[
              const Text("Assignments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ...assignments.map((task) => SimpleGradedCard(task: task)),
              const SizedBox(height: 16),
            ],

            if (exams.isNotEmpty) ...[
              const Text("Exams", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ...exams.map((task) => SimpleGradedCard(task: task)),
            ],
          ],
        ),
      ),
    );
  }
}