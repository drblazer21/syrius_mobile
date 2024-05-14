import 'dart:async';

import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';

class NotificationsBloc extends BaseBloc<WalletNotification?> {
  Future<void> addNotification(WalletNotification notification) async {
    try {
      final Box<WalletNotification> notificationsBox =
          await Hive.openBox<WalletNotification>(kNotificationsBox);
      if (notificationsBox.length >= kNotificationsResultLimit) {
        while (notificationsBox.length >= kNotificationsResultLimit) {
          await notificationsBox.delete(notificationsBox.keys.first);
        }
      }

      Logger('NotificationsBloc').log(
        Level.INFO,
        'addNotification',
        notification.title,
      );

      await notificationsBox.add(notification);
      addEvent(notification);
    } catch (e) {
      addError(e);
    }
  }

  void sendPlasmaNotification(String purposeOfGeneratingPlasma) {
    addNotification(
      WalletNotification(
        title: 'Plasma will be generated in order to '
            '$purposeOfGeneratingPlasma',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        details: 'Plasma will be generated for this account-block',
      ),
    );
  }

  void addErrorNotification(String title, Object error) {
    addNotification(
      WalletNotification(
        title: title,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        details: '$error.',
        type: NotificationType.error,
      ),
    );
  }
}
