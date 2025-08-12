import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/shared/Views/theam.dart';
import '../models/submission_model.dart';

class SubmissionViewPage extends StatelessWidget {
  final String taskTitle;
  final Submission submission;

  const SubmissionViewPage({
    super.key,
    required this.taskTitle,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(taskTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGradeCard(),
            const SizedBox(height: 20),
            Card(
              color: ThemeMode.light == getThemeMode()
                  ? Colors.white
                  : Theme.of(context).cardColor,
              shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Submission Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: "Submitted On",
                      value: DateFormat.yMMMd().add_jm().format(submission.submittedAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Submitted Content",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    SelectableText(
                      submission.content,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCard() {
    final bool isGraded = submission.grade != null;

    return Card(
      elevation: 4,
      color: isGraded ? Colors.green.shade50 : Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isGraded ? Colors.green.shade200 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              isGraded ? "Your Grade" : "Status",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isGraded ? Colors.green.shade800 : Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isGraded ? submission.grade.toString() : "Submitted for Grading",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isGraded ? Colors.green.shade900 : Colors.orange.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}