import 'dart:typed_data';

import 'package:syrius_mobile/utils/wallet/key_store_utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class Signature {
  String signature;
  String publicKey;

  Signature(this.signature, this.publicKey);
}

Future<Signature> walletSign(List<int> message) async {
  final wallet = await getKeyStore();
  final walletAccount = await wallet!.getAccount();
  final List<int> publicKey = await walletAccount.getPublicKey();
  final List<int> signature = await walletAccount.sign(
    Uint8List.fromList(
      message,
    ),
  );
  return Signature(
    BytesUtils.bytesToHex(signature),
    BytesUtils.bytesToHex(publicKey),
  );
}
