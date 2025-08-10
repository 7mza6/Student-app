import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:users/main.dart';


// App-wide Colors
const kPrimaryColor = Color(0xFF3F99F6);
const kSecondaryColor = Color(0xFF1976D2);
const kAccentColor = Colors.blueAccent;
//const kLightBackgroundColor = Color(0xFFCBE4FE);
const kLightBackgroundColor = Colors.white;
const kDarkBackgroundColor = Color(0xFF121212);
const kDarkSurfaceColor = Color(0xFF1E1E1E);
const kUserInfoCardColor = Color(0xFFF1F4FD);
const kDividerColor = Colors.black26;
const kErrorColor = Colors.red;
const kAppTitleColor = Colors.deepPurple;
const kPrimaryIconColor = Color(0xFF1565C0); // Equivalent to Colors.blue.shade800
const kSubTextColor = Color(0xFF616161); // Equivalent to Colors.grey[700]
const kMutedTextColor = Color(0xFF757575); // Equivalent to Colors.grey[600]

const kAppBarColor = Colors.blue;
const kLanguageButtonBorderColor = Color.fromRGBO(255, 255, 255, 0.8);
const kLanguageButtonBackgroundColor = Color.fromRGBO(255, 255, 255, 0.1);
const kFormBackgroundColor = Color.fromARGB(147, 15, 81, 134);
const kShadowColor = Color.fromRGBO(0, 0, 0, 0.1);



// Dimensions & Spacing
// Padding
const kPagePadding = EdgeInsets.all(20.0);
const kAllPadding8 = EdgeInsets.all(8.0);
const kHeaderPadding = EdgeInsets.fromLTRB(20, 10, 20, 10);
const kHorizontalPadding20 = EdgeInsets.symmetric(horizontal: 20.0);

// Margin
const kUserInfoCardMargin = EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0);
const kVerticalMargin5 = EdgeInsets.symmetric(vertical: 5);

// Spacers
const kHeightSpacer5 = SizedBox(height: 5);
const kHeightSpacer10 = SizedBox(height: 10);
const kHeightSpacer20 = SizedBox(height: 20);
const kHeightSpacer30 = SizedBox(height: 30);
const kWidthSpacer15 = SizedBox(width: 15);

// Sizes
const kLogoSize = 120.0;
const kAvatarRadius = 25.0;
const kCardElevation = 2.0;

// Border Radius
final kBorderRadius10 = BorderRadius.circular(10);
final kBorderRadius12 = BorderRadius.circular(12);

// Responsive Breakpoints
const kTabletBreakpoint = 600.0;
const kDesktopBreakpoint = 1200.0;

// Text Styles
const kHeaderTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const kCardDataStyle = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
const kSubHeaderTextStyle = TextStyle(fontSize: 14, color: Colors.grey);
const kUserInfoTextStyle = TextStyle(fontWeight: FontWeight.bold,);
const kMenuItemTextStyle = TextStyle(fontWeight: FontWeight.w500);
const kNotificationCountTextStyle = TextStyle(color: Colors.white, fontSize: 12);
const kLogoutTextStyle = TextStyle(color: kErrorColor, fontWeight: FontWeight.w500);
const kSectionTitleStyle = TextStyle(fontWeight: FontWeight.bold, color: kAccentColor);


// Strings & Labels
// App Info
const kAppName = 'Student App';
const kAppVersion = 'Version 1.0.0';
const kCopyright = '© 2025 All rights reserved.';
const kDeveloperName = 'Hamza Sayes';
const kAppLegalese = '© 2025 Alquds University';
const kAppDescription = 'Welcome to Student App! This app helps you manage your assignments, quizzes, courses, and schedule — all in one place.It’s built to make it easier for you to stay organized and keep track of your academic tasks.Simple, clear, and useful.';
const kAcknowledgmentsText = 'This app uses various open-source libraries. You can view their licenses by tapping "Licenses" below.';
const kAcknowledgmentsTitle = 'Acknowledgments';

// UI Labels
const kBiometricSubscriptionPitch = 'Subcribe or you will never find any stack overflow answer';

// Routes
const kMainRoute = '/main';
const kAboutRoute = '/about';
const kTestRoute = '/test';
const kNotificationsRoute = '/notifications';
const kLoginRoute = '/login';

// URLs
const kDefaultAvatarUrl =  'images/profile.png';
const kAppLogoUrl = 'https://images-platform.99static.com/nK0Z_sdR6pVTLL97Gq1z5TkG3vQ=/102x102:921x921/500x500/top/smart/99designs-contests-attachments/71/71057/attachment_71057015';
const kUserProfileImageUrl = 'images/profile.png';
const kFacebookUrl = 'https://www.facebook.com/hamza.msayes.5';
const kInstagramUrl = 'https://www.instagram.com/hamza.sayes/';
const kSupportEmailUrl = 'mailto:hamza.sayes@students.alquds.edu';
// Asset Paths
const kBackgroundImage = "images/background.png";


// ===== DIMENSIONS & SPACING =====
//shadow

 List<BoxShadow>? kCardShadow(context) {return[
   BoxShadow(
     color: Theme.of(context).shadowColor.withOpacity(0.3),
     blurRadius: 10,
     offset: Offset(0, 5),
   ),
 ] ;}



// Padding
const kDialogPadding = EdgeInsets.all(8.0);
const kSheetPadding = EdgeInsets.all(10.0);
const kUserButtonPadding = EdgeInsets.fromLTRB(10, 0, 10, 10);
const kUserButtonContentPadding = 10.0;

// Spacers
const kHeightSpacer2 = SizedBox(height: 2.0);
const kHeightSpacer9 = SizedBox(height: 9.0);
const kHeightSpacer15 = SizedBox(height: 15);

// Sizes
const kLanguageButtonSize = 40.0;
const kFingerprintIconSize = 40.0;
const kSheetBorderRadius = Radius.circular(20);
const kSheetInitialSize = 0.4;
const kSheetMaxSize = 0.6;
const kSheetMinSize = 0.3;

// Border
const kLanguageButtonBorderWidth = 1.0;
const kUserButtonBorderWidth = 0.0000000001; // Kept as is for precision

// Constraints
const kFormMinWidth = 250.0;
const kFormMaxWidth = 600.0;
const kRegisterFormMinHeight = 450.0;
const kRegisterFormMaxHeight = 600.0;
const kLoginFormMinHeight = 600.0;
const kLoginFormMaxHeight = 600.0;

// ===== TEXT STYLES =====
const kSheetTitleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const kSheetSubtitleStyle = TextStyle(fontSize: 14, color: Colors.grey);
const kLanguageButtonTextStyle = TextStyle(color: Colors.white);
const kAuthTitleStyle = TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white);
const kAuthButtonTextStyle = TextStyle(fontSize: 20, color: Colors.white);

//  LOCALES 
const kDefaultLanguage = 'en';
const kArabicLanguage = 'ar';
const kEnglishLanguage = 'en';