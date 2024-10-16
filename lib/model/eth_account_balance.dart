import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/utils/utils.dart';

class EthAccountBalance {
  final List<EthAccountBalanceItem> items;

  EthAccountBalance({required this.items});

  // Returns ETH balance in wei - which will be used in most calculations
  BigInt get wei =>
      items.firstWhere((item) => item.ethAsset.isCurrency).balance;

  // The ETH balance that we present to the user, with decimals
  String get eth => wei.toStringWithDecimals(
        kEthereumMainnetCurrency.decimals.value,
      );

  EthAccountBalanceItem findItem({required NetworkAsset ethAsset}) =>
      items.firstWhere(
        (item) =>
            item.ethAsset.contractAddressHex == ethAsset.contractAddressHex &&
            item.ethAsset.isCurrency == ethAsset.isCurrency,
      );

  BigInt getBalance({required NetworkAsset ethAsset}) =>
      findItem(ethAsset: ethAsset).balance;

  EthAccountBalanceItem getCurrency() => items.firstWhere(
        (item) => item.ethAsset.isCurrency,
      );
}

class EthAccountBalanceItem {
  final NetworkAsset ethAsset;
  final BigInt balance;

  String get displayBalance => balance.toStringWithDecimals(ethAsset.decimals);

  EthAccountBalanceItem({required this.ethAsset, required this.balance});
}
