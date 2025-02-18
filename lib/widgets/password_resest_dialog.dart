import 'package:cashier/services/security_utils.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PasswordResetDialog extends StatefulWidget {
  final int userId;
  final Database db;

  const PasswordResetDialog(
      {super.key, required this.userId, required this.db});

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  late TextEditingController oldPasswordController = TextEditingController();
  late TextEditingController newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool oldPasswordObscure = true;
  bool newPasswordObscure = true;
  String? passwordError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: const Text('Reset Password'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: oldPasswordController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : passwordError,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      oldPasswordObscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(() {
                      oldPasswordObscure = !oldPasswordObscure;
                    }),
                  ),
                ),
                obscureText: oldPasswordObscure,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Required';
                  } else if (value!.length < 8) {
                    return 'Minimum 8 characters';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() {
                      newPasswordObscure = !newPasswordObscure;
                    }),
                    icon: Icon(
                      newPasswordObscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: newPasswordObscure,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final user = await widget.db.query(
                'users',
                where: 'id = ?',
                whereArgs: [widget.userId],
              );
              if (user.first['password'] != oldPasswordController.text) {
                setState(() {
                  passwordError = 'Incorrect password';
                });
                _formKey.currentState!.validate();

                return;
              }
              await widget.db.update(
                'users',
                {
                  'password':
                      SecurityUtils.hashPassword(newPasswordController.text)
                },
                where: 'id = ?',
                whereArgs: [widget.userId],
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }
}
