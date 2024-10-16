import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syrius_mobile/btc/btc.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:web3dart/credentials.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

extension AppAddressExtension on AppAddress {
  Address toZnnAddress() => Address.parse(hex);

  EthereumAddress toEthAddress() => EthereumAddress.fromHex(hex);
}

extension EthereumTxExtension on EthereumTx {
  bool get isContractInteraction => input.isNotEmpty;
}

extension WalletNotificationExtension on WalletNotification {
  Widget getIcon(BuildContext context) {
    switch (type) {
      case NotificationType.copiedToClipboard:
        return const Icon(
          Icons.content_copy_rounded,
          color: znnColor,
        );
      case NotificationType.nodeSyncing:
        return const Icon(
          Icons.circle_outlined,
          color: Colors.orange,
        );
      case NotificationType.stakingDeactivated:
        return _getCircledIcon('staked', iconColor: Colors.orange);
      case NotificationType.stakeSuccess:
        return _getCircledIcon('staked');
      case NotificationType.delegateSuccess:
        return _getCircledIcon('pillar');
      case NotificationType.needPlasma || NotificationType.plasmaSuccess:
        return const Icon(
          Icons.flash_on,
          color: znnColor,
        );
      case NotificationType.paymentReceived:
        return const Icon(
          Icons.arrow_downward,
          color: znnColor,
        );
      case NotificationType.paymentSent:
        return const Icon(
          Icons.arrow_upward,
          color: znnColor,
        );
      case NotificationType.error:
        return Icon(
          Icons.error,
          color: context.colorScheme.error,
        );
    }
  }

  Widget _getCircledIcon(
    String icon, {
    Color? iconColor,
  }) {
    iconColor ??= znnColor;
    return SvgPicture.asset(
      getSvgImagePath(icon),
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      height: 20.0,
    );
  }
}

extension AppNetworkBitcoinSupport on AppNetwork {
  BitcoinNetwork get bitcoinBaseNetwork {
    if (blockChain != BlockChain.btc) {
      throw 'App wanted to get Bitcoin info without being on the Bitcoin network';
    }
    switch (type) {
      case NetworkType.mainnet:
        return BitcoinNetwork.mainnet;
      case NetworkType.testnet:
        return BitcoinNetwork.testnet;
    }
  }

  String get explorerApiBaseUrl {
    if (blockChain != BlockChain.btc) {
      throw 'App wanted to get Bitcoin info without being on the Bitcoin network';
    }
    switch (type) {
      case NetworkType.mainnet:
        return 'https://mempool.space/api';
      case NetworkType.testnet:
        return 'https://mempool.space/signet/api';
    }
  }
}

extension Generators on BitcoinNetwork {
  BitcoinBaseAddress Function({required String addressHex})
      get bitcoinBaseAddressGenerator => isMainnet
          ? generateTaprootBitcoinBaseAddress
          : generateTestnetBitcoinBaseAddress;

  Future<ECPrivate> Function({required int index}) get privateKeyGenerator =>
      isMainnet ? generateTaprootPrivateKey : generateBtcTestnetPrivateKey;
}
