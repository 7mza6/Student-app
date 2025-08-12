import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:users/tasks/Views/all_tasks_page.dart';
import 'package:users/shared/Viewmodels/constants.dart';
import 'package:users/submissions/Views/submissions_view_body.dart';
import 'package:users/shared/Views/theam.dart';


import '../../Models/dashboard_stats_model.dart';
import '../../tasks/models/upcoming_event_model.dart';
import '../../shared/Views/GridCards.dart';
import '../../tasks/Views/graded_work_page.dart';
import '../../auth/models/userModel.dart';
import '../Viewmodels/homePage_view_model.dart';
import 'course_enrollment_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: kAllPadding8,
              child: Text(
                'Hello, ${CurrentUser.getcurrentUser()?.fullName}',
                style: kSheetTitleStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Welcome back to your personalized learning hub.',
                style: kSheetSubtitleStyle,
              ),
            ),
            Padding(
              padding: kAllPadding8,
              child: Text(
                'Your Progress',
                style: kCardDataStyle,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ProgressCards(),
            ),
            Padding(
              padding: kAllPadding8,
              child: Text(
                'Quick Actions',
                style: kCardDataStyle,
              ),
            ),
               buildQuickActionsCards(),
            Padding(
              padding: kAllPadding8,
              child: Text(
                'Upcoming Events',
                style: kCardDataStyle,
              ),
            ),
            UpcomingEventsGrid(),
          ],
        ),
      ),
    );
  }
}



class ProgressCards extends StatefulWidget {
  const ProgressCards({super.key});

  @override
  State<ProgressCards> createState() => _ProgressCardsState();
}

class _ProgressCardsState extends State<ProgressCards> {
  late Future<DashboardStatsViewModel> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = fetchDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardStatsViewModel>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Failed to load dashboard data."));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No data available."));
        }

        final stats = snapshot.data!;

        return GridCards(
          itemCount: 4,
          mobileCount: 2,
          nonMobileCount: 4,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return card(
                  title: 'Courses Enrolled',
                  icon: FontAwesomeIcons.book,
                  data: Text(stats.coursesEnrolledCount.toString(), style: kCardDataStyle),
                );
              case 1:
                return card(
                  title: 'Pending Assignments',
                  icon: FontAwesomeIcons.listCheck,
                  data: Text(stats.pendingAssignmentsCount.toString(), style: kCardDataStyle),
                );
              case 2:
                final quizDateText = stats.nextUpcomingQuizDate != null
                    ? DateFormat('MMM d').format(stats.nextUpcomingQuizDate!)
                    : "None";
                return card(
                  title: 'Upcoming Quizzes',
                  icon: FontAwesomeIcons.calendarDay,
                  data: Text(quizDateText, style: kCardDataStyle),
                );
              case 3:
                final progressText = "${(stats.overallProgress * 100).toStringAsFixed(0)}%";
                return card(
                  title: 'Overall Progress',
                  icon: FontAwesomeIcons.chartLine,
                  data: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(progressText, style: kCardDataStyle),
                      Text('${progressText} achieved', style: kSheetSubtitleStyle),
                    ],
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}

class card extends StatelessWidget {
  final title;
  final icon;
  final Widget data;
  const card({
    super.key,
    required this.title,
    required this.icon,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kAllPadding8,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: kCardShadow(context),
          color: ThemeMode.light == getThemeMode()
              ? Colors.white
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: ThemeMode.light == getThemeMode()
                        ? kAccentColor
                        : kAccentColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(100000),
                  ),
                  height: 40,
                  width: 40,
                  child: Icon(
                    icon,
                    size: 20,
                    color: ThemeMode.dark == getThemeMode()
                        ? kAccentColor
                        : Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(title, style: kSheetSubtitleStyle),
              ),
              data,
            ],
          ),
        ),
      ),
    );
  }
}

class quickActionsCard extends StatelessWidget {
  final title;
  final icon;
  Function()? onTap = (){};

   quickActionsCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return ConstrainedBox(
      constraints: BoxConstraints(
      minHeight: 156,
      minWidth: 150,
      maxHeight: 156,
      maxWidth: 360,
    ),

      child: Padding(
        padding: kAllPadding8,
        child: GestureDetector(
          child: Container(
            width: 200,
            decoration: BoxDecoration(
                boxShadow: kCardShadow(context),
              color: ThemeMode.light == getThemeMode()
                  ? Colors.white
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ThemeMode.light == getThemeMode()
                            ? kAccentColor
                            : kAccentColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(100000),
                      ),
                      height: 40,
                      width: 40,
                      child: Icon(
                        icon,
                        size: 20,
                        color: ThemeMode.dark == getThemeMode()
                            ? kAccentColor
                            : Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(title, style: kSheetSubtitleStyle),
                  ),
                ],
              ),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class buildQuickActionsCards extends StatelessWidget {
  const buildQuickActionsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          quickActionsCard(title: 'Submit Assignment', icon: Icons.add , onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AllTasksPage()));

          }, ),
          quickActionsCard(title: 'View Reports', icon: FontAwesomeIcons.listCheck , onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  GradedWorkByCoursePage()));
          },),
          quickActionsCard(title: 'Enroll Course', icon: FontAwesomeIcons.book ,onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  CourseEnrollmentPage()));

          },),
        ],
      ),
    );
  }
}

class UpcomingEventCard extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final String time;
  final String location;
  final Color backgroundColor;
  final Color textColor;
  final Widget statusWidget;

  const UpcomingEventCard({
    super.key,
    required this.day,
    required this.month,
    required this.title,
    required this.time,
    required this.location,
    required this.backgroundColor,
    required this.textColor,
    required this.statusWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kAllPadding8,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: kCardShadow(context),
        ),
        child: Row(
          children: [
            // Date container
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    month,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  statusWidget,

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpcomingEventsGrid extends StatefulWidget {
  const UpcomingEventsGrid({super.key});

  @override
  State<UpcomingEventsGrid> createState() => _UpcomingEventsGridState();
}

class _UpcomingEventsGridState extends State<UpcomingEventsGrid> {
  late Future<List<UpcomingEventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = fetchUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UpcomingEventModel>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Could not load events."));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No upcoming events."));
        }

        final events = snapshot.data!;

        final colorSchemes = [
          {'bg': const Color(0xFFFEE6E2), 'text': const Color(0xFFD95B4A)},
          {'bg': const Color(0xFFE0F7FA), 'text': const Color(0xFF00796B)},
          {'bg': const Color(0xFFE8F5E9), 'text': const Color(0xFF388E3C)},
          {'bg': const Color(0xFFFFF3E0), 'text': const Color(0xFFF57C00)},
          {'bg': const Color(0xFFEDE7F6), 'text': const Color(0xFF5E35B1)},
        ];

        return GridCards(
          mobileCount: 1,
          nonMobileCount: 2,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final colorScheme = colorSchemes[index % colorSchemes.length];

            return UpcomingEventCard(
              day: DateFormat('d').format(event.eventDate),
              month: DateFormat('MMM').format(event.eventDate),
              title: event.title,
              time: event.eventTime,
              location: event.location,
              backgroundColor: colorScheme['bg']!,
              textColor: colorScheme['text']!,
              statusWidget: _buildStatusWidget(event),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusWidget(UpcomingEventModel event) {
    final now = DateTime.now();
    Color statusColor;
    String statusText;

    if (event.isExam) {
      if (now.isAfter(event.endTime!)) {
        statusText = "Finished";
        statusColor = Colors.grey;
      } else if (now.isBefore(event.startTime!)) {
        statusText = "Upcoming";
        statusColor = Colors.purple;
      } else { // It's currently active
        statusText = "Active Now";
        statusColor = Colors.green;
      }
    } else {
      // It's an assignment, so it's always just pending
      statusText = "Pending";
      statusColor = Colors.orange;
    }

    return Text(
      statusText,
      style: TextStyle(
        color: statusColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}
