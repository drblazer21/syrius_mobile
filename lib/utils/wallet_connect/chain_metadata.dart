import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/model/model.dart';

enum ChainType {
  eip155,
  zenon,
}

class ChainMetadata {
  final String chainId;
  final int chainIdInt;
  final String name;
  final String logo;
  final bool isTestnet;
  final Color color;
  final ChainType type;
  final List<String> rpc;

  const ChainMetadata({
    required this.chainId,
    required this.chainIdInt,
    required this.name,
    required this.logo,
    this.isTestnet = false,
    required this.color,
    required this.type,
    required this.rpc,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChainMetadata &&
        other.chainId == chainId &&
        other.name == name &&
        other.logo == logo &&
        other.isTestnet == isTestnet &&
        listEquals(other.rpc, rpc);
  }

  @override
  int get hashCode {
    return chainId.hashCode ^
        name.hashCode ^
        logo.hashCode ^
        rpc.hashCode ^
        isTestnet.hashCode;
  }
}

ChainMetadata generateChainMetadata(AppNetwork appNetwork) {
  final ChainType chainType;

  switch (appNetwork.blockChain) {
    case BlockChain.evm:
      chainType = ChainType.eip155;
    case BlockChain.nom:
      chainType = ChainType.zenon;
    default:
      throw 'Only Ethereum and NoM networks are supported by WalletConnect';
  }

  return ChainMetadata(
    chainId: '${chainType.name}:${appNetwork.chainId}',
    chainIdInt: appNetwork.chainId!,
    name: appNetwork.name,
    logo: 'TODO',
    color: appNetwork.blockChain.bgColor,
    type: chainType,
    rpc: [appNetwork.url],
  );
}
