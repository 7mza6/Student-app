import 'package:flutter/material.dart';
import '../../shared/Viewmodels/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class UsersSheet {
  final Map<String, String> userPasswords;
  UsersSheet(this.userPasswords);
  String? selectedUser;

  Future<String> showUserSelectionSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: kSheetBorderRadius),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: kSheetInitialSize,
          maxChildSize: kSheetMaxSize,
          minChildSize: kSheetMinSize,
          builder: (BuildContext context, ScrollController scrollController) {
            return Padding(
              padding: kSheetPadding,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(AppLocalizations.of(context)!.kSelectAccountLabel, style: kSheetTitleStyle),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  kHeightSpacer2,
                  Row(
                    children:  [
                      Text(AppLocalizations.of(context)!.kBiometricAuthPrompt, style: kSheetSubtitleStyle),
                    ],
                  ),
                  kHeightSpacer9,
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: _buildUserButtons(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    return selectedUser ?? '';
  }

  List<Widget> _buildUserButtons(BuildContext context) {
    return userPasswords.keys.map((username) {
      return UserButton(
        userName: username,
        avatarUrl: kDefaultAvatarUrl,
        onPressed: () {
          selectedUser = username;
          Navigator.pop(context);
        },
      );
    }).toList();
  }
}

class UserButton extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final VoidCallback onPressed;

  const UserButton({
    Key? key,
    required this.userName,
    required this.avatarUrl,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kUserButtonPadding,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: kShadowColor,
              spreadRadius: 1,
              offset: const Offset(0.5, 0.5),
              blurRadius: 1,
            ),
            BoxShadow(
              color: kShadowColor,
              spreadRadius: 1,
              offset: const Offset(-0.5, -0.5),
              blurRadius: 1,
            ),
          ],
          border: Border.all(
            color: Colors.black,
            width: kUserButtonBorderWidth,
          ),
          borderRadius: kBorderRadius10,
        ),
        child: ListTile(
          minVerticalPadding: kUserButtonContentPadding,
          leading: CircleAvatar(
            backgroundImage: AssetImage(avatarUrl),
          ),
          title: Text(userName),
          onTap: onPressed,
        ),
      ),
    );
  }
}