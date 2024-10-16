import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:syrius_mobile/btc/btc.dart';
import 'package:syrius_mobile/btc/electrum/electrum_ssl_service.dart';
import 'package:syrius_mobile/btc/explorer_service/explorer_service.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/model/electrum_btc_node_stats.dart';
import 'package:syrius_mobile/utils/ui/notification_utils.dart';

class BitcoinService {
  ElectrumApiProvider? _electrumApi;
  ApiProvider? _explorerApi;

  Future<void> init({required AppNetwork appNetwork}) async {
    try {
      final String url = appNetwork.url;

      final Uri uri = Uri.parse(url);

      final service = await ElectrumSSLService.connect(uri);

      _electrumApi = ElectrumApiProvider(service);

      final String explorerApiBaseUrl = appNetwork.explorerApiBaseUrl;

      final APIConfig explorerApiConfig = APIConfig(
        url: "$explorerApiBaseUrl/address/###/utxo",
        feeRate: "$explorerApiBaseUrl/v1/fees/recommended",
        transaction: "$explorerApiBaseUrl/tx/###",
        sendTransaction: "$explorerApiBaseUrl/tx",
        apiType: APIType.mempool,
        transactions: "$explorerApiBaseUrl/address/###/txs",
        network: appNetwork.bitcoinBaseNetwork,
        blockHeight: "$explorerApiBaseUrl/block-height/###",
      );

      /// Define http provider and api provider
      final bitcoinApiService = BitcoinApiService();

      _explorerApi =
          ApiProvider(api: explorerApiConfig, service: bitcoinApiService);
    } on Exception catch (e) {
      sendNotificationError(
        'Something went wrong while connecting to the Bitcoin network',
        e,
      );
    }
  }

  Future<Map<String, dynamic>> fetchAccountBalance({
    required BitcoinBaseAddress bitcoinBaseAddress,
  }) async {
    /// Return the confirmed and unconfirmed balances of a script hash.
    final accountBalance = await _electrumApi!.request(
      ElectrumGetScriptHashBalance(
        scriptHash: bitcoinBaseAddress.pubKeyHash(),
      ),
    );

    return accountBalance;
  }

  Future<List<ElectrumUtxo>> fetchUtxos({required String addressHex}) async {
    final BitcoinBaseAddress bitcoinBaseAddress =
        generateTestnetBitcoinBaseAddress(
      addressHex: addressHex,
    );

    final List<ElectrumUtxo> electrumUtxos = await _electrumApi!.request(
      ElectrumScriptHashListUnspent(
        scriptHash: bitcoinBaseAddress.pubKeyHash(),
      ),
    );

    return electrumUtxos;
  }

  /// Retrieves the list of transactions associated with an address from
  /// block cypher
  Future<List<MempoolTransaction>> fetchAccountTxs({
    required String addressHex,
  }) =>
      _explorerApi!.getAccountTransactions<MempoolTransaction>(addressHex);

  Future<BitcoinFeeRate> feeRate() => _explorerApi!.getNetworkFeeRate();

  Future<String> sendRawTx({required String rawTx}) => _electrumApi!.request(
        ElectrumBroadCastTransaction(transactionRaw: rawTx),
      );

  Future<void> switchNetwork({required AppNetwork appNetwork}) async {
    await disconnect();
    await init(appNetwork: appNetwork);
  }

  Future<void> disconnect() async {
    if (_electrumApi != null) {
      await (_electrumApi!.rpc as ElectrumSSLService).disconnect();
    }
    if (_explorerApi != null) {
      (_explorerApi!.service as BitcoinApiService).close();
    }
  }

  Future<ElectrumBtcNodeStats> getNodeStats() async {
    final dynamic electrumServerFeatures = await _electrumApi!.request(
      ElectrumServerFeatures(),
    );

    return ElectrumBtcNodeStats.fromJson(
      electrumServerFeatures as Map<String, dynamic>,
    );
  }
}
