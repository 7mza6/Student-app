import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:users/notifications/Viewmodels/notification-viewModel.dart';
import 'package:users/profile/Views/profile_page.dart';
import 'package:users/shared/Views/theam.dart';
import 'package:users/auth/models/userModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../auth/Views/LoginPage.dart';
import '../../main.dart';
import '../../shared/Viewmodels/constants.dart';
import '../../notifications/Views/notification_body.dart';
import 'main-view.dart';

class DrawerView extends StatefulWidget {
  DrawerView({super.key});

  @override
  State<DrawerView> createState() => _DrawerViewState();
}

class _DrawerViewState extends State<DrawerView> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),
          _buildUserInfoCard(),
          _buildNotificationsItem(),
          _buildDarkModeItem(),
          _buildMenuItem(
            icon: Icons.info_outline,
            text: AppLocalizations.of(context)!.kAboutLabel, // Used constant
            onTap: () {
              Navigator.pushNamed(context, kAboutRoute); // Used constant
            },
          ),
          const Padding(
            padding: kHorizontalPadding20, // Used constant
            child: Divider(color: kDividerColor), // Used constant
          ),
          _buildLogoutItem(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: kHeaderPadding,
      child: Row(
        children: [
           CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.0),
            radius: kAvatarRadius, 
            backgroundImage: AssetImage(kAppLogo),
          ),
          kWidthSpacer15, 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text(kAppName, style: kHeaderTextStyle),
              Text(AppLocalizations.of(context)!.kNavMenuTitle, style: kSubHeaderTextStyle), // Used constant
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          mainView.of(context)?.setBody(Profile());
        });
      },
      child: Container(
        margin: kUserInfoCardMargin,
        padding: kAllPadding8,
        decoration: BoxDecoration(
         color: Theme.of(context).drawerTheme.backgroundColor,
          borderRadius: kBorderRadius12,
        ),
        child: ListTile(
          leading: const CircleAvatar(
            radius: kAvatarRadius,
            backgroundImage: AssetImage(kUserProfileImageUrl),
          ),
          title: Text(
            CurrentUser.getcurrentUser()?.fullName ?? 'User Name',
            style: kUserInfoTextStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryIconColor),
      title: Text(text, style: kMenuItemTextStyle),
      onTap: onTap,
    );
  }

  Widget _buildNotificationsItem() {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications, color: kPrimaryIconColor),
        ],
      ),
      title:  Text(AppLocalizations.of(context)!.kNotificationsLabel, style: kMenuItemTextStyle), // Used constant
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: kErrorColor, // Used constant
          borderRadius: kBorderRadius10, // Used constant
        ),
        child: const Text('5', style: kNotificationCountTextStyle), // Used constant
      ),
      onTap: () {
        setState(() {
          mainView.of(context)?.setBody(NotificationBody());
        }); // Used constant
      },
    );
  }

  Widget _buildDarkModeItem() {
    return ListTile(
      leading: Icon(Icons.dark_mode, color: kPrimaryIconColor), // Used constant
      title:  Text(AppLocalizations.of(context)!.kDarkModeLabel, style: kMenuItemTextStyle), // Used constant
      trailing: Switch(
        value: getThemeMode() == ThemeMode.dark,
        onChanged: (value) {
          setState(() {
            final newMode = value ? ThemeMode.dark : ThemeMode.light;
            setThemeMode(newMode);
            MyApp.of(context)?.setThemeMode(newMode);
          });
        },
        activeColor: kPrimaryIconColor, // Used constant
      ),
    );
  }

  Widget _buildLogoutItem() {
    return ListTile(
      leading: const Icon(Icons.logout, color: kErrorColor), // Used constant
      title:  Text(AppLocalizations.of(context)!.kLogoutLabel, style: kLogoutTextStyle),
      onTap: () {
        MyApp.of(context)?.setThemeMode(ThemeMode.light);
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginPage()));
      },
    );
  }
}