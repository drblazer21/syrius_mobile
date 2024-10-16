import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class UpdatePhaseBloc extends BaseBloc<AccountBlockTemplate?> {
  void updatePhase(
    Hash id,
    String name,
    String description,
    String url,
    BigInt znnFundsNeeded,
    BigInt qsrFundsNeeded,
  ) {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams =
          zenon.embedded.accelerator.updatePhase(
        id,
        name,
        description,
        url,
        znnFundsNeeded,
        qsrFundsNeeded,
      );
      createAccountBlock(transactionParams, 'update phase')
          .then(
        (block) {
          addEvent(block);
          sl.get<NotificationsService>().addNotification(
            WalletNotificationsCompanion.insert(
              title: 'Updated phase $name',
              details: '$name - $description - $url',
              type: NotificationType.paymentSent,
            ),
          );
          dispose();
        },
      )
          .onError(
        (error, _) {
          addError(error ?? 'No error available');
          sendNotificationError(
            'Error while updating phase',
            error,
          );
        },
      );
    } catch (e, _) {
      addError(e);
      sendNotificationError(
        'Error while updating phase',
        e,
      );
    }
  }
}
