import 'package:cashier/screens/admin/admin_dashboard.dart';
import 'package:cashier/screens/cashier_dashboard.dart';
import 'package:cashier/services/database_helper.dart';
import 'package:cashier/services/security_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final int _maxLoginAttempts = 5;
  final int _lockoutDurationMinutes = 15;
  String? error;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper.instance.database;
      final users = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [_usernameController.text],
      );

      if (users.isEmpty) {
        setState(() {
          error = "user or password is wrong";
          _isLoading = false;
        });
        _formKey.currentState!.validate(); // Trigger validation
        return;
      }

      final user = users.first;

      // Check if account is locked
      if (user['failedAttempts'] as int >= _maxLoginAttempts) {
        final lastAttempt = DateTime.parse(user['lastLoginAttempt'] as String);
        final lockoutEnd =
            lastAttempt.add(Duration(minutes: _lockoutDurationMinutes));

        if (DateTime.now().isBefore(lockoutEnd)) {
          setState(() {
            error = 'Account is locked. Try again later.';
            _isLoading = false;
          });
          _formKey.currentState!.validate(); // Trigger validation
          return;
        } else {
          // Reset failed attempts after lockout period
          await db.update(
            'users',
            {'failedAttempts': 0},
            where: 'id = ?',
            whereArgs: [user['id']],
          );
        }
      }

      // Verify password
      if (!SecurityUtils.verifyPassword(
        _passwordController.text,
        user['password'] as String,
      )) {
        // Increment failed attempts
        await db.update(
          'users',
          {
            'failedAttempts': (user['failedAttempts'] as int) + 1,
            'lastLoginAttempt': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [user['id']],
        );
        setState(() {
          error = 'user or password is wrong';
          _isLoading = false;
        });
        _formKey.currentState!.validate(); // Trigger validation
        return;
      }

      // Successful login
      await db.update(
        'users',
        {
          'failedAttempts': 0,
          'lastLoginAttempt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [user['id']],
      );

      // Log successful login attempt
      await db.insert('login_attempts', {
        'userId': user['id'],
        'attemptTime':
            DateFormat('yyyy-MM-dd   hh:mm a').format(DateTime.now()),
        'success': 1,
        'ipAddress': 'local'
      });

      // Check if user is active
      if (user['isActive'] == 0 && mounted) {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Access Denied'),
            content: const Text(
                'User is not allowed to access. Please contact the admin.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Navigate based on role
      if (mounted) {
        if (user['role'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CashierDashboard()),
          );
        }
      }
    } catch (e) {
      const SnackBar(content: Text('An error occurred. Please try again.'));
      setState(() {
        _isLoading = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 26,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                    onChanged: (value) {
                      setState(() {
                        error = null;
                      });

                      _formKey.currentState!.validate();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : error,
                    onChanged: (value) {
                      setState(() {
                        error = null;
                      });
                      _formKey.currentState!.validate();
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
