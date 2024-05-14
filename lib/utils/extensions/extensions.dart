import 'dart:math' show pow;
import 'package:big_decimal/big_decimal.dart';

extension StringExtensions on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${toLowerCase().substring(1)}';
  }

  num toNum() => num.parse(this);

  BigInt extractDecimals(int decimals) {
    if (!contains('.')) {
      if (decimals == 0 && isEmpty) {
        return BigInt.zero;
      }
      return BigInt.parse(this + ''.padRight(decimals, '0'));
    }
    final List<String> parts = split('.');

    return BigInt.parse(
      parts[0] +
          (parts[1].length > decimals
              ? parts[1].substring(0, decimals)
              : parts[1].padRight(decimals, '0')),
    );
  }

  String abs() => this;
}

extension FixedNumDecimals on double {
  String toStringFixedNumDecimals(int numDecimals) {
    return '${(this * pow(10, numDecimals)).truncate() / pow(10, numDecimals)}';
  }
}

extension BigIntExtensions on BigInt {
  String addDecimals(int decimals) {
    return BigDecimal.createAndStripZerosForScale(this, decimals, 0)
        .toPlainString();
  }
}

extension ShortString on String {
  String get short {
    final longString = this;
    return '${longString.substring(0, 6)}...'
        '${longString.substring(longString.length - 6)}';
  }
}
