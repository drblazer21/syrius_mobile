import 'dart:typed_data';

import 'package:syrius_mobile/utils/constants.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3_provider/web3_provider.dart';

class JsBridgeParams {
  int? chainId;
  int? gas;
  EtherAmount? value;
  String? from;
  EthereumAddress? to;
  Uint8List? data;
  String? gasPrice;
  int? nonce;

  JsBridgeParams({
    this.chainId,
    this.value,
    this.to,
    this.data,
    this.from,
    this.gas,
  });

  JsBridgeParams.fromJson(Map<String, dynamic> json) {
    final String? jsonChainId = json['chainId'] as String?;
    chainId = jsonChainId == null ? null : hexToDartInt(jsonChainId);
    final String? jsonGas = json["gas"] as String?;
    gas = jsonGas == null ? null : hexToDartInt(jsonGas);
    final String? jsonPrice = json["gasPrice"] as String?;
    gasPrice = jsonPrice == null ? null : hexToInt(jsonPrice).tokenString(kGweiDecimals);
    final BigInt? weiValue = BigInt.tryParse(
      (json['value'] as String? ?? "0").replaceAll("0x", ""),
      radix: 16,
    );
    value = weiValue != null
        ? EtherAmount.fromBigInt(EtherUnit.wei, weiValue)
        : null;
    from = json['from'] as String?;
    final String? jsonTo = json['to'] as String?;
    to = jsonTo != null ? EthereumAddress.fromHex(jsonTo) : null;
    final String? jsonData = json['data'] as String?;
    data = jsonData != null ? hexToBytes(jsonData) : null;
    nonce =
        json['nonce'] != null ? hexToDartInt(json['nonce'] as String) : null;
  }
}
