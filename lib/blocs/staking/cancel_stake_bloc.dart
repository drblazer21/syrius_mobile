import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class CancelStakeBloc extends BaseBloc<AccountBlockTemplate?> {
  void cancel(String hash) {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams =
          zenon.embedded.stake.cancel(
        Hash.parse(hash),
      );
      createAccountBlock(
        transactionParams,
        'cancel stake',
        waitForRequiredPlasma: true,
        actionType: ActionType.stake,
      ).then(
        (response) {
          refreshBalanceAndTx();
          addEvent(response);
        },
      ).onError(
        (error, stackTrace) {
          addError(error.toString());
        },
      );
    } catch (e) {
      addError(e);
    }
  }
}
