import 'package:flutter/material.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/utils/utils.dart';

class SelectedAddressNotifier extends ChangeNotifier {
  void changeAddress(AppAddress newSelectedAddress) {
    selectedAddress = newSelectedAddress;
    refreshBlocs();
    notifyListeners();
  }

  void changedAddressLabel() {
    notifyListeners();
  }
}
