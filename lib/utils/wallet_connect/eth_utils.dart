import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:hex/hex.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class EthUtils {
  final addressRegEx = RegExp(
    r'^0x[a-fA-F0-9]{40}$',
    caseSensitive: false,
  );

  String getUtf8Message(String maybeHex) {
    if (maybeHex.startsWith('0x')) {
      final List<int> decoded = HEX.decode(
        maybeHex.substring(2),
      );
      return utf8.decode(decoded);
    }

    return maybeHex;
  }

  dynamic getAddressFromParamsList(dynamic params) {
    return (params as List).firstWhere(
      (p) {
        try {
          if (addressRegEx.hasMatch(p as String)) {
            EthereumAddress.fromHex(p);
            return true;
          }
          return false;
        } catch (e) {
          return false;
        }
      },
      orElse: () => null,
    );
  }

  dynamic getDataFromParamsList(dynamic params) {
    final address = getAddressFromParamsList(params);
    final param = (params as List).firstWhere(
      (p) => p != address,
      orElse: () => null,
    );
    return param;
  }

  Map<String, dynamic>? getTransactionFromParams(dynamic params) {
    final address = getAddressFromParamsList(params);
    final param = (params as List).firstWhere(
      (p) => p != address,
      orElse: () => null,
    );
    return param as Map<String, dynamic>?;
  }

  Future<dynamic> decodeMessageEvent(MessageEvent event) async {
    final w3Wallet = GetIt.I<IWeb3WalletService>().getWeb3Wallet();
    final payloadString = await w3Wallet.core.crypto.decode(
      event.topic,
      event.message,
    );
    if (payloadString == null) return null;

    final data = jsonDecode(payloadString) as Map<String, dynamic>;
    if (data.containsKey('method')) {
      return JsonRpcRequest.fromJson(data);
    } else {
      return JsonRpcResponse.fromJson(data);
    }
  }
}
