import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/services/ethereum_wc_service.dart';
import 'package:syrius_mobile/services/nom_service.dart';
import 'package:syrius_mobile/utils/wallet_connect/chain_metadata.dart';

void registerWcService(AppNetwork appNetwork) {
  final ChainMetadata chainMetadata = generateChainMetadata(appNetwork);

  final String instanceName = chainMetadata.chainId;

  switch (appNetwork.blockChain) {
    case BlockChain.nom:
      final bool isRegistered =
          sl.isRegistered<NoMService>(instanceName: instanceName);
      if (!isRegistered) {
        sl.registerSingleton<NoMService>(
          NoMService(chainMetaData: chainMetadata),
          instanceName: chainMetadata.chainId,
        );
      }
    case BlockChain.evm:
      final bool isRegistered =
          sl.isRegistered<EthereumWcService>(instanceName: instanceName);
      if (!isRegistered) {
        sl.registerSingleton<EthereumWcService>(
          EthereumWcService(chainMetaData: chainMetadata),
          instanceName: chainMetadata.chainId,
        );
      }
    default:
  }
}
