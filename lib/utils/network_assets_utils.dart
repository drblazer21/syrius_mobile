import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

NetworkAssetsCompanion generateBitcoinNetworkCurrency(String symbol) =>
    NetworkAssetsCompanion(
      decimals: const Value(kBtcDecimals),
      isCurrency: const Value(true),
      name: const Value('Bitcoin'),
      symbol: Value(symbol),
    );

NetworkAssetsCompanion generateEthereumNetworkCurrency(String symbol) =>
    NetworkAssetsCompanion(
      decimals: const Value(kEvmCurrencyDecimals),
      isCurrency: const Value(true),
      symbol: Value(symbol),
    );

final NetworkAssetsCompanion kEthereumMainnetCurrency =
    generateEthereumNetworkCurrency('ETH');

final NetworkAssetsCompanion kSepoliaCurrency =
    generateEthereumNetworkCurrency('sETH');

final NetworkAssetsCompanion kSupernovaZvmCurrency =
    generateEthereumNetworkCurrency('xZNN');

final List<NetworkAssetsCompanion> kDefaultEthereumMainnetAssets = [
  kEthereumMainnetCurrency,
  NetworkAssetsCompanion(
    contractAddressHex:
        const Value('0xb2e96a63479C2Edd2FD62b382c89D5CA79f572d3'),
    decimals: Value(kZnnCoin.decimals),
    isCurrency: const Value(false),
    name: const Value('Wrapped ZNN'),
    symbol: const Value('wZNN'),
  ),
  NetworkAssetsCompanion(
    contractAddressHex:
        const Value('0xe6c61425d0383c1cde02a49365945f48ebf0ea0c'),
    decimals: Value(kQsrCoin.decimals),
    isCurrency: const Value(false),
    name: const Value('Wrapped QSR'),
    symbol: const Value('wQSR'),
  ),
];

final NetworkAssetsCompanion kBitcoinSignetCurrency =
    generateBitcoinNetworkCurrency(
  'sBTC',
);
final NetworkAssetsCompanion kBitcoinMainnetCurrency =
    generateBitcoinNetworkCurrency(
  'BTC',
);
final List<Token> kDualCoin = [
  kZnnCoin,
  kQsrCoin,
];

final Token kZnnCoin = Token(
  'Zenon',
  'ZNN',
  'zenon.network',
  BigInt.zero,
  coinDecimals,
  pillarAddress,
  TokenStandard.parse(znnTokenStandard),
  BigInt.zero,
  true,
  true,
  true,
);
final Token kQsrCoin = Token(
  'Quasar',
  'QSR',
  'zenon.network',
  BigInt.zero,
  coinDecimals,
  stakeAddress,
  TokenStandard.parse(qsrTokenStandard),
  BigInt.zero,
  true,
  true,
  true,
);

final Map<TokenStandard, Color> kCoinIdColor = {
  kZnnCoin.tokenStandard: znnColor,
  kQsrCoin.tokenStandard: qsrColor,
};
