import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class CreateProjectBloc extends BaseBloc<AccountBlockTemplate?> {
  void createProject(
    String name,
    String description,
    String url,
    BigInt znnFundsNeeded,
    BigInt qsrFundsNeeded,
  ) {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams =
          zenon.embedded.accelerator.createProject(
        name,
        description,
        url,
        znnFundsNeeded,
        qsrFundsNeeded,
      );
      createAccountBlock(
        transactionParams,
        'creating project',
      ).then(
        (block) {
          refreshBalanceAndTx();
          addEvent(block);
          sl.get<NotificationsService>().addNotification(
                WalletNotificationsCompanion.insert(
                  title: 'Created $name accelerator project',
                  details: '$name - $description - $url',
                  type: NotificationType.paymentSent,
                ),
              );
          dispose();
        },
      ).onError(
        (error, _) {
          addError(
            error ?? 'No error available',
          );
          sendNotificationError(
            'Error while submitting project',
            error,
          );
        },
      );
    } catch (e, _) {
      addError(e);
    }
  }
}
