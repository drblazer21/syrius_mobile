import 'package:flutter/foundation.dart';
import 'package:syrius_mobile/btc/btc.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:web3dart/web3dart.dart';
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
  final int keyPairIndex = kDefaultAddressList.indexOf(findAppAddress(address));

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

Future<String> generateNewAddressByIndex({required int index}) async {
  final KeyPair newKeyPair = await getKeyPair(index);

  switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
    case BlockChain.btc:
      final NetworkType networkType =
          kSelectedAppNetworkWithAssets!.network.type;

      switch (networkType) {
        case NetworkType.mainnet:
          return await generateTaprootAddress(index: index);
        case NetworkType.testnet:
          return await generateBtcTestnetAddress(index: index);
      }
    case BlockChain.evm:
      final Credentials credentials = await generateCredentialsByIndex(
        index: index,
      );
      final EthereumAddress ethereumAddress = credentials.address;
      return ethereumAddress.hex;
    case BlockChain.nom:
      final Address znnAddress = await newKeyPair.address;
      return znnAddress.toString();
  }
}
