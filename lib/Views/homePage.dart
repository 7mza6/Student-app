import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:users/Views/constants.dart';
import 'package:users/Views/theam.dart';

import '../auth/models/userModel.dart';
import 'GridCards.dart';
import 'Responsive.dart';

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
                'Hello, ${CurrentUser.getcurrentUser()?.username}',
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



class UpcomingEventsGrid extends StatelessWidget {
  const UpcomingEventsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridCards(
      mobileCount: 1,
      nonMobileCount: 2,
      itemCount: 3,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return UpcomingEventCard(
              day: '15',
              month: 'Oct',
              title: 'Physics Lecture',
              time: '10:00 AM - 11:30 AM',
              location: 'Online - Zoom',
              backgroundColor: const Color(0xFFFEE6E2),
              textColor: const Color(0xFFD95B4A),
            );
          case 1:
            return UpcomingEventCard(
              day: '20',
              month: 'Oct',
              title: 'Chemistry Lab',
              time: '2:00 PM - 4:00 PM',
              location: 'Lab Room 204',
              backgroundColor: const Color(0xFFE0F7FA),
              textColor: const Color(0xFF00796B),
            );
          case 2:
            return UpcomingEventCard(
              day: '22',
              month: 'Oct',
              title: 'Math Workshop',
              time: '1:00 PM - 2:30 PM',
              location: 'Main Hall',
              backgroundColor: const Color(0xFFE8F5E9),
              textColor: const Color(0xFF388E3C),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class ProgressCards extends StatelessWidget {
  const ProgressCards({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridCards(
      itemCount: 4,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return card(
              title: 'Courses Enrolled',
              icon: FontAwesomeIcons.book,
              data: Text('12', style: kCardDataStyle),
            );
          case 1:
            return card(
              title: 'Pending Assignments',
              icon: FontAwesomeIcons.tasks,
              data: Text('3', style: kCardDataStyle),
            );
          case 2:
            return card(
              title: 'Upcoming Quizzes',
              icon: Icons.calendar_month_outlined,
              data: Text('Oct 12', style: kCardDataStyle),
            );
          case 3:
            return card(
              title: 'Overall Progress',
              icon: Icons.speed,
              data: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('75%', style: kCardDataStyle),
                  Text('75% achieved', style: kSheetSubtitleStyle),
                ],
              ),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );;
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
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
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
          quickActionsCard(title: 'Open Calendar', icon: Icons.calendar_month ),
          quickActionsCard(title: 'View Reports', icon: FontAwesomeIcons.listCheck ),
          quickActionsCard(title: 'Submit Assignment', icon: Icons.add ),

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

  const UpcomingEventCard({
    super.key,
    required this.day,
    required this.month,
    required this.title,
    required this.time,
    required this.location,
    required this.backgroundColor,
    required this.textColor,
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
            // Event details
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
                  const Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





