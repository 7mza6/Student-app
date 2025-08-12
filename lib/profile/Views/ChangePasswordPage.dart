import 'package:flutter/material.dart';
import '../../auth/Repositories/user_api.dart';
import '../../auth/models/userModel.dart';       // Adjust path as needed
import '../../shared/Viewmodels/constants.dart';                     // Adjust path for kPrimaryColor

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _userApi = UserApi();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isCurrentObscured = true;
  bool _isNewObscured = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final currentUser = CurrentUser.getcurrentUser()!;
      final newPassword = _newPasswordController.text;
      final successCode = await _userApi.updatePassword(currentUser, newPassword);

      if (successCode == 1) {
        CurrentUser.setcurrentUser(currentUser.copyWith(password: newPassword));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to change password.'), backgroundColor: Colors.red),
          );
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _isCurrentObscured,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isCurrentObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isCurrentObscured = !_isCurrentObscured),
                  ),
                ),
                validator: (value) {
                  if (value != CurrentUser.getcurrentUser()!.password) {
                    return 'Incorrect current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // New Password Field
              TextFormField(
                controller: _newPasswordController,
                obscureText: _isNewObscured,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isNewObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isNewObscured = !_isNewObscured),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (value == _currentPasswordController.text) {
                    return 'New password must be different from the old one';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isNewObscured, // Should be obscured the same way as the new password
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_person_outlined),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}