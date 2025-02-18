import 'package:cashier/screens/admin/add_products.dart';
import 'package:cashier/screens/login_screen.dart';
import 'package:cashier/screens/admin/user_management.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
////////////////////////////////////////////
  int _selectedIndex = 0;

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
                MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                icon: Icon(Icons.production_quantity_limits_outlined),
                label: Text('products'),
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
        return const UserManagement();
      case 1:
        return const AddProducts();
      case 2:
        return _buildReports();
      case 3:
        return _buildSettings();
      default:
        return const Center(child: Text('Unknown page'));
    }
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
