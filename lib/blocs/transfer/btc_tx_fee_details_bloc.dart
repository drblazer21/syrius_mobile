import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:syrius_mobile/blocs/base_bloc.dart';
import 'package:syrius_mobile/main.dart';

sealed class BtcTxFeeDetailsState {}

class BtcTxFeeDetailsInitial extends BtcTxFeeDetailsState {}

class BtcTxFeeDetailsLoading extends BtcTxFeeDetailsState {}

class BtcTxFeeDetailsLoaded extends BtcTxFeeDetailsState {
  final BitcoinFeeRate data;

  BtcTxFeeDetailsLoaded(this.data);
}

class BtcTxFeeDetailsError extends BtcTxFeeDetailsState {
  final String message;

  BtcTxFeeDetailsError(this.message);
}

class BtcTxFeeDetailsBloc extends BaseBloc<BtcTxFeeDetailsState> {
  Future<void> fetchFees() async {
    try {
      addEvent(BtcTxFeeDetailsLoading());

      final BitcoinFeeRate data = await btc.feeRate();

      addEvent(BtcTxFeeDetailsLoaded(data));
    } catch (e) {
      addEvent(BtcTxFeeDetailsError(e.toString()));
    }
  }
}
