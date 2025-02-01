// security_utils.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityUtils {
  static const storage = FlutterSecureStorage();

  // Hash password using SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verify password
  static bool verifyPassword(String password, String hashedPassword) {
    final hashedInput = hashPassword(password);
    return hashedInput == hashedPassword;
  }

  // Generate random salt (for future password hashing improvements)
  static String generateSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
