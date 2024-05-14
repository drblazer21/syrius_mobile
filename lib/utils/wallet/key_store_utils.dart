import 'package:flutter/foundation.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

Future<KeyStore?> getKeyStore() async {
  final String entropy = await secureStorageUtil.read(
    kKeyStoreKey,
  );
  if (entropy.isNotEmpty) {
    return await compute(KeyStore.fromEntropy, entropy);
  }
  return null;
}

/// When this method is called, we are certain that a keyStore, hence a
/// mnemonic exists
Future<List<String>> getMnemonicAsList() async {
  final String mnemonic = (await getMnemonic())!;
  return mnemonic.split(' ');
}

Future<String?> getMnemonic() async {
  final KeyStore? keyStore = await getKeyStore();

  if (keyStore != null) {
    return keyStore.mnemonic;
  }
  return null;
}

Future<void> saveEntropy(String entropy) => secureStorageUtil.write(
      key: kKeyStoreKey,
      value: entropy,
    );

Future<KeyPair> getKeyPairFromAddress(String address) async {
  final int keyPairIndex = kDefaultAddressList.indexOf(address);

  final KeyPair keyPair = await getKeyPair(keyPairIndex);

  return keyPair;
}

Future<KeyPair> getKeyPair(int index) async {
  final KeyStore? keyStore = await getKeyStore();

  final KeyPair keyPair = await compute(
    (message) => keyStore!.getKeyPair(
      message,
    ),
    index,
  );

  return keyPair;
}

Future<Address> generateAddressByIndex(int index) async {
  final KeyPair newKeyPair = await getKeyPair(index);

  final Address newAddress = await newKeyPair.getAddress();

  return newAddress;
}
