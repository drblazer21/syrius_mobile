import 'package:flutter/material.dart';
import 'package:syrius_mobile/btc/btc.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:web3dart/credentials.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

enum BlockChain {
  btc,
  nom,
  evm;

  String get displayName {
    switch (this) {
      case BlockChain.nom:
        return 'NoM';
      default:
        return name.toUpperCase();
    }
  }

  String get iconFileName {
    switch (this) {
      case btc:
        return 'btc_icon';
      case nom:
        return 'zn_icon';
      case evm:
        return 'eth_icon';
    }
  }

  Color get bgColor {
    switch (this) {
      case btc:
        return const Color(0xFFF7931A);
      case nom:
        return znnColor.withOpacity(0.3);
      case evm:
        return Colors.white.withOpacity(0.7);
    }
  }

  bool get isSelected =>
      kSelectedAppNetworkWithAssets!.network.blockChain == this;

  dynamic Function(String) get addressParser {
    switch (this) {
      case btc:
        return btcAddressValidator;
      case evm:
        return EthereumAddress.fromHex;
      case nom:
        return Address.parse;
    }
  }

  String? Function(String) get networkUrlValidator {
    switch (this) {
      case btc:
        return btcUrlNetworkValidator;
      case evm:
        return urlValidator;
      case nom:
        return znnWsUrlValidator;
    }
  }

  String get networkUrlHintText {
    switch (this) {
      case btc:
        return 'https://electrum.blockstream.info:50002';
      case evm:
        return 'http(s)://host';
      case nom:
        return 'ws(s)://host:port';
    }
  }

  bool get isSupportedByWalletConnect => [evm, nom].contains(this);

  List<Color> get animateGradientPrimaryColors {
    switch (this) {
      case btc:
        return kBtcAnimateGradientPrimaryColors;
      case evm:
        return kEthAnimateGradientPrimaryColors;
      case nom:
        return kNoMAnimateGradientPrimaryColors;
    }
  }

  List<Color> get animateGradientSecondaryColors {
    switch (this) {
      case btc:
        return kBtcAnimateGradientSecondaryColors;
      case evm:
        return kEthAnimateGradientSecondaryColors;
      case nom:
        return kNoMAnimateGradientSecondaryColors;
    }
  }
}
