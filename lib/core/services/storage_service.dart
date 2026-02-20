import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> setBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<bool?> getBool(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> setInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<int?> getInt(String key) async {
    final value = await _storage.read(key: key);
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
    return await _storage.read(key: 'encrypted_password');
  }

  Future<void> removeEncryptedPassword() async {
    await _storage.delete(key: 'encrypted_password');
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
