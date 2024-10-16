import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:syrius_mobile/blocs/base_bloc.dart';
import 'package:syrius_mobile/main.dart';

sealed class BtcActivityState {}

class BtcActivityInitial extends BtcActivityState {}

class BtcActivityLoading extends BtcActivityState {}

class BtcActivityLoaded extends BtcActivityState {
  final List<MempoolTransaction> txs;

  BtcActivityLoaded(this.txs);
}

class BtcActivityError extends BtcActivityState {
  final String message;

  BtcActivityError(this.message);
}

class BtcActivityBloc extends BaseBloc<BtcActivityState> {
  Future<void> fetch({required String addressHex}) async {
    try {
      final List<MempoolTransaction> txs = await btc.fetchAccountTxs(
        addressHex: addressHex,
      );
      if (txs.isEmpty) {
        throw 'Nothing to show';
      }
      addEvent(BtcActivityLoaded(txs));
    } catch (e) {
      addEvent(BtcActivityError(e.toString()));
    }
  }
}
