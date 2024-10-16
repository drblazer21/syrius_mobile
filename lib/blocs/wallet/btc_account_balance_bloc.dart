import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/btc/btc.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/global.dart';

class BtcAccountBalanceBloc extends BaseBloc<BtcAccountBalance> {
  Future<void> fetch({required String addressHex}) async {
    try {
      final NetworkType networkType = kSelectedAppNetworkWithAssets!.network.type;

      final BitcoinBaseAddress bitcoinBaseAddress;

      switch (networkType) {
        case NetworkType.mainnet:
          bitcoinBaseAddress = generateTaprootBitcoinBaseAddress(addressHex: addressHex);
        case NetworkType.testnet:
          bitcoinBaseAddress = generateTestnetBitcoinBaseAddress(addressHex: addressHex);
      }

      final Map<String, dynamic> response = await btc.fetchAccountBalance(
        bitcoinBaseAddress: bitcoinBaseAddress,
      );

      final BtcAccountBalance accountBalance =
          BtcAccountBalance.fromJson(response);

      addEvent(accountBalance);
    } catch (e) {
      addError(e);
    }
  }
}
