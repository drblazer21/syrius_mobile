import 'package:logging/logging.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:wallet_connect_uri_validator/wallet_connect_uri_validator.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

String? minimumLength({
  required String invalidErrorText,
  required int minimumLength,
  required String? value,
  required String nullErrorText,
}) {
  final int length = value?.length ?? 0;
  if (value == null) {
    return nullErrorText;
  } else if (length > 0 && length < minimumLength || length > minimumLength) {
    return invalidErrorText;
  }
  return null;
}

String? nodeValidator(String? node) {
  if (node != null && node.isEmpty) {
    return null;
  } else if (node != null &&
      RegExp(
        r'^(wss?://)([0-9]{1,3}(?:.[0-9]{1,3}){3}|[^/]+):([0-9]{1,5})$',
      ).hasMatch(node)) {
    return null;
  }
  return 'Node is not valid';
}

String? correctValueSyrius(
  String? value,
  BigInt maxValue,
  int decimals,
  BigInt minValue, {
  bool canBeEqualToMin = false,
  bool canBeBlank = false,
}) {
  if (value != null) {
    try {
      if (maxValue == BigInt.zero) {
        return 'Empty balance';
      }
      if (value.isEmpty) {
        if (canBeBlank) {
          return null;
        } else {
          return 'Enter a valid amount';
        }
      }

      final BigInt inputNum = value.extractDecimals(decimals);

      if (value.contains('.') && value.split('.')[1].length > decimals) {
        return 'Inputted number has too many decimals';
      }
      if (maxValue < minValue) {
        return 'Your available balance must be at least ${minValue.addDecimals(decimals)}';
      }
      if (canBeEqualToMin) {
        return minValue <= inputNum && inputNum <= maxValue
            ? null
            : maxValue == minValue
                ? 'Value must be  ${minValue.addDecimals(decimals)}'
                : 'Value must be between ${minValue.addDecimals(decimals)} and ${maxValue.addDecimals(decimals)}';
      }
      return minValue < inputNum && inputNum <= maxValue
          ? null
          : maxValue == minValue
              ? 'Value must be ${minValue.addDecimals(decimals)}'
              : 'Value must be between ${minValue.addDecimals(decimals)} and ${maxValue.addDecimals(decimals)}';
    } catch (e, stackTrace) {
      Logger('InputValidators')
          .log(Level.SEVERE, 'correctValueSyrius', e, stackTrace);
      return 'Error';
    }
  }
  return "Value can't be empty";
}

String? checkAddress(String? value) {
  if (value != null) {
    if (value.isEmpty) {
      return 'Enter an address';
    }

    return Address.isValid(value) ? null : 'Invalid address';
  } else {
    return 'Value is null';
  }
}

bool canParseWalletConnectUri(String wcUri) {
  WalletConnectUri? walletConnectUri;
  walletConnectUri = WalletConnectUri.tryParse(wcUri);
  if (walletConnectUri != null) {
    return true;
  }

  return false;
}

String? chainIdValidator(String? value) {
  if (value == null) {
    return "Value can't be empty";
  }
  return null;
}
