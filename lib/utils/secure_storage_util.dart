import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syrius_mobile/main.dart';

class SecureStorageUtil {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  SecureStorageUtil() {
    initSecureStorage();
  }

  Future<void> initSecureStorage() async {
    const String firstRunKey = 'firstRun';

    final bool isFirstRun = sharedPrefsService.get<bool>(
      firstRunKey,
      defaultValue: true,
    )!;
    if (isFirstRun) {
      await _storage.deleteAll();
      await sharedPrefsService.put(firstRunKey, false);
    }
  }

  Future<void> write({
    required String key,
    required String value,
  }) =>
      _storage.write(
        key: key,
        value: value,
      );

  Future<String> read(String key, {String defaultValue = ''}) async {
    final data = await _storage.read(key: key);
    if (data == null) {
      return defaultValue;
    } else {
      return data;
    }
  }

  Future<void> delete({
    required String key,
  }) =>
      _storage.delete(
        key: key,
      );

  Future<bool> containsKey({
    required String key,
  }) =>
      _storage.containsKey(
        key: key,
      );

  Future<void> deleteAll() async => await _storage.deleteAll();
}
