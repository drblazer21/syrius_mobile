import 'dart:async';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

// States
sealed class GasPriceState {}

class GasPriceInitial extends GasPriceState {}

class GasPriceLoaded extends GasPriceState {
  final EtherAmount gasPrice;

  GasPriceLoaded(this.gasPrice);
}

class GasPriceError extends GasPriceState {
  final String message;

  GasPriceError(this.message);
}

// BLoC that periodically fetches the fee per unit of gas
class GasPriceBloc extends BaseBloc<GasPriceState> {
  Timer? _timer;

  Future<void> _fetchGasPrice() async {
    try {
      final gasPrice = await eth.getGasPrice();
      addEvent(GasPriceLoaded(gasPrice));
    } catch (e) {
      addEvent(GasPriceError(e.toString()));
    }
  }

  Future<void> start() async {
    await _fetchGasPrice();
    _timer = Timer.periodic(kFeeRefreshInterval, (timer) {
      _fetchGasPrice();
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
