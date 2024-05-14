import 'package:flutter/material.dart';

class HistoryScreenControllerNotifier extends ChangeNotifier {
  void redirectToHistoryScreen() {
    notifyListeners();
  }
}
