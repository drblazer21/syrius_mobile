import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

enum PlasmaLevel {
  average,
  high,
  insufficient,
  low;

  Color get color {
    if (this == PlasmaLevel.high) {
      return znnColor;
    } else if (this == PlasmaLevel.average) {
      return Colors.yellow;
    } else if (this == PlasmaLevel.low) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }
}
