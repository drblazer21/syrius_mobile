import 'dart:async';

import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

String getLabel(String address) => kAddressLabelMap[address] ?? address;

Future<void> generateNewAddress() async {
  final int newAddressIndex = kDefaultAddressList.length;

  final Address newAddress = await generateAddressByIndex(newAddressIndex);

  final Box addressesBox = Hive.box(kAddressesBox);
  await addressesBox.add(newAddress.toString());
  _initAddresses(addressesBox);
  _refreshBlocs();
  final Box addressLabelsBox = Hive.box(kAddressLabelsBox);
  await addressLabelsBox.put(
    newAddress.toString(),
    'Address ${kDefaultAddressList.length}',
  );
  _initAddressLabels(addressLabelsBox);
  addUnreceivedTransactionsByAddress(newAddress);
}

// These blocs need to be refreshed so that they call RPCs for the newly
// generated address also
void _refreshBlocs() {
  sl.get<BalanceBloc>().getForAllAddresses();
  sl.get<PlasmaStatsBloc>().get();
}

Future<void> setAddressLabels() async {
  final Box addressLabelsBox = await Hive.openBox(kAddressLabelsBox);

  if (addressLabelsBox.isEmpty) {
    for (final address in kDefaultAddressList) {
      await addressLabelsBox.put(
        address,
        'Address ${kDefaultAddressList.indexOf(address) + 1}',
      );
    }
  }
  _initAddressLabels(addressLabelsBox);
}

Future<void> setDefaultAddress() async {
  Logger('AddressUtils').log(
    Level.INFO,
    'setDefaultAddress',
    sharedPrefsService.get(kDefaultAddressKey),
  );

  if (sharedPrefsService.get(kDefaultAddressKey) == null) {
    await sharedPrefsService.put(
      kDefaultAddressKey,
      kDefaultAddressList[0],
    );
  }
  kSelectedAddress = sharedPrefsService.get(kDefaultAddressKey);
}

Future initAppAddress() async {
  final Box addressesBox = await Hive.openBox(kAddressesBox);
  _initAddresses(addressesBox);
  final Box addressLabelsBox = await Hive.openBox(kAddressLabelsBox);
  _initAddressLabels(addressLabelsBox);
}

Future<void> setAddresses() async {
  final Box addressesBox = await Hive.openBox(kAddressesBox);

  if (addressesBox.isEmpty) {
    final List<Future<String>> newFutureAddresses = List.generate(
      kNumOfInitialAddresses,
      (index) async {
        final Address address = await generateAddressByIndex(index);

        return address.toString();
      },
    );

    final List<String> newAddresses =
        await Future.wait<String>(newFutureAddresses);

    for (final String address in newAddresses) {
      addressesBox.add(address);
    }
  }

  _initAddresses(addressesBox);
}

String shortenWalletAddress(
  String address, {
  int prefixCharactersCount = 3,
}) {
  final int length = address.length;
  return '${address.substring(
    0,
    prefixCharactersCount,
  )}...${address.substring(
    length - 3,
  )}';
}

void _initAddresses(Box addressesBox) =>
    kDefaultAddressList = List<String>.from(addressesBox.values);

void _initAddressLabels(Box box) =>
    kAddressLabelMap = box.keys.toList().fold<Map<String, String>>(
      {},
      (previousValue, key) {
        previousValue[key as String] = box.get(key) as String;
        return previousValue;
      },
    );
