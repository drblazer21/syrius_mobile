import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class ExtendedBlockInformation extends BlockInformation {
  final BigInt gasLimit;

  ExtendedBlockInformation({
    required super.baseFeePerGas,
    required this.gasLimit,
    required super.timestamp,
  });

  factory ExtendedBlockInformation.fromJson(Map<String, dynamic> json) {
    final BlockInformation blockInformation = BlockInformation.fromJson(json);
    final BigInt gasLimit = hexToInt(json['gasLimit'] as String);

    return ExtendedBlockInformation(
      baseFeePerGas: blockInformation.baseFeePerGas,
      gasLimit: gasLimit,
      timestamp: blockInformation.timestamp,
    );
  }
}
