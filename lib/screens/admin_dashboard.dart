import 'package:cashier/screens/login_screen.dart';
import 'package:cashier/services/securityUtils.dart';
import 'package:cashier/services/database_helper.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Future<void> _resetPassword(int userId) async {
    final newPassword = 'temp${DateTime.now().millisecondsSinceEpoch}';
    final hashedPassword = SecurityUtils.hashPassword(newPassword);

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      {
        'password': hashedPassword,
        'lastPasswordChange': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Password Reset'),
        content: Text('Temporary password: $newPassword'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _viewLoginHistory(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final attempts = await db.query(
      'login_attempts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'attemptTime DESC',
      limit: 10,
    );

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
                title: Text(DateTime.parse(attempt['attemptTime'] as String)
                    .toString()),
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

////////////////////////////////////////////
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = await DatabaseHelper.instance.database;
    final users =
        await db.query('users', where: 'role != ?', whereArgs: ['admin']);
    setState(() => _users = users);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildUserManagement();
      case 1:
        return _buildReports();
      case 2:
        return _buildSettings();
      default:
        return const Center(child: Text('Unknown page'));
    }
  }

  Widget _buildUserManagement() {
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
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
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
                        // Add user implementation
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
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
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
                                      _viewLoginHistory(user['id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.password),
                                  onPressed: () => _resetPassword(user['id']),
                                ),
                                Switch(
                                  value: user['isActive'] == 1,
                                  onChanged: (bool value) {
                                    // Toggle user status implementation
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

  Widget _buildReports() {
    return const Center(
      child: Text('Reports Coming Soon'),
    );
  }

  Widget _buildSettings() {
    return const Center(
      child: Text('Settings Coming Soon'),
    );
  }
}
