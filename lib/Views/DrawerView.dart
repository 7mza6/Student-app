import 'package:flutter/material.dart';
import 'package:users/Viewmodels/notification-viewModel.dart';
import 'package:users/Views/theam.dart';
import 'package:users/auth/models/userModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../auth/Views/LoginPage.dart';
import '../main.dart';
import 'constants.dart';
import 'notification_body.dart';
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
      padding: kHeaderPadding, // Used constant
      child: Row(
        children: [
          const CircleAvatar(
            radius: kAvatarRadius, // Used constant
            backgroundImage: NetworkImage(kAppLogoUrl), // Used constant
          ),
          kWidthSpacer15, // Used constant
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text(kAppName, style: kHeaderTextStyle), // Used constant
              Text(AppLocalizations.of(context)!.kNavMenuTitle, style: kSubHeaderTextStyle), // Used constant
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      margin: kUserInfoCardMargin, // Used constant
      padding: kAllPadding8, // Used constant
      decoration: BoxDecoration(
        color: kUserInfoCardColor, // Used constant
        borderRadius: kBorderRadius12, // Used constant
      ),
      child: ListTile(
        leading: const CircleAvatar(
          radius: kAvatarRadius, // Used constant
          backgroundImage: NetworkImage(kUserProfileImageUrl), // Used constant
        ),
        title: Text(
          CurrentUser.getcurrentUser()?.username ?? 'User Name',
          style: kUserInfoTextStyle, // Used constant
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
      leading: Icon(icon, color: kPrimaryIconColor), // Used constant
      title: Text(text, style: kMenuItemTextStyle), // Used constant
      onTap: onTap,
    );
  }

  Widget _buildNotificationsItem() {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications, color: kPrimaryIconColor), // Used constant
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
      title:  Text(AppLocalizations.of(context)!.kLogoutLabel, style: kLogoutTextStyle), // Used constant
      onTap: () {
        MyApp.of(context)?.setThemeMode(ThemeMode.light);
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginPage()));// Used constant
      },
    );
  }
}