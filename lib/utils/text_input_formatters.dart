import 'package:flutter/services.dart';

List<TextInputFormatter> generateAmountTextInputFormatters({
  required String replacementString,
  required int maxDecimals,
}) {
  final String decimalsRegexPatter = '^\\d+(\\.\\d{0,$maxDecimals})?\$';
  return [
    FilteringTextInputFormatter.allow(
      RegExp(decimalsRegexPatter),
      replacementString: replacementString,
    ),
    FilteringTextInputFormatter.deny(
      RegExp(r'^0\d+'),
      replacementString: replacementString,
    ),
  ];
}

List<TextInputFormatter> onlyIntegersTextInputFormatters({
  required String replacementString,
}) =>
    [
      FilteringTextInputFormatter.allow(
        RegExp(r'^[1-9]\d*$'),
        replacementString: replacementString,
      ),
    ];
