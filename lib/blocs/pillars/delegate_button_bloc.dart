import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class DelegateButtonBloc extends BaseBloc<AccountBlockTemplate?> {
  Future<void> votePillar(
    String pillarName,
  ) async {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams =
          zenon.embedded.pillar.delegate(
        pillarName,
      );
      createAccountBlock(
        transactionParams,
        'delegate to Pillar',
        waitForRequiredPlasma: true,
        actionType: ActionType.delegate,
      ).then(
        (response) async {
          await Future.delayed(kDelayAfterBlockCreationCall);
          _sendSuccessDelegationNotification(pillarName: pillarName);
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

  void _sendSuccessDelegationNotification({
    required String pillarName,
  }) {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Delegated to $pillarName',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Delegated to $pillarName from '
                '${getLabel(kSelectedAddress!)}',
            type: NotificationType.delegateSuccess,
          ),
        );
  }
}
