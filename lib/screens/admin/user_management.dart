import 'package:cashier/services/database_helper.dart';
import 'package:cashier/widgets/password_resest_dialog.dart';
import 'package:flutter/material.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  List<Map<String, dynamic>> users = [];
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> resetPassword(int userId) async {
    final db = await DatabaseHelper.instance.database;
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => PasswordResetDialog(userId: userId, db: db),
    );
  }

  Future<void> loadUsers() async {
    final db = await DatabaseHelper.instance.database;
    final fetchUsers =
        await db.query('users', where: 'role != ?', whereArgs: ['admin']);
    setState(() => users = fetchUsers);
  }

  Future<void> viewLoginHistory(context, int userId) async {
    final db = await DatabaseHelper.instance.database;

    final attempts = await db.query(
      'login_attempts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'attemptTime DESC',
      limit: 31,
    );
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login History'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                return ListTile(
                  leading: Icon(
                    attempt['success'] == 1 ? Icons.check_circle : Icons.error,
                    color: attempt['success'] == 1 ? Colors.green : Colors.red,
                  ),
                  title: Text("${attempt['attemptTime']}"),
                  subtitle: Text(attempt['success'] == 1
                      ? 'Successful login'
                      : 'Failed attempt'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> updateUserActive({active, userid}) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      {'isActive': active ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userid],
    );
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Add New User Form
        Expanded(
          flex: 1,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Cashier',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: userController,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (userController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty) {
                          DatabaseHelper.instance.database.then((db) async {
                            final existingUser = await db.query(
                              'users',
                              where: 'username = ?',
                              whereArgs: [userController.text],
                            );

                            if (existingUser.isEmpty) {
                              DatabaseHelper.instance.addUser(
                                userName: userController.text,
                                password: passwordController.text,
                              );
                              loadUsers();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Username already exists')),
                              );
                            }
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              // title: const Text('Add New Cashier'),
                              content: const Text(
                                'Please fill out all fields',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Add Cashier'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // User List
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cashier List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.person,
                              color: user['isActive'] == 1
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            title: Text(user['username']),
                            subtitle: Text('Created: ${user['createdAt']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.history),
                                  onPressed: () =>
                                      viewLoginHistory(context, user['id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.password),
                                  onPressed: () {
                                    resetPassword(user['id']);
                                  },
                                ),
                                Switch(
                                  value: user['isActive'] == 1,
                                  onChanged: (bool value) {
                                    updateUserActive(
                                      active: value,
                                      userid: user['id'],
                                    );
                                    loadUsers();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[900],
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete User'),
                                        content: const Text(
                                            'Are you sure you want to delete this user?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              final db = await DatabaseHelper
                                                  .instance.database;
                                              await db.delete(
                                                'users',
                                                where: 'id = ?',
                                                whereArgs: [user['id']],
                                              );
                                              loadUsers();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
