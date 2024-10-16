import 'package:eip1559/eip1559.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/model/ethereum_tx_speed.dart';
import 'package:web3dart/web3dart.dart';

class EthereumTxGasDetailsData {
  BigInt gasLimit; // Units of gas editable by the user
  final List<Fee> fees; // The original fees for slow, medium and fast tx speed
  final Transaction tx;
  Fee? userFee;
  EthereumTxSpeed? speed;
  NetworkAssetsCompanion? asset;

  EthereumTxGasDetailsData({
    required this.gasLimit,
    required this.fees,
    required this.tx,
    this.userFee,
    this.speed = EthereumTxSpeed.medium,
  }) {
    if (speed != null) {
      userFee = fees[speed!.index];
    }
  }

  EtherAmount get estimatedGas {
    // The estimated fee is calculated as the base fee plus the max priority fee
    // which in some cases would make the estimated fee higher than the max fee
    // and so we will use the max fee as a replacement for the estimated cost
    final BigInt realWorldEstimate =
        userFee!.maxFeePerGas < userFee!.estimatedGas
            ? userFee!.maxFeePerGas
            : userFee!.estimatedGas;
    return EtherAmount.fromBigInt(
      EtherUnit.wei,
      gasLimit * realWorldEstimate,
    );
  }

  EtherAmount get maxFee => EtherAmount.fromBigInt(
        EtherUnit.wei,
        gasLimit * userFee!.maxFeePerGas,
      );

  Transaction get txWithGasFee => tx.copyWith(
        maxGas: gasLimit.toInt(),
        maxFeePerGas: EtherAmount.fromBigInt(
          EtherUnit.wei,
          userFee!.maxFeePerGas,
        ),
        maxPriorityFeePerGas: EtherAmount.fromBigInt(
          EtherUnit.wei,
          userFee!.maxPriorityFeePerGas,
        ),
      );
}
