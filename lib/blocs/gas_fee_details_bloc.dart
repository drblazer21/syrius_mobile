import 'package:eip1559/eip1559.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:web3dart/web3dart.dart';

sealed class GasFeeDetailsState {}

class GasFeeDetailsInitialState extends GasFeeDetailsState {}

class GasFeeDetailsLoading extends GasFeeDetailsState {}

class GasFeeDetailsLoaded extends GasFeeDetailsState {
  final EthereumTxGasDetailsData ethereumTxGasDetailsData;

  GasFeeDetailsLoaded(this.ethereumTxGasDetailsData);
}

class GasFeeDetailsError extends GasFeeDetailsState {
  final String message;

  GasFeeDetailsError(this.message);
}

class GasFeeDetailsBloc extends BaseBloc<GasFeeDetailsState> {
  Future<void> fetch({
    required Transaction tx,
    bool fetchAsset = false,
  }) async {
    try {
      addEvent(GasFeeDetailsLoading());
      final EthereumTxGasDetailsData ethereumTxGasDetailsData =
          await eth.getGasDetails(
        tx: tx,
      );
      if (fetchAsset && tx.to != null) {
        final NetworkAssetsCompanion asset = await eth.getNetworkAsset(
          contractAddressHex: tx.to!.hex,
        );
        ethereumTxGasDetailsData.asset = asset;
      }
      addEvent(GasFeeDetailsLoaded(ethereumTxGasDetailsData));
    } catch (e) {
      addEvent(GasFeeDetailsError(e.toString()));
    }
  }

  void update(EthereumTxGasDetailsData newData) => addEvent(
        GasFeeDetailsLoaded(newData),
      );

  Future<void> updateUserFee({
    required EthereumTxGasDetailsData data,
    required BigInt maxFeePerGas,
    required BigInt maxPriorityFeePerGas,
  }) async {
    try {
      addEvent(GasFeeDetailsLoading());
      final EtherAmount etherAmount = await eth.getBaseFee();

      final BigInt baseFee = etherAmount.getInWei;

      final BigInt estimatedFeePerGas = baseFee + maxPriorityFeePerGas;

      final Fee userFee = Fee(
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        maxFeePerGas: maxFeePerGas,
        estimatedGas: estimatedFeePerGas,
      );

      final EthereumTxGasDetailsData newData = data
        ..userFee = userFee
        ..speed = null;
      addEvent(GasFeeDetailsLoaded(newData));
    } catch (e) {
      addEvent(GasFeeDetailsError(e.toString()));
    }
  }
}
