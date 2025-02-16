import 'package:cashier/services/security_utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future addUser({
    required String userName,
    required String password,
  }) async {
    final db = await instance.database;

    await db.insert('users', {
      'username': userName,
      'password': SecurityUtils.hashPassword(password),
      'role': 'user',
      'isActive': 1,
      'failedAttempts': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'lastPasswordChange': DateTime.now().toIso8601String()
    });
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      role TEXT NOT NULL,
      isActive INTEGER NOT NULL DEFAULT 1,
      failedAttempts INTEGER DEFAULT 0,
      lastLoginAttempt TEXT,
      createdAt TEXT NOT NULL,
      lastPasswordChange TEXT NOT NULL
    )
    ''');

    // Login attempts table
    await db.execute('''
    CREATE TABLE login_attempts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      attemptTime TEXT NOT NULL,
      success INTEGER NOT NULL,
      ipAddress TEXT,
      FOREIGN KEY(userId) REFERENCES users(id)
    )
    ''');

    // Insert default admin with hashed password
    final hashedPassword = SecurityUtils.hashPassword('admin123');
    await db.insert('users', {
      'username': 'admin',
      'password': hashedPassword,
      'role': 'admin',
      'isActive': 1,
      'failedAttempts': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'lastPasswordChange': DateTime.now().toIso8601String()
    });
  }
}
