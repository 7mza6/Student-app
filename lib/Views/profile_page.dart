import 'package:flutter/material.dart';
import 'package:users/Views/ChangePasswordPage.dart';
import 'package:users/Views/NotificationSettingsPage.dart';
import 'package:users/auth/models/userModel.dart'; // Adjust the import path as needed
import '../auth/Views/LoginPage.dart';
import '../auth/services/biometric_servic.dart';
import '../main.dart';
import 'edit_profile_page.dart'; // Adjust the import path as needed

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Get the current user from your static class
  final user? _currentUser = CurrentUser.getcurrentUser();

  // Initialize switchVal to false to prevent errors before the async call completes.
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    // Fetch the stored preference when the widget loads.
    _loadBiometricPreference();
  }

  /// Fetches the user's biometric preference from secure storage
  /// and updates the UI state.
  Future<void> _loadBiometricPreference() async {
    if (_currentUser == null) return;

    // The '?? false' ensures that if null is returned, we default to false.
    final storedValue = await getbiometric_Enabled(_currentUser!);
    if (mounted) { // Check if the widget is still in the tree
      setState(() {
        _isBiometricEnabled = storedValue ?? false;
      });
    }
  }

  /// Toggles the biometric preference, saves it, and updates the UI.
  Future<void> _toggleBiometric(bool value) async {
    if (_currentUser == null) return;

    setState(() {
      _isBiometricEnabled = value;
    });
    await biometric_Enabled(value, _currentUser!);
  }

  @override
  Widget build(BuildContext context) {
    // Handle the case where the user might not be logged in
    if (_currentUser == null) {
      return const Center(child: Text("No user logged in."));
    }

    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: "Account",
            children: [
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: "Edit Profile",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
                },
              ),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage()));

                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            title: "Settings",
            children: [
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text("Biometric Login"),
                trailing: Switch(
                  value: _isBiometricEnabled,
                  onChanged: (value) {
                    _toggleBiometric(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildLogoutButton(),
        ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          _currentUser!.username ?? 'No Username',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser!.email ?? 'No Email',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text("Log Out"),
      onPressed: () {
          MyApp.of(context)?.setThemeMode(ThemeMode.light);
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginPage()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}