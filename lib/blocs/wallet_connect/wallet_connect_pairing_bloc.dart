import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectPairingBloc extends BaseBloc<PairingInfo?> {
  Future<void> pair(String uri) async {
    try {
      addEvent(null);
      final walletConnectUri = Uri.parse(uri);
      final PairingInfo pairingInfo = await _pair(walletConnectUri);
      Logger('WalletConnectPairBloc').log(
        Level.INFO,
        'pairing info',
        pairingInfo.toJson(),
      );
      addEvent(pairingInfo);
    } on Exception catch (e) {
      addError(e);
    }
  }

  Future<PairingInfo> _pair(Uri uri) {
    return sl<IWeb3WalletService>().pair(uri);
  }
}
