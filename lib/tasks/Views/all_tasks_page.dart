import 'package:flutter/material.dart';
import 'package:users/tasks/Views/task_card.dart';
import 'package:users/shared/Views/theam.dart';
import '../Viewmodels/task_view_model.dart';
import '../../courses/Models/Course-model.dart';

class AllTasksPage extends StatefulWidget {
  const AllTasksPage({super.key});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  late Future<Map<Course, Map<String, List<TaskWithSubmission>>>> _allTasksFuture;

  @override
  void initState() {
    super.initState();
    _loadAllTasks();
  }

  void _loadAllTasks() {
    _allTasksFuture = fetchAllTasksForEnrolledCourses();
  }

  void _refreshData() {
    setState(() {
      _loadAllTasks();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks & Submissions"),
      ),
      body: FutureBuilder<Map<Course, Map<String, List<TaskWithSubmission>>>>(
        future: _allTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "You have no assignments or exams in your enrolled courses.",
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

      color: ThemeMode.light == getThemeMode()
          ? Color(0xFFDDECFF)
          : Theme.of(context).backgroundColor,
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

            const Text("Assignments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (assignments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("No assignments.", style: TextStyle(color: Colors.grey)),
              )
            else
              ...assignments.map((task) => TaskCard(
                courseId: course.id!,
                type: 'assignments',
                taskWithSubmission: task,
                onSubmitted: _refreshData,
              )),

            const SizedBox(height: 16),
            const Text("Exams", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (exams.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("No exams.", style: TextStyle(color: Colors.grey)),
              )
            else
              ...exams.map((task) => TaskCard(
                courseId: course.id!,
                type: 'exams',
                taskWithSubmission: task,
                onSubmitted: _refreshData,
              )),
          ],
        ),
      ),
    );
  }
}