import 'package:flutter/material.dart';
import 'package:users/Views/constants.dart';
import 'package:users/Views/submissions_view_body.dart';
import 'package:users/Views/theam.dart';
import '../Models/Course-model.dart';
import '../Viewmodels/Courses-Model.dart';
import '../auth/models/userModel.dart';
import 'GridCards.dart';



class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Course>>(
        future: fetchEnrolledCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No courses enrolled."));
          }
          final courses = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                   Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GridCards(
                      mobileCount: 1,
                      nonMobileCount: 2,
                      mainAxisExtent: 247,
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return Padding(padding: EdgeInsets.all(8),child: CourseCard(course: courses[index], onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  SubmissionsViewBody(courseId:(courses[index].id)!, studentId: (CurrentUser.getcurrentUser()?.id.toString())!) ));
                        },));
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}













class CourseCard extends StatelessWidget {
  final Course course;
  final Function()? onPressed;

  const CourseCard({super.key, required this.course, required this.onPressed});

  Map<String, dynamic> _getStatusConfig() {
    switch (course.status) {
      case CourseStatus.inProgress:
        return {
          'text': 'In Progress',
          'color': const Color(0xFF007BFF),
          'buttonText': 'Continue Learning',
        };
      case CourseStatus.completed:
        return {
          'text': 'Completed',
          'color': const Color(0xFF28A745),
          'buttonText': 'View Details',
        };
      case CourseStatus.overdue:
        return {
          'text': 'Overdue',
          'color': const Color(0xFFDC3545),
          'buttonText': 'View Details',
        };
      case CourseStatus.upcoming:
      default:
        return {
          'text': 'Upcoming',
          'color': Colors.grey[600],
          'buttonText': 'View Details',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig();
    final statusColor = statusConfig['color'] as Color;
    final statusText = statusConfig['text'] as String;
    final buttonText = statusConfig['buttonText'] as String;


    return Container(
      height: 209,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ThemeMode.light == getThemeMode()
            ? Colors.white
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: kCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:  ThemeMode.light == getThemeMode()
                      ? kAccentColor
                      : kAccentColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  course.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (course.status != CourseStatus.upcoming)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (course.status == CourseStatus.upcoming)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: course.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(course.progress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPressed??(){} ,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF007BFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}