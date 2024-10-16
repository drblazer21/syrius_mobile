import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class CreatePhaseBloc extends BaseBloc<AccountBlockTemplate?> {
  Future<void> create(
    Hash id,
    String name,
    String description,
    String url,
    BigInt znnFundsNeeded,
    BigInt qsrFundsNeeded,
  ) async {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams =
          zenon.embedded.accelerator.addPhase(
        id,
        name,
        description,
        url,
        znnFundsNeeded,
        qsrFundsNeeded,
      );
      createAccountBlock(transactionParams, 'create phase').then(
        (block) {
          addEvent(block);
          sl.get<NotificationsService>().addNotification(
                WalletNotificationsCompanion.insert(
                  title: 'Created $name phase',
                  details: '$name - $description - $url',
                  type: NotificationType.paymentSent,
                ),
              );
        },
      ).onError(
        (error, _) {
          addError(error ?? 'No error available');
          sendNotificationError(
            'Error while submitting phase',
            error,
          );
        },
      );
    } catch (e) {
      addError(e);
    }
  }
}
