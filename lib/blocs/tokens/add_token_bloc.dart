import 'package:rxdart/rxdart.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';

sealed class UiState {}

class InitialUiState extends UiState {}

class LoadingUiState extends UiState {}

class SuccessUiState<T> extends UiState {
  final T data;

  SuccessUiState(this.data);
}

class ErrorUiState extends UiState {
  final dynamic error;

  ErrorUiState(this.error);
}

class AddTokenBloc extends BaseBloc<UiState> {
  final _contractAddress = BehaviorSubject<String>();

  void searchToken(String contractAddressHex) =>
      _contractAddress.add(contractAddressHex);

  late Stream<NetworkAsset> _networkAsset;

  Stream<NetworkAsset> get networkAsset => _networkAsset;

  AddTokenBloc() {
    _contractAddress
        .debounce(
          (_) => TimerStream<bool>(
            true,
            const Duration(milliseconds: 500),
          ),
        )
        .listen(
          fetchNetworkAsset,
        );
  }

  Future<void> fetchNetworkAsset(String contractAddressHex) async {
    try {
      addEvent(LoadingUiState());
      final NetworkAssetsCompanion networkAsset = await eth.getNetworkAsset(
        contractAddressHex: contractAddressHex,
      );
      addEvent(SuccessUiState<NetworkAssetsCompanion>(networkAsset));
    } catch (e) {
      addEvent(ErrorUiState(e));
    }
  }
}
