import 'package:cashier/screens/admin_dashboard.dart';
import 'package:cashier/screens/cashier_dashboard.dart';
import 'package:cashier/services/securityUtils.dart';
import 'package:cashier/services/database_helper.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final int _maxLoginAttempts = 5;
  final int _lockoutDurationMinutes = 15;

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
        _showError('Invalid credentials');
        return;
      }

      final user = users.first;

      // Check if account is locked
      if (user['failedAttempts'] as int >= _maxLoginAttempts) {
        final lastAttempt = DateTime.parse(user['lastLoginAttempt'] as String);
        final lockoutEnd =
            lastAttempt.add(Duration(minutes: _lockoutDurationMinutes));

        if (DateTime.now().isBefore(lockoutEnd)) {
          _showError('Account is locked. Try again later.');
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
          _passwordController.text, user['password'] as String)) {
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

        _showError('Invalid credentials');
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
        'attemptTime': DateTime.now().toIso8601String(),
        'success': 1,
        'ipAddress': 'local'
      });

      // Navigate based on role
      if (user['role'] == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CashierDashboard()),
        );
      }
    } catch (e) {
      _showError('Login failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                    'POS System Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
                        value?.isEmpty ?? true ? 'Required' : null,
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
