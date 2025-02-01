import 'package:cashier/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database configuration
  await DatabaseConfig.initializeDatabase();

  runApp(const MainApp());
}

class DatabaseConfig {
  static Future<void> initializeDatabase() async {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for desktop
    databaseFactory = databaseFactoryFfi;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF56B9F1),
      ),
      home: LoginScreen(),
    );
  }
}
