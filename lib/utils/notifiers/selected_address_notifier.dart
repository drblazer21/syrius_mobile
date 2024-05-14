import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class SelectedAddressNotifier extends ChangeNotifier {
  void changeAddress(String newSelectedAddress) {
    kSelectedAddress = newSelectedAddress;
    notifyListeners();
  }

  void changedAddressLabel() {
    notifyListeners();
  }
}
