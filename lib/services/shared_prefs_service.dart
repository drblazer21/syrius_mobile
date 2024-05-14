import 'package:hive/hive.dart';
import 'package:syrius_mobile/utils/utils.dart';

class SharedPrefsService {
  static Box? _sharedPrefsBox;

  static SharedPrefsService? _instance;

  static Future<SharedPrefsService?> getInstance() async {
    _instance ??= SharedPrefsService();
    await _checkIfBoxIsOpen();
    return _instance;
  }

  T? get<T>(String key, {T? defaultValue}) {
    try {
      return _sharedPrefsBox!.get(
        key,
        defaultValue: defaultValue,
      ) as T?;
    } on Exception {
      return defaultValue;
    }
  }

  Future<void> close() async => await _sharedPrefsBox!.close();

  Future<void> put(String key, dynamic value) async =>
      await _sharedPrefsBox!.put(
        key,
        value,
      );

  static Future<void> _checkIfBoxIsOpen() async {
    if (_sharedPrefsBox == null || !_sharedPrefsBox!.isOpen) {
      _sharedPrefsBox = await Hive.openBox(kSharedPrefsBox);
    }
  }
}
