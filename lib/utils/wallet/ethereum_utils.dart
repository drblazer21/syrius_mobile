import 'package:bip39/bip39.dart' as bip39;
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/services.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

int getEthAddressIndex({required String address}) =>
    kEthDefaultAddressList.map((e) => e.hex).toList().indexOf(
          address,
        );

Future<String> getPrivateKey({required String address}) async {
  final int index = getEthAddressIndex(address: address);

  final ExtendedKey extendedKey = await getExtendedKey(index: index);

  return extendedKey.privateKeyHex();
}

Future<ExtendedKey> getExtendedKey({required int index}) async {
  final String ethDerivationPath = "m/44'/60'/0'/0/$index";
  final String? mnemonic = await getMnemonic();
  final Chain chain = Chain.seed(
    bip39.mnemonicToSeedHex(mnemonic!),
  );
  return chain.forPath(ethDerivationPath);
}

Future<Credentials> generateCredentialsByIndex({required int index}) async {
  final ExtendedKey key = await getExtendedKey(index: index);
  final Credentials credentials = EthPrivateKey.fromHex(key.privateKeyHex());
  return credentials;
}

Future<Credentials> generateCredentials({
  required String address,
}) async {
  final int index = getEthAddressIndex(address: address);

  final Credentials credentials = await generateCredentialsByIndex(
    index: index,
  );

  return credentials;
}

List<dynamic> decodeParameters(ContractFunction function, Uint8List data) {
  final decoded = [];
  // The first 4 bytes are always the function identifier
  int offset = 4;
  for (final param in function.parameters) {
    final type = param.type;
    Object value;
    if (type.name.startsWith('uint') || type.name.startsWith('int')) {
      value = decodeBigInt(data.sublist(offset, offset + 32));
      offset += 32;
    } else if (type.name == 'address') {
      value = decodeAddress(data.sublist(offset + 12, offset + 32));
      offset += 32;
    } else if (type.name == 'bool') {
      value = data[offset] != 0;
      offset += 32;
    } else if (type.name == 'bytes' || type.name.startsWith('bytes')) {
      final length = decodeBigInt(data.sublist(offset, offset + 32)).toInt();
      offset += 32;
      value = data.sublist(offset, offset + length);
      offset += length;
    } else if (type.name == 'string') {
      final length = decodeBigInt(data.sublist(offset, offset + 32)).toInt();
      offset += 32;
      value = String.fromCharCodes(data.sublist(offset, offset + length));
      offset += length;
    } else {
      throw UnsupportedError('Unsupported parameter type: $type');
    }
    decoded.add(value);
  }
  return decoded;
}

EthereumAddress decodeAddress(Uint8List data) {
  return EthereumAddress.fromHex('0x${bytesToHex(data)}');
}

BigInt decodeBigInt(Uint8List data) {
  return BigInt.parse(bytesToHex(data), radix: 16);
}
