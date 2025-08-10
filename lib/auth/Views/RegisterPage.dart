import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';
import '../../views/constants.dart';
import '../Viewmodels/register_view_model.dart' as regis;
import '../Viewmodels/register_view_model.dart';

const Color kFormBackgroundColor = Colors.white;
const Color kTextColor = Colors.black87;
const Color kSubtitleColor = Colors.grey;
const Color kBorderColor = Colors.grey;

String lang = kDefaultLanguage;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 700,
          ),
          decoration: BoxDecoration(
            borderRadius: kBorderRadius10,
            color: kFormBackgroundColor,
          ),
          child: Padding(
            padding: kSheetPadding,
            child: _buildRegisterForm(),
          ),
        ),
      ),
    );
  }

  // --- Reused Language Switcher Logic ---
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
          lang = newLang;
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

  // --- Main Registration Form Builder ---
  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView( // Use SingleChildScrollView to prevent overflow
        child: Column(
          children: [
            Row( // Header
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 50),
                Text(
                  'Create Account', //TODO: Add Localization
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
                ),
                _buildLanguageSwitcher(),
              ],
            ),
            const SizedBox(height: 30),

            // Main Content Area
            Container(
              constraints: const BoxConstraints(
                minWidth: kFormMinWidth,
                maxWidth: kFormMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign Up for a New Account', //TODO: Add Localization
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join our community to get started.', //TODO: Add Localization
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: kSubtitleColor),
                  ),
                  SizedBox(height: 40),

                  // --- ALL THE NEW FORM FIELDS ---

                  // Full Name
                  Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)), //TODO: Add Localization
                  SizedBox(height: 8),
                  TextFormField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      hintText: "Enter your full name", //TODO: Add Localization
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
                  ),
                  SizedBox(height: 20),

                  // Username
                  Text(AppLocalizations.of(context)!.username, style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.username,
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a username' : null,
                  ),
                  SizedBox(height: 20),

                  // Email
                  Text("Email", style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)), //TODO: Add Localization
                  SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Enter your email address", //TODO: Add Localization
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
                  ),
                  SizedBox(height: 20),

                  // Phone Number
                  Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)), //TODO: Add Localization
                  SizedBox(height: 8),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: "Enter your phone number", //TODO: Add Localization
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
                  ),
                  SizedBox(height: 20),

                  // Age
                  Text("Age", style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)), //TODO: Add Localization
                  SizedBox(height: 8),
                  TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(
                      hintText: "Enter your age", //TODO: Add Localization
                      prefixIcon: Icon(Icons.cake_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your age' : null,
                  ),
                  SizedBox(height: 20),

                  // Password
                  Text(AppLocalizations.of(context)!.password, style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.password,
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  SizedBox(height: 20),

                  // Confirm Password
                  Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)), //TODO: Add Localization
                  SizedBox(height: 8),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Confirm your password", //TODO: Add Localization
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: () async{
                      if (_formKey.currentState!.validate()) {
                        final api = RegisterViewModel();
                        api.registerUserAndShowDialog(
                          context: context,
                          username: usernameController.text,
                          password: passwordController.text,
                          fullName: fullNameController.text,
                          email:  emailController.text,
                          phone: phoneController.text,
                         age:  int.tryParse(ageController.text) ?? 0,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(AppLocalizations.of(context)!.regesteraitin, style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  SizedBox(height: 12),

                  // Go to Login Page Button
                  OutlinedButton(
                    onPressed: () {
                      // Pop back to the login page
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: kPrimaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("Already have an account? Log In", style: TextStyle(fontSize: 16, color: kPrimaryColor)), //TODO: Add Localization
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}