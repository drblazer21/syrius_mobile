import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/btc/bitcoin_utils.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:web3dart/credentials.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

AppAddress findAppAddress(String value) => addressList.firstWhere(
      (appAddress) => appAddress.hex == value,
    );

String getLabel(String address) {
  return addressList
          .firstWhereOrNull(
            (appAddress) => appAddress.hex == address,
          )
          ?.label ??
      address;
}

Future<void> generateNewAddress() async {
  final int newAddressIndex = addressList.length;

  final String newAddressHex =
      await generateNewAddressByIndex(index: newAddressIndex);

  final BlockChain blockChain =
      kSelectedAppNetworkWithAssets!.network.blockChain;
  final String label = generateLabel(
    blockChain: blockChain,
    hex: newAddressHex,
    index: newAddressIndex,
  );
  final NetworkType networkType = kSelectedAppNetworkWithAssets!.network.type;

  final int? bitcoinNetVersion =
      BlockChain.btc.isSelected ? networkType.index : null;

  final AppAddressesCompanion newAppAddress = AppAddressesCompanion.insert(
    index: newAddressIndex,
    bitcoinNetVersion: Value(bitcoinNetVersion),
    blockChain: blockChain,
    hex: newAddressHex,
    label: label,
  );

  await db.appAddressesDao.insert(newAppAddress);
  await refreshAddresses();
  refreshBlocs();
  if (BlockChain.nom.isSelected) {
    final Address address = Address.parse(newAddressHex);

    addUnreceivedTransactionsByAddress(address);
    subscribeToUnreceivedAccountBlocksByAddress(address: address);
  }
}

Future<void> refreshAddresses() async {
  await _initAddresses(
    oldList: addressList,
    blockChain: kSelectedAppNetworkWithAssets!.network.blockChain,
    networkType: kSelectedAppNetworkWithAssets!.network.type,
  );
}

// These blocs need to be refreshed so that they call RPCs for the newly
// generated address also
void refreshBlocs() {
  switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
    case BlockChain.btc:
      sl.get<BtcAccountBalanceBloc>().fetch(addressHex: selectedAddress.hex);
      sl.get<BtcActivityBloc>().fetch(addressHex: selectedAddress.hex);
    case BlockChain.evm:
      sl
          .get<EthAccountBalanceBloc>()
          .fetch(address: selectedAddress.toEthAddress());
    case BlockChain.nom:
      refreshBalanceAndTx();
      sl.get<PlasmaStatsBloc>().get();
  }
}

Future<AppAddress> getDefaultAddress({
  required String defaultAppAddressIdKey,
  required AppAddress initialAppAddress,
}) async {
  if (sharedPrefs.getInt(defaultAppAddressIdKey) == null) {
    await sharedPrefs.setInt(
      defaultAppAddressIdKey,
      initialAppAddress.id,
    );
  }

  final int appAddressId = sharedPrefs.getInt(defaultAppAddressIdKey)!;

  return await db.managers.appAddresses
      .filter((f) => f.id(appAddressId))
      .getSingle();
}

Future<void> setAddresses() async {
  final int appAddressesCount = await db.managers.appAddresses.count();

  if (appAddressesCount == 0) {
    await Future.wait(
      [
        _generateZnnAddress(),
        _generateEthAddress(),
        _generateBtcTestAddress(),
        _generateBtcTaprootAddress(),
      ],
    );
  }

  await Future.wait([
    _initAddresses(
      oldList: kDefaultAddressList,
      blockChain: BlockChain.nom,
    ),
    _initAddresses(
      oldList: kEthDefaultAddressList,
      blockChain: BlockChain.evm,
    ),
    _initAddresses(
      oldList: kBtcTestAddressList,
      blockChain: BlockChain.btc,
      networkType: NetworkType.testnet,
    ),
    _initAddresses(
      oldList: kBtcTaprootAddressList,
      blockChain: BlockChain.btc,
      networkType: NetworkType.mainnet,
    ),
  ]);
}

Future<void> _generateZnnAddress() async {
  final List<Future<AppAddressesCompanion>> newFutureAddresses = List.generate(
    kNumOfInitialAddresses,
    (index) async {
      final Address address = await generateAddressByIndex(index);
      const BlockChain blockChain = BlockChain.nom;
      final String hex = address.toString();
      final String label = generateLabel(
        blockChain: blockChain,
        hex: hex,
        index: index,
      );

      return AppAddressesCompanion.insert(
        blockChain: BlockChain.nom,
        hex: hex,
        label: label,
        index: index,
      );
    },
  );

  final List<AppAddressesCompanion> newAddresses =
      await Future.wait<AppAddressesCompanion>(newFutureAddresses);

  await db.appAddressesDao.insertMultiple(newAddresses);
}

Future<void> _generateEthAddress() async {
  final List<Future<AppAddressesCompanion>> newFutureAddresses = List.generate(
    kNumOfInitialAddresses,
    (index) async {
      final Credentials credentials =
          await generateCredentialsByIndex(index: index);

      final EthereumAddress ethereumAddress = credentials.address;
      const BlockChain blockChain = BlockChain.evm;
      final String hex = ethereumAddress.hex;
      final String label = generateLabel(
        blockChain: blockChain,
        hex: hex,
        index: index,
      );

      return AppAddressesCompanion.insert(
        blockChain: blockChain,
        hex: hex,
        index: index,
        label: label,
      );
    },
  );

  final List<AppAddressesCompanion> newAddresses =
      await Future.wait<AppAddressesCompanion>(newFutureAddresses);

  await db.appAddressesDao.insertMultiple(newAddresses);
}

Future<void> _generateBtcTestAddress() async {
  final List<Future<AppAddressesCompanion>> newFutureAddresses = List.generate(
    kNumOfInitialAddresses,
    (index) async {
      final String hex = await generateBtcTestnetAddress(index: index);
      const BlockChain blockChain = BlockChain.btc;
      final String label = generateLabel(
        blockChain: blockChain,
        hex: hex,
        index: index,
      );

      return AppAddressesCompanion.insert(
        bitcoinNetVersion: Value(NetworkType.testnet.index),
        blockChain: BlockChain.btc,
        hex: hex,
        index: index,
        label: label,
      );
    },
  );

  final List<AppAddressesCompanion> newAddresses =
      await Future.wait<AppAddressesCompanion>(newFutureAddresses);

  await db.appAddressesDao.insertMultiple(newAddresses);
}

Future<void> _generateBtcTaprootAddress() async {
  final List<Future<AppAddressesCompanion>> newFutureAddresses = List.generate(
    kNumOfInitialAddresses,
    (index) async {
      final String hex = await generateTaprootAddress(index: index);
      const BlockChain blockChain = BlockChain.btc;
      final String label = generateLabel(
        blockChain: blockChain,
        hex: hex,
        index: index,
      );

      return AppAddressesCompanion.insert(
        bitcoinNetVersion: Value(NetworkType.mainnet.index),
        blockChain: BlockChain.btc,
        hex: hex,
        index: index,
        label: label,
      );
    },
  );

  final List<AppAddressesCompanion> newAddresses =
      await Future.wait<AppAddressesCompanion>(newFutureAddresses);

  await db.appAddressesDao.insertMultiple(newAddresses);
}

String shortenWalletAddress(
  String address, {
  int prefixCharactersCount = 6,
  int suffixCharactersCount = 3,
}) {
  final int length = address.length;
  return '${address.substring(
    0,
    prefixCharactersCount,
  )}...${address.substring(
    length - suffixCharactersCount,
  )}';
}

Future<void> _initAddresses({
  required List<AppAddress> oldList,
  required BlockChain blockChain,
  NetworkType? networkType,
}) async {
  final List<AppAddress> newList = await db.appAddressesDao.filter(
    blockChain: blockChain,
    networkType: networkType,
  );

  oldList.clear();
  oldList.addAll(newList);
}

String generateLabel({
  required BlockChain blockChain,
  required String hex,
  required int index,
}) =>
    '${blockChain.displayName} $index ${shortenWalletAddress(
      hex,
      prefixCharactersCount: 5,
    )}';
