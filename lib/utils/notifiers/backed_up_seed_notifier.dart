import 'package:flutter/material.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/constants.dart';

class BackedUpSeedNotifier extends ChangeNotifier {
  bool _isBackedUp = sharedPrefsService.get<bool>(
    kIsBackedUpKey,
    defaultValue: false,
  )!;

  bool get isBackedUp => _isBackedUp;

  set isBackedUp(bool newValue) {
    _isBackedUp = newValue;
    notifyListeners();
  }
}
