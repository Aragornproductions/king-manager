import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles PIN storage (hashed, never stored in plain text) for the Locker.
class LockerAuth {
  static const _pinHashKey = 'locker_pin_hash';

  static String _hash(String pin) {
    final bytes = utf8.encode('king_manager_salt_$pin');
    return sha256.convert(bytes).toString();
  }

  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinHashKey) != null;
  }

  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, _hash(pin));
  }

  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pinHashKey);
    return stored != null && stored == _hash(pin);
  }

  static Future<void> resetPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
  }
}
