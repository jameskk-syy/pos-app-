import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await _safeRead(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<bool?> getBool(String key) async {
    final value = await _safeRead(key);
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> setInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<int?> getInt(String key) async {
    final value = await _safeRead(key);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> saveEncryptedPassword(String password) async {
    // FlutterSecureStorage encrypts by default
    await _storage.write(key: 'encrypted_password', value: password);
  }

  Future<String?> getEncryptedPassword() async {
    return await _safeRead('encrypted_password');
  }

  Future<void> removeEncryptedPassword() async {
    await _storage.delete(key: 'encrypted_password');
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// Safely reads a value from secure storage, handling potential decryption errors.
  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (e is PlatformException) {
        // Handle Android KeyStore decryption failures (e.g. BadPaddingException)
        // by clearing the corrupted storage.
        await clear();
      }
      return null;
    }
  }
}
