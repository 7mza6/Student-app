import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:users/Views/profile_page.dart';
import '../Viewmodels/Courses-Model.dart';
import 'AboutPage.dart';
import 'Courses.dart';
import 'constants.dart';
import 'homePage.dart';
import 'main-view.dart';

class BottomNavBar extends StatefulWidget {
  final mainView;
  const BottomNavBar({
    super.key, required this.mainView,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
    static int selectedIndex = 0;

    void setBody(Widget body) {
      setState(() {
        widget.mainView.setBody(body);
      });
    }
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: kAccentColor,
      unselectedItemColor: Color.fromARGB(255, 211, 211, 211),
      items:  <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppLocalizations.of(context)!.kHomeLabel,
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.book),
          label: AppLocalizations.of(context)!.kCoursesLabel,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: AppLocalizations.of(context)!.kProfileLabel,
        ),
      ],
      onTap: (index) {
        if (index == 0) {
            selectedIndex = 0;
            setState(() {
              setBody(HomePage());
            });
         
        } else if (index == 1) {
          selectedIndex = 1;
          setState(() {
            setBody(Courses());
          });
        } else if (index == 2) {
          selectedIndex = 2;
          setState(() {
            mainView.of(context)?.setBody(Profile());
          });
        }
      },
    );
  }
}