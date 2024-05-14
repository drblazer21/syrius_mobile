import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class UndelegateButtonBloc extends BaseBloc<AccountBlockTemplate?> {
  void undelegate({required String pillarName}) {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams =
          zenon.embedded.pillar.undelegate();
      createAccountBlock(
        transactionParams,
        'undelegate',
        waitForRequiredPlasma: true,
        actionType: ActionType.delegate,
      ).then(
        (response) async {
          await Future.delayed(kDelayAfterBlockCreationCall);
          _sendSuccessUndelegationNotification(pillarName: pillarName);
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

  void _sendSuccessUndelegationNotification({
    required String pillarName,
  }) {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Undelegated from $pillarName',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Undelegated from $pillarName with '
                '${getLabel(kSelectedAddress!)}',
            type: NotificationType.delegateSuccess,
          ),
        );
  }
}
