import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectPairingsBloc extends InfiniteScrollBloc<PairingInfo> {
  WalletConnectPairingsBloc() : super();

  @override
  Future<List<PairingInfo>> getData(int pageKey, int pageSize) =>
      Future.delayed(const Duration(milliseconds: 500)).then(
        (value) => sl.get<IWeb3WalletService>().pairings.value,
      );
}
