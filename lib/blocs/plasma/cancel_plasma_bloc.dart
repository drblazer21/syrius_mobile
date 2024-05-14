import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class CancelPlasmaBloc extends BaseBloc<AccountBlockTemplate?> {
  void cancel(String id) {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams =
          zenon.embedded.plasma.cancel(
        Hash.parse(id),
      );
      createAccountBlock(
        transactionParams,
        'cancel Plasma',
        waitForRequiredPlasma: true,
        actionType: ActionType.plasma,
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
