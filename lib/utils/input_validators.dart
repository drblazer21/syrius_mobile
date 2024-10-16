import 'package:logging/logging.dart';
import 'package:syrius_mobile/utils/utils.dart';


String? lockTimeValidator(String? value) {
  if (value == null) {
    return 'Input is not valid';
  } else if (value.isNotEmpty) {
    try {
      final int number = int.parse(value);
      if (number >= 0 && number <= 4294967295) {
        return null;
      } else {
        return 'Value must be between 0 and 4294967295';
      }
    } catch (e) {
      return 'Input must be a positive integer';
    }
  } else {
    return null;
  }
}

String? maxPriorityFeePerGasValidator({
  required String maxFeePerGasValue,
  required String maxPriorityFeePerGasValue,
}) {
  if (maxPriorityFeePerGasValue.isNotEmpty) {
    try {
      final BigInt maxFeePerGas =
          maxFeePerGasValue.extractDecimals(kGweiDecimals);
      final BigInt maxPriorityFeePerGas =
          maxPriorityFeePerGasValue.extractDecimals(kGweiDecimals);
      if (maxPriorityFeePerGas > maxFeePerGas) {
        return 'Max priority fee needs to be lower than max base fee';
      }
      return null;
    } catch (e) {
      return 'Value is not valid';
    }
  }
  return null;
}

String? maxFeePerGasValidator(String value) {
  if (value.isNotEmpty) {
    try {
      value.extractDecimals(kGweiDecimals);
      return null;
    } catch (e) {
      return 'Value is invalid';
    }
  }
  return null;
}

// Currently we use the gas consumed in the latest block as a gas limit for a
// single transaction
String? gasLimitValidator({
  required String value,
  required BigInt max,
}) {
  if (value.isNotEmpty) {
    final BigInt current = BigInt.parse(value);
    if (current < kGasLimitMinUnits) {
      return 'Gas limit must be at least $kGasLimitMinUnits';
    } else if (current > max) {
      return 'Gas limit is higher than $max';
    }
  }
  return null;
}

String? networkAssetSymbolValidator(String? value) => minimumLength(
      maxLength: kNetworkAssetSymbolMaxLength,
      minLength: kNetworkAssetSymbolMinLength,
      value: value,
    );

String? networkAssetNameValidator(String? value) => minimumLength(
      maxLength: kNetworkAssetNameMaxLength,
      minLength: kNetworkAssetNameMinLength,
      value: value,
    );

String? minimumLength({
  required String? value,
  required int minLength,
  required int maxLength,
}) {
  if (value != null) {
    if (value.isEmpty) {
      return null;
    } else if (value.length < minLength) {
      return 'Value must be at least $minLength characters';
    } else if (value.length >= maxLength) {
      return "Value can't be over $maxLength characters";
    } else {
      return null;
    }
  }
  return 'Name is not valid';
}

String? fixedLength({
  required String invalidErrorText,
  required int fixedLength,
  required String? value,
  required String nullErrorText,
}) {
  final int length = value?.length ?? 0;
  if (value == null) {
    return nullErrorText;
  } else if (length > 0 && length < fixedLength || length > fixedLength) {
    return invalidErrorText;
  }
  return null;
}

String? znnWsUrlValidator(String? node) {
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

bool isValidUrl(String url) {
  if (url.isEmpty) {
    return false;
  }

  try {
    final Uri uri = Uri.parse(url);
    return uri.hasScheme && uri.host.isNotEmpty;
  } catch (e) {
    return false;
  }
}

String? urlValidator(String url) {
  if (url.isEmpty) {
    return null;
  }

  if (isValidUrl(url)) {
    return null;
  }

  return 'URL is not valid';
}

String? btcUrlNetworkValidator(String url) {
  if (url.isEmpty) {
    return null;
  }

  final Uri? uri = Uri.tryParse(url);

  if (uri != null) {
    final String scheme = uri.scheme;
    final bool isSecure = scheme == 'https';

    if (!isSecure) {
      return 'URL must be secure, starting with https';
    }

    final int port = uri.port;
    final bool urlContainsPort = url.contains(':$port');

    if (!urlContainsPort) {
      return 'URL must contain the port also';
    }

    return null;
  }

  return 'URL is not valid';
}

String? acceleratorProjectUrlValidator(String url) {
  if (url.isEmpty) {
    return "URL can't be empty";
  } else if (RegExp(
    r'^([Hh][Tt][Tt][Pp][Ss]?://)?[a-zA-Z0-9]{2,60}\.[a-zA-Z]{1,6}([-a-zA-Z0-9()@:%_+.~#?&/=]{0,100})$',
  ).hasMatch(url)) {
    return null;
  }

  return 'URL is not valid';
}

String? networkNameValidator({
  required String? name,
}) {
  const int characterLimit = 35;

  if (name != null) {
    if (name.isEmpty) {
      return null;
    } else {
      if (name.length >= characterLimit) {
        return "Name can't be over $characterLimit characters";
      } else {
        return null;
      }
    }
  }
  return 'Name is not valid';
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
        return 'Your available balance must be at least ${minValue.toStringWithDecimals(decimals)}';
      }
      if (canBeEqualToMin) {
        return minValue <= inputNum && inputNum <= maxValue
            ? null
            : maxValue == minValue
                ? 'Value must be  ${minValue.toStringWithDecimals(decimals)}'
                : 'Value must be between ${minValue.toStringWithDecimals(decimals)} and ${maxValue.toStringWithDecimals(decimals)}';
      }
      return minValue < inputNum && inputNum <= maxValue
          ? null
          : maxValue == minValue
              ? 'Value must be ${minValue.toStringWithDecimals(decimals)}'
              : 'Value must be between ${minValue.toStringWithDecimals(decimals)} and ${maxValue.toStringWithDecimals(decimals)}';
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
    try {
      kSelectedAppNetworkWithAssets!.network.blockChain.addressParser(value);
      return null;
    } catch (_) {
      return 'Invalid address';
    }
  } else {
    return 'Value is null';
  }
}

bool canParseWalletConnectUri(String wcUri) {
  Uri? walletConnectUri;
  walletConnectUri = Uri.tryParse(wcUri);
  if (walletConnectUri != null && walletConnectUri.scheme == 'wc') {
    return true;
  }

  return false;
}

String? chainIdValidator(String? chainId) {
  if (chainId != null) {
    if (chainId.isEmpty) {
      return null;
    } else {
      try {
        int.parse(chainId);
        return null;
      } catch (_) {
        return 'Chain ID must be a number';
      }
    }
  }
  return 'Chain ID is not valid';
}
