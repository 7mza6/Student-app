import 'package:flutter/material.dart';
import 'package:users/Views/constants.dart';


import '../Models/Course-model.dart';
import '../auth/Repositories/user_api.dart';
import '../auth/models/userModel.dart'; // Adjust import

class CourseEnrollmentCard extends StatefulWidget {
  final Course course;
  final VoidCallback onEnrollmentSuccess;

  const CourseEnrollmentCard({
    super.key,
    required this.course,
    required this.onEnrollmentSuccess,
  });

  @override
  State<CourseEnrollmentCard> createState() => _CourseEnrollmentCardState();
}

class _CourseEnrollmentCardState extends State<CourseEnrollmentCard> {
  bool _isLoading = false;
  final UserApi _userApi = UserApi();

  Future<void> _enrollInCourse() async {
    final currentUser =  CurrentUser.getcurrentUser();
    if (currentUser == null || currentUser.id == null || widget.course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot enroll: User or Course data is invalid.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _userApi.enrollInCourse(
        currentUser.id.toString(),
        widget.course.id!,
      );

      currentUser.enrolledCourses.add(widget.course.id!);
      CurrentUser.setcurrentUser(currentUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully enrolled in ${widget.course.title}!"),
          backgroundColor: Colors.green,
        ),
      );

      // Trigger a refresh on the parent page to remove this card from the list.
      widget.onEnrollmentSuccess();

    } catch (e) {
      print("Failed to enroll: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again."), backgroundColor: Colors.red),
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(widget.course.icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(widget.course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: ElevatedButton.icon(
          onPressed: _isLoading ? null : _enrollInCourse,
          icon: _isLoading
              ? Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.all(2.0),
            child: const CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
          )
              : const Icon(Icons.add),
          label: const Text("Enroll"),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}