import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectSessionsBloc extends InfiniteScrollBloc<SessionData> {
  WalletConnectSessionsBloc() : super();

  @override
  Future<List<SessionData>> getData(int pageKey, int pageSize) async {
    final wcService = sl.get<IWeb3WalletService>();
    final sessions = <SessionData>[];
    for (final pairing in wcService.pairings.value) {
      sessions.addAll(
        wcService.getSessionsForPairing(pairing.topic).values,
      );
    }
    Logger('WalletConnectSessionsBloc').log(
      Level.INFO,
      'sessions',
      sessions.toList().toString(),
    );
    return Future.delayed(const Duration(milliseconds: 500)).then(
      (value) => sessions,
    );
  }
}
