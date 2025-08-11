import 'package:flutter/material.dart';
import 'package:users/Views/submission_view_page.dart';
import '../Viewmodels/task_view_model.dart';
import 'constants.dart';

class SimpleGradedCard extends StatelessWidget {
  final TaskWithSubmission task;

  const SimpleGradedCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final submission = task.submission!;
    final grade = submission.grade!;

    return Card(
      elevation: 0,
      color:kPrimaryColor.withOpacity(0.6),
      margin: const EdgeInsets.only(top: 8.0),
      child: ListTile(
        title: Text(task.title),
        trailing: Text(
          grade.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmissionViewPage(
                taskTitle: task.title,
                submission: submission,
              ),
            ),
          );
        },
      ),
    );
  }
}