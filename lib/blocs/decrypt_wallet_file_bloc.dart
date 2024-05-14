import 'package:syrius_mobile/blocs/base_bloc.dart';
import 'package:syrius_mobile/utils/wallet/wallet_file.dart';

class DecryptWalletFileBloc extends BaseBloc<WalletFile?> {
  Future<void> decryptWalletFile(String path, String password) async {
    try {
      addEvent(null);
      final walletFile = await WalletFile.decrypt(path, password);
      addEvent(walletFile);
    } catch (e) {
      addError(e);
    }
  }
}
