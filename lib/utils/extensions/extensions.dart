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
  String toStringWithDecimals(int decimals) {
    return addDecimals(decimals).toPlainString();
  }

  BigDecimal addDecimals(int decimals) {
    if (this == BigInt.zero) {
      return BigDecimal.zero;
    }
    return BigDecimal.createAndStripZerosForScale(this, decimals, 0);
  }
}

extension ShortString on String {
  String get short {
    final longString = this;
    return '${longString.substring(0, 6)}...'
        '${longString.substring(longString.length - 6)}';
  }
}

// This extension takes other list with fewer elements and creates a single one
// by interleaving them, starting with the first element of the first list,
// then the first element of the second list. If second list runs out of elements
// then we continue with the elements from the first list
extension ZipTwoLists on List {
  List<T> zip<T>(List<T> smallerList) {
    return fold(
      <T>[],
          (previousValue, element) {
        final int elementIndex = indexOf(element);
        previousValue.add(element as T);
        if (elementIndex < smallerList.length) {
          previousValue.add(
            smallerList[elementIndex],
          );
        }
        return previousValue;
      },
    );
  }
}
