import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Viewmodels/login_view_model.dart';
import 'RegisterPage.dart';
import '../../main.dart';
import '../../Views/constants.dart';

const Color kFormBackgroundColor = Colors.white;
const Color kTextColor = Colors.black87;
const Color kSubtitleColor = Colors.grey;
const Color kBorderColor = Colors.grey;






String lang = kDefaultLanguage;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
                child: Container(
                  constraints:BoxConstraints(
                    minHeight: 700,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: kBorderRadius10,
                    color: kFormBackgroundColor,
                  ),
                  child: Padding(
                    padding: kSheetPadding,
                    child: _buildLoginForm(),
                  ),
                  ),
                ),
      );
  }

  Widget _buildLanguageSwitcher() {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLanguageButton('EN'),
          _buildLanguageButton('AR'),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String language) {
    bool isSelected = lang.toUpperCase() == language;
    return GestureDetector(
      onTap: () {
        setState(() {
          String newLang = lang == kArabicLanguage ? kEnglishLanguage : kArabicLanguage;
          setState(() {
            lang = newLang;
          });
          MyApp.of(context)?.setLocale(Locale(newLang));
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            language,
            style: TextStyle(
              color: isSelected ? Colors.white : kTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Container(
        child: Column(

          children: [

                      Row( // Header: Close button, Title, Language Switcher
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 SizedBox(width: 50),
                 Text(
                  'Welcome Back',//TODO: Add Localization
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
                ),
                _buildLanguageSwitcher(),
              ],
            ),


             Expanded(flex: 1, child: SizedBox()),

            // Title
            Expanded(
              flex: 9,
               child: Container(
                constraints: const BoxConstraints(
                    minWidth: kFormMinWidth,
                    maxWidth: kFormMaxWidth,
                    minHeight: kLoginFormMinHeight,
                    maxHeight: kLoginFormMaxHeight,
                  ),
                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     Text(
                      'Log In to Your Account',//TODO: Add Localization
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextColor),
                           ),
                     SizedBox(height: 8),
                     Text(
                      'Access your personalized experience.', //TODO: Add Localization
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: kSubtitleColor),
                           ),
                     SizedBox(height: 50,),



                     // User name Field
                     Text(AppLocalizations.of(context)!.username, style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
                     SizedBox(height: 8),
                     TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.username,
                        prefixIcon:  Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.text,
                           ),
                     SizedBox(height: 20),



                     // Password Field
                     Text(AppLocalizations.of(context)!.password, style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
                     SizedBox(height: 8),
                           TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.password,
                        prefixIcon:  Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                           ),
                     SizedBox(height: 10),

                           // Forgot Password
                           Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child:  Text('Forgot Password', style: TextStyle(color: kPrimaryColor)),//TODO: Add Localization
                      ),
                           ),
                     SizedBox(height: 20),

                      Row(
                children: [

                     Expanded(
                       child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            check(context, usernameController.text, passwordController.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding:  EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child:  Text(AppLocalizations.of(context)!.login, style: TextStyle(fontSize: 16, color: Colors.white)),
                                       ),
                     ),
                  SizedBox(width: 12),


                      IconButton(
                                 style: OutlinedButton.styleFrom(
                                   minimumSize: Size.square(55),
                                   padding:  EdgeInsets.symmetric(vertical: 0),
                                   side:  BorderSide(color: kPrimaryColor),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))) ,
                                 onPressed: () async => await localAuth(context, mounted),
                                 icon: const Icon(Icons.fingerprint, size: kFingerprintIconSize, color: kPrimaryColor),
                               ),

                ],
            ),
                     SizedBox(height: 12),


            // Sign Up Button
            OutlinedButton(
                onPressed: () {
                },
                style: OutlinedButton.styleFrom(
                  padding:  EdgeInsets.symmetric(vertical: 16),
                  side:  BorderSide(color: kPrimaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child:  Text(AppLocalizations.of(context)!.regesteraitin, style: TextStyle(fontSize: 16, color: kPrimaryColor)),
            ),


            SizedBox(height: 12),



                   ],
                 ),
               ),
             ),

            // Log In Button

          ],
        ),
      ),
    );
  }



  
}


