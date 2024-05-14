import 'package:flutter/material.dart';

extension ClearSecurely on List<String> {
  void clearSecurely() {
    fillRange(0, length, '');
    clear();
  }
}

extension DisposeSecurely on TextEditingController {
  void disposeSecurely() {
    text = '' * text.length;
    dispose();
  }
}
