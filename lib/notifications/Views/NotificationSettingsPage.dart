import 'package:flutter/material.dart';
import 'package:users/shared/Viewmodels/constants.dart';
import '../../auth/Repositories/user_api.dart';
import '../../auth/models/userModel.dart';      // Adjust path as needed

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _userApi = UserApi();

  late bool _announcements;
  late bool _gradesPosted;
  late bool _deadlineReminders;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = CurrentUser.getcurrentUser()!.notificationSettings;
    setState(() {
      _announcements = settings?['announcements'] ?? true;
      _gradesPosted = settings?['gradesPosted'] ?? true;
      _deadlineReminders = settings?['deadlineReminders'] ?? true;
      _isLoading = false;
    });
  }

  /// A generic function to update a setting and save it to the database.
  Future<void> _updateSetting(String key, bool value) async {
    setState(() {
      if (key == 'announcements') _announcements = value;
      if (key == 'gradesPosted') _gradesPosted = value;
      if (key == 'deadlineReminders') _deadlineReminders = value;
    });

    final currentUser = CurrentUser.getcurrentUser()!;
    final newSettings = Map<String, bool>.from(currentUser.notificationSettings ?? {});
    newSettings[key] = value;

    final updatedUser = currentUser.copyWith(notificationSettings: newSettings);

    final successCode = await _userApi.update(updatedUser);
    if (successCode == 1) {
      CurrentUser.setcurrentUser(updatedUser);
      print('SUCCESS: Updated setting: $key -> $value');
    } else {
      print('ERROR: Failed to update setting: $key');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save setting.'), backgroundColor: Colors.red),
        );
        _loadSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildSwitchTile(
            title: 'Course Announcements',
            subtitle: 'Get notified about new announcements from teachers.',
            value: _announcements,
            onChanged: (value) => _updateSetting('announcements', value),
          ),
          _buildSwitchTile(
            title: 'Grades Posted',
            subtitle: 'Get notified when a grade is posted for your submissions.',
            value: _gradesPosted,
            onChanged: (value) => _updateSetting('gradesPosted', value),
          ),
          _buildSwitchTile(
            title: 'Deadline Reminders',
            subtitle: 'Receive reminders for upcoming assignment deadlines.',
            value: _deadlineReminders,
            onChanged: (value) => _updateSetting('deadlineReminders', value),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      value: value,
      onChanged: onChanged,
      activeColor: kPrimaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }
}