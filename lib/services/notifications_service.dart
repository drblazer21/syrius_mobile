import 'dart:async';

import 'package:logging/logging.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';

class NotificationsService {
  Stream<List<WalletNotification>> get notifications =>
      db.walletNotificationsDao.listen();

  Future<void> markNotificationsAsRead() async {
    await db.walletNotificationsDao.markAllAsRead();
  }

  Future<void> deleteNotificationsFromDb() async {
    await db.walletNotificationsDao.deleteAll();
  }

  Future<void> deleteNotification(int id) async {
    await db.walletNotificationsDao.deleteById(id);
  }

  Future<void> addNotification(WalletNotificationsCompanion notification) async {
    if (await _getNotificationsNumber() >= kNotificationsResultLimit) {
      while (await _getNotificationsNumber() >= kNotificationsResultLimit) {
        await _deleteLastNotification();
      }
    }

    Logger('NotificationsBloc').log(
      Level.INFO,
      'addNotification',
      notification.title,
    );

    await _insertNotification(notification: notification);
    if (!navState.currentState!.mounted) return;
    showNotificationSnackBar(
      navState.currentState!.context,
      walletNotification: notification,
    );
  }

  void sendPlasmaNotification(String purposeOfGeneratingPlasma) {
    addNotification(
      WalletNotificationsCompanion.insert(
        type: NotificationType.needPlasma,
        title: 'Plasma will be generated in order to '
            '$purposeOfGeneratingPlasma',
        details: 'Plasma will be generated for this account-block',
      ),
    );
  }

  void addErrorNotification(String title, Object error) {
    addNotification(
      WalletNotificationsCompanion.insert(
        title: title,
        details: '$error.',
        type: NotificationType.error,
      ),
    );
  }

  Future<int> _getNotificationsNumber() async {
    return await db.managers.walletNotifications.count();
  }

  Future<void> _deleteLastNotification() async {
    await db.walletNotificationsDao.deleteOldest();
  }

  Future<void> _insertNotification({
    required WalletNotificationsCompanion notification,
  }) async {
    await db.walletNotificationsDao.insert(notification);
  }
}
