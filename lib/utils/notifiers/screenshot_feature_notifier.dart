import 'package:flutter/material.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/constants.dart';

class ScreenshotFeatureNotifier extends ChangeNotifier {
  bool _isEnabled = sharedPrefs.getBool(
    kIsScreenshotFeatureEnabledKey,
  ) ?? false;

  bool get isEnabled => _isEnabled;

  set isEnabled(bool newValue) {
    _isEnabled = newValue;
    notifyListeners();
  }
}
