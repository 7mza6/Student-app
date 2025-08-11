import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'constants.dart'; // Import constants

Widget AboutPage(BuildContext context) {
  return SingleChildScrollView(
    padding: kPagePadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          kAppLogo,
          height: kLogoSize,
          width: kLogoSize,
          fit: BoxFit.contain,
        ),
        kHeightSpacer20,
        Text(
          kAppName,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: kAppTitleColor),
        ),
        kHeightSpacer10,
        Text(
          kAppVersion,
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(color: kSubTextColor),
        ),
        kHeightSpacer30,
        Text(
          kAppDescription,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        kHeightSpacer30,
        _buildSectionTitle(context, AppLocalizations.of(context)!.kDevelopedBy),
        kHeightSpacer10,
        Text(kDeveloperName, style: Theme.of(context).textTheme.titleMedium),
        kHeightSpacer5,
        Text(kCopyright,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: kMutedTextColor)),
        kHeightSpacer30,
        _buildSectionTitle(context, AppLocalizations.of(context)!.kConnectWithUs),
        kHeightSpacer10,
        _buildLinkTile(
          context,
          icon: Icons.facebook,
          title: AppLocalizations.of(context)!.kFacebookLabel,
          url: kFacebookUrl,
        ),
        _buildLinkTile(
          context,
          icon: FontAwesomeIcons.instagram,
          title: AppLocalizations.of(context)!.kInstagramLabel,
          url: kInstagramUrl,
        ),
        _buildLinkTile(
          context,
          icon: Icons.email,
          title: AppLocalizations.of(context)!.kContactSupportLabel,
          url: kSupportEmailUrl,
        ),
        kHeightSpacer30,
        _buildSectionTitle(context, kAcknowledgmentsTitle),
        kHeightSpacer10,
        Text(
          kAcknowledgmentsText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        kHeightSpacer10,
        ElevatedButton.icon(
          icon: const Icon(Icons.info_outline),
          label:  Text(AppLocalizations.of(context)!.kViewLicensesLabel),
          onPressed: () {
            showLicensePage(
              context: context,
              applicationName: kAppName,
              applicationVersion: kAppVersion,
              applicationLegalese: kAppLegalese,
            );
          },
        ),
        kHeightSpacer20,
      ],
    ),
  );
}

Widget _buildSectionTitle(BuildContext context, String title) {
  return Text(
    title,
    style: Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontWeight: FontWeight.bold, color: kAccentColor),
  );
}

Widget _buildLinkTile(BuildContext context,
    {required IconData icon, required String title, required String url}) {
  return Card(
    margin: kVerticalMargin5,
    elevation: kCardElevation,
    child: ListTile(
      leading: Icon(icon, color: kAccentColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $title')),
          );
        }
      },
    ),
  );
}