import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/global.dart';
import 'package:web3dart/web3dart.dart';

class EthAccountBalanceBloc extends BaseBloc<EthAccountBalance> {
  Future<void> fetch({required EthereumAddress address}) async {
    try {
      final List<NetworkAsset> assets = kSelectedAppNetworkWithAssets!.assets;

      final List<EthAccountBalanceItem> tokenBalanceItems = await Future.wait(
        assets.map(
          (token) =>
              _generateAccountBalanceItem(address: address, asset: token),
        ),
      );

      final EthAccountBalance accountBalance = EthAccountBalance(
        items: tokenBalanceItems,
      );

      addEvent(accountBalance);
    } catch (e) {
      addError(e);
    }
  }

  Future<EthAccountBalanceItem> _generateAccountBalanceItem({
    required EthereumAddress address,
    required NetworkAsset asset,
  }) async {
    BigInt? balance;
    if (asset.isCurrency) {
      final EtherAmount etherAmount = await eth.getBalance(address: address);

      balance = etherAmount.getInWei;
    } else {
      balance = await eth.getTokenBalance(
        addressHex: address.hex,
        contractAddressHex: asset.contractAddressHex!,
      );
    }

    return EthAccountBalanceItem(
      ethAsset: asset,
      balance: balance,
    );
  }
}
