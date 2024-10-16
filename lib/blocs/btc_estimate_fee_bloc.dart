import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/constants.dart';

// States
sealed class BtcEstimateFeeState {}

class BtcEstimateFeeInitial extends BtcEstimateFeeState {}

class BtcEstimateFeeLoaded extends BtcEstimateFeeState {
  final int satoshiEstimateFeePerBytes;

  BtcEstimateFeeLoaded(this.satoshiEstimateFeePerBytes);
}

class BtcEstimateFeeError extends BtcEstimateFeeState {
  final String message;

  BtcEstimateFeeError(this.message);
}

/// BLoC that periodically fetches the estimate fee of satoshi per kb
/// and converts it to satoshi per byte
class BtcEstimateFeeBloc extends BaseBloc<BtcEstimateFeeState> {
  Timer? _timer;

  Future<void> _fetchBtcEstimateFee() async {
    try {
      final BitcoinFeeRate bitcoinFeeRate = await btc.feeRate();
      final BigInt satoshiPerKb = bitcoinFeeRate.medium;
      final BigInt fee = satoshiPerKb ~/ BigInt.from(1024);
      addEvent(BtcEstimateFeeLoaded(fee.toInt()));
    } catch (e) {
      addEvent(BtcEstimateFeeError(e.toString()));
    }
  }

  Future<void> start() async {
    await _fetchBtcEstimateFee();
    _timer = Timer.periodic(kFeeRefreshInterval, (timer) {
      _fetchBtcEstimateFee();
    });
  }

  void stop() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
