import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_integrity_checker/app_integrity_checker.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/app_integrity.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void refreshBalanceAndTx() {
  sl.get<BalanceBloc>().getForAllAddresses();
  sl.get<LatestTransactionsBloc>().refreshResults();
}

Future<void> initApp() async {
  try {
    await initAppAddress();
    await setNode();
    await setChainId();
    await loadDbNodes();
  } catch (e, stackTrace) {
    Logger('MiscUtils').log(
      Level.SEVERE,
      'initApp',
      e,
      stackTrace,
    );
    rethrow;
  }
}

String getAddress() {
  switch (kSelectedNetwork) {
    case AppNetwork.znn:
      return kSelectedAddress!;
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
  await setAddressLabels();
  await setDefaultAddress();

  if (kSelectedNetwork == AppNetwork.znn) {
    zenon.defaultKeyPair = await getKeyPairFromAddress(kSelectedAddress!);

    await _openNotificationsBox();
    await _openRecipientBox();
  }

  await initWebSocketClient();
}

Future<void> _openNotificationsBox() async =>
    await Hive.openBox<WalletNotification>(kNotificationsBox);

Future<void> _openRecipientBox() async =>
    await Hive.openBox(kRecipientAddressBox);

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
