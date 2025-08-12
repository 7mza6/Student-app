import 'package:flutter/material.dart';
import 'package:users/shared/Viewmodels/constants.dart';
import '../Repositories/submission_api.dart';
import '../models/submission_model.dart';
import '../../auth/models/userModel.dart';

class SubmissionPage extends StatefulWidget {
  final String courseId;
  final String taskId;
  final String taskTitle;
  final String type;

  const SubmissionPage({
    super.key,
    required this.courseId,
    required this.taskId,
    required this.taskTitle,
    required this.type,
  });

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _submissionApi = SubmissionApi();
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studentId = CurrentUser.getcurrentUser()!.id.toString();

      final newSubmission = Submission(
        studentId: studentId,
        content: _contentController.text,
        submittedAt: DateTime.now(),
      );

      await _submissionApi.create(
        widget.courseId,
        widget.taskId,
        widget.type,
        newSubmission,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Submission successful!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // 6. Handle errors
      print("Error submitting: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskTitle),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Submission",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your submission content below. This could be text, a link or any other required information.",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: "Type your submission here...",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  labelText: 'Content',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Submission content cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitForm,
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.cloud_upload),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Task"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}