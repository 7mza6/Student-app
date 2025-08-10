

import 'package:flutter/material.dart';

import '../Models/exam_model.dart';
import '../Models/question_model.dart';
import '../Models/submission_model.dart';
import '../Repositories/submission_api.dart';
import '../Viewmodels/exam_view_model.dart';
import '../auth/models/userModel.dart';

class ExamPage extends StatefulWidget {
  final Exam exam;
  final String courseId;

  const ExamPage({super.key, required this.exam, required this.courseId});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  final PageController _pageController = PageController();
  final Map<int, dynamic> userAnswers = {}; // Map<questionIndex, answer>
  bool isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(int questionIndex, dynamic answer) {
    setState(() {
      userAnswers[questionIndex] = answer;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        itemCount: widget.exam.questions.length + 1, // Add 1 for the final submission page
        itemBuilder: (context, index) {
          if (index == widget.exam.questions.length) {
            return _buildSubmissionScreen();
          }
          final question = widget.exam.questions[index];
          return _buildQuestionCard(question, index);
        },
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Question ${index + 1} of ${widget.exam.questions.length}", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 16),
          Text(question.questionText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          if (question.type == QuestionType.trueFalse)
            _buildTrueFalseOptions(index),
          if (question.type == QuestionType.multipleChoice)
            _buildMultipleChoiceOptions(question, index),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
            child: Text(index == widget.exam.questions.length - 1 ? "Finish" : "Next Question"),
          ),
        ],
      ),
    );
  }

  Widget _buildTrueFalseOptions(int questionIndex) {
    return Column(
      children: [
        RadioListTile<bool>(
          title: const Text("True"),
          value: true,
          groupValue: userAnswers[questionIndex],
          onChanged: (value) => _onAnswerSelected(questionIndex, value),
        ),
        RadioListTile<bool>(
          title: const Text("False"),
          value: false,
          groupValue: userAnswers[questionIndex],
          onChanged: (value) => _onAnswerSelected(questionIndex, value),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions(Question question, int questionIndex) {
    return Column(
      children: question.options!.map((option) {
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: userAnswers[questionIndex],
          onChanged: (value) => _onAnswerSelected(questionIndex, value),
        );
      }).toList(),
    );
  }

  Widget _buildSubmissionScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("You have reached the end of the exam.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text("${userAnswers.length} of ${widget.exam.questions.length} questions answered."),
          const SizedBox(height: 32),
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Submit Final Answers"),
            onPressed: () {
              submitExam(context,this);
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ],
      ),
    );
  }
}