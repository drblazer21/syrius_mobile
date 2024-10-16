import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_integrity_checker/app_integrity_checker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/app_integrity.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/utils/wallet_connect/functions.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void refreshBalanceAndTx() {
  sl.get<BalanceBloc>().get();
  sl.get<LatestTransactionsBloc>().refreshResults();
}

AppAddress get selectedAddress {
  switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
    case BlockChain.btc:
      final NetworkType networkType =
          kSelectedAppNetworkWithAssets!.network.type;

      switch (networkType) {
        case NetworkType.mainnet:
          return kBtcTaprootSelectedAddress!;
        case NetworkType.testnet:
          return kBtcTestSelectedAddress!;
      }
    case BlockChain.evm:
      return kEthSelectedAddress!;
    case BlockChain.nom:
      return kSelectedAddress!;
  }
}

set selectedAddress(AppAddress newAddress) {
  switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
    case BlockChain.btc:
      final NetworkType networkType =
          kSelectedAppNetworkWithAssets!.network.type;

      switch (networkType) {
        case NetworkType.mainnet:
          kBtcTaprootSelectedAddress = newAddress;
        case NetworkType.testnet:
          kBtcTestSelectedAddress = newAddress;
      }
    case BlockChain.evm:
      kEthSelectedAddress = newAddress;
    case BlockChain.nom:
      kSelectedAddress = newAddress;
  }
}

List<AppAddress> get addressList {
  switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
    case BlockChain.btc:
      final NetworkType networkType =
          kSelectedAppNetworkWithAssets!.network.type;

      switch (networkType) {
        case NetworkType.mainnet:
          return kBtcTaprootAddressList;
        case NetworkType.testnet:
          return kBtcTestAddressList;
      }
    case BlockChain.evm:
      return kEthDefaultAddressList;
    case BlockChain.nom:
      return kDefaultAddressList;
  }
}

String get defaultAddressKey {
  switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
    case BlockChain.btc:
      final NetworkType networkType =
          kSelectedAppNetworkWithAssets!.network.type;

      switch (networkType) {
        case NetworkType.mainnet:
          return kBtcTaprootDefaultAppAddressIdKey;
        case NetworkType.testnet:
          return kBtcTestDefaultAppAddressIdKey;
      }
    case BlockChain.evm:
      return kEthDefaultAppAddressIdKey;
    case BlockChain.nom:
      return kDefaultAppAddressIdKey;
  }
}

set addressList(List<AppAddress> newList) => addressList
  ..clear()
  ..addAll(newList);

String get chainIdBoxKey {
  switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
    case BlockChain.btc:
      return kBtcChainIdKey;
    case BlockChain.evm:
      return kEthChainIdKey;
    case BlockChain.nom:
      return kChainIdKey;
  }
}

Future<List<PillarDetail>> getPillarDetail() async {
  final url = Uri.parse(kZenonToolsPillarsEndpoint);
  final response = await http.get(
    url,
  );
  if (response.statusCode == 200) {
    final Map<String, Map<String, dynamic>> decodedJson =
        json.decode(response.body) as Map<String, Map<String, dynamic>>;
    final List<PillarDetail> pillarDetails = decodedJson.keys
        .map((e) => PillarDetail.fromJson(e, decodedJson[e]!))
        .toList();
    return pillarDetails;
  }
  return [];
}

PlasmaStatus getPlasmaStatus(PlasmaInfo plasmaInfo) {
  if (plasmaInfo.currentPlasma >= kPowerUserPlasmaRequirements.reduce(max)) {
    return PlasmaStatus.instant;
  } else if (plasmaInfo.currentPlasma >= kUserPlasmaRequirements.reduce(max)) {
    return PlasmaStatus.fast;
  } else if (BigInt.from(plasmaInfo.currentPlasma) >= minPlasmaAmount) {
    return PlasmaStatus.average;
  } else {
    return PlasmaStatus.slow;
  }
}

Future<void> initWalletAfterDecrypt() async {
  await setAddresses();
  final List<AppAddress> addresses = await Future.wait(
    [
      getDefaultAddress(
        defaultAppAddressIdKey: kDefaultAppAddressIdKey,
        initialAppAddress: kDefaultAddressList.first,
      ),
      getDefaultAddress(
        defaultAppAddressIdKey: kEthDefaultAppAddressIdKey,
        initialAppAddress: kEthDefaultAddressList.first,
      ),
      getDefaultAddress(
        defaultAppAddressIdKey: kBtcTestDefaultAppAddressIdKey,
        initialAppAddress: kBtcTestAddressList.first,
      ),
      getDefaultAddress(
        defaultAppAddressIdKey: kBtcTaprootDefaultAppAddressIdKey,
        initialAppAddress: kBtcTaprootAddressList.first,
      ),
    ],
  );
  kSelectedAddress = addresses[0];
  kEthSelectedAddress = addresses[1];
  kBtcTestSelectedAddress = addresses[2];
  kBtcTaprootSelectedAddress = addresses[3];

  switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
    case BlockChain.btc:
      await btc.init(appNetwork: kSelectedAppNetworkWithAssets!.network);
      sl.get<BtcAccountBalanceBloc>().fetch(
            addressHex: selectedAddress.hex,
          );
      sl.get<BtcEstimateFeeBloc>().start();
    case BlockChain.evm:
      await eth.initialize(kSelectedAppNetworkWithAssets!.network.url);
      sl.get<EthAccountBalanceBloc>().fetch(
            address: kEthSelectedAddress!.toEthAddress(),
          );
      sl.get<GasPriceBloc>().start();
    case BlockChain.nom:
      chainId = kSelectedAppNetworkWithAssets!.network.chainId!;
      await initZnnWebSocketClient(
        url: kSelectedAppNetworkWithAssets!.network.url,
      );
  }

  final List<AppNetwork> appNetworks = await db.managers.appNetworks.get();

  for (final appNetwork in appNetworks) {
    if (appNetwork.blockChain.isSupportedByWalletConnect) {
      registerWcService(appNetwork);
    }
  }
}

Future<AppIntegrity> getAppIntegrityStatus() async {
  String? checksum;
  String? signature;
  bool? isNotTrust;
  bool? isRooted;
  bool? isRealDevice;
  bool? isTampered;
  bool? isOnExternalStorage;

  try {
    checksum = await AppIntegrityChecker.getchecksum();
    signature = await AppIntegrityChecker.getsignature();

    isNotTrust = await JailbreakRootDetection.instance.isNotTrust;
    isRooted = await JailbreakRootDetection.instance.isJailBroken;
    isRealDevice = await JailbreakRootDetection.instance.isRealDevice;
    if (Platform.isIOS) {
      isTampered = await JailbreakRootDetection.instance.isTampered(kBundleId);
    }
    if (Platform.isAndroid) {
      isOnExternalStorage =
          await JailbreakRootDetection.instance.isOnExternalStorage;
    }
  } on PlatformException catch (e, stackTrace) {
    Logger('MiscUtils')
        .log(Level.SEVERE, 'getAppIntegrityStatus', e, stackTrace);
  }
  return AppIntegrity(
    checksum: checksum,
    signature: signature,
    isNotTrust: isNotTrust,
    isRooted: isRooted,
    isRealDevice: isRealDevice,
    isTampered: isTampered,
    isOnExternalStorage: isOnExternalStorage,
  );
}
