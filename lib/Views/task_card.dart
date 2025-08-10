

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/Views/submission_page.dart';
import 'package:users/Views/submission_view_page.dart';
import 'package:users/Views/theam.dart';
import '../Models/exam_model.dart';
import '../Viewmodels/task_view_model.dart';
import 'constants.dart';
import 'exam_page.dart';

class TaskCard extends StatelessWidget {
  final VoidCallback onSubmitted;
  final TaskWithSubmission taskWithSubmission;
  final String courseId;
  final String type;

  const TaskCard({
    super.key,
    required this.taskWithSubmission,
    required this.courseId,
    required this.type, required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final task = taskWithSubmission.task;
    final submission = taskWithSubmission.submission;
    final bool isSubmitted = submission != null;
    final bool isGraded = isSubmitted && submission.grade != null;
    final bool isPastDue = DateTime.now().isAfter(taskWithSubmission.dueDate);



    String buttonText = "Submit";
    Color statusColor = Colors.orange;
    String statusText = "Not Submitted";
    IconData statusIcon = Icons.edit_document;
    VoidCallback? onPressed;

    if (taskWithSubmission.task is Exam) {
      final exam = taskWithSubmission.task as Exam;
      final now = DateTime.now();

      if (isSubmitted) {
        statusText = isGraded ? "Graded: ${submission!.grade}" : "Submitted";
        statusColor = isGraded ? Colors.green : Colors.blue;
        statusIcon = isGraded ? Icons.check_circle : Icons.cloud_done;
        buttonText = "View Submission";
        onPressed = () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubmissionViewPage(taskTitle: exam.title, submission: submission!)));
      } else if (now.isAfter(exam.endDateTime)) {
        statusText = "Finished";
        statusColor = Colors.red;
        statusIcon = Icons.timer_off;
        buttonText = "Exam Closed";
        onPressed = null;
      } else if (now.isBefore(exam.startDateTime)) {
        statusText = "Upcoming";
        statusColor = Colors.purple;
        statusIcon = Icons.hourglass_top;
        buttonText = "Not Started Yet";
        onPressed = null;
      } else {
        statusText = "Active Now";
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_fill;
        buttonText = "Start Exam";
        onPressed = () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ExamPage(exam: exam, courseId: courseId)));
          if (result == true) { onSubmitted(); }
        };
      }
    }
    else {
    if (isGraded) {
      statusText = "Graded: ${submission.grade}";
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      buttonText = "View Submission";
      onPressed = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmissionViewPage(
              taskTitle: taskWithSubmission.title,
              submission: submission, // Pass the submission object
            ),
          ),
        );
      };
    } else if (isSubmitted) {
      statusText = "Submitted";
      statusColor = Colors.blue;
      statusIcon = Icons.cloud_done;
      buttonText = "View Submission";
      onPressed = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmissionViewPage(
              taskTitle: taskWithSubmission.title,
              submission: submission,
            ),
          ),
        );
      };
    } else if (isPastDue) {
      statusText = "Past Due";
      statusColor = Colors.red;
      statusIcon = Icons.error;
      buttonText = "Submission Closed";
      onPressed = null; // Disables the button
    } else {
      onPressed = () {
        onSubmitted;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmissionPage(
              courseId: courseId,
              taskId: taskWithSubmission.id,
              taskTitle: taskWithSubmission.title,
              type: type,
            ),
          ),
        );
      };
    }
}
    return Card(
      color: ThemeMode.light == getThemeMode()
          ? Colors.white
          : Theme.of(context).cardColor,
      shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(taskWithSubmission.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "Due: ${DateFormat.yMMMd().add_jm().format(taskWithSubmission.dueDate)}",
              style: kSheetSubtitleStyle,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onPressed != null ? kPrimaryColor.withOpacity(1)
                    : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(buttonText, style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}