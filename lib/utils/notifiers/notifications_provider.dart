import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';

class NotificationsProvider extends ChangeNotifier {
  List<WalletNotification> walletNotifications = [];

  late BehaviorSubject<List<WalletNotification?>> _notificationResponse;

  Stream<List<WalletNotification?>> get getNotifications =>
      _notificationResponse.stream;

  NotificationsProvider() {
    _notificationResponse = BehaviorSubject<List<WalletNotification?>>();
  }

  List<WalletNotification> getNotificationsFromDb() {
    try {
      final Box<WalletNotification> notificationsBox =
          Hive.box(kNotificationsBox);
      final List<dynamic> keys = notificationsBox.keys.toList();
      if (keys.length >= kNotificationsResultLimit) {
        return List<WalletNotification>.from(
          notificationsBox.valuesBetween(
            startKey: keys[keys.length - kNotificationsResultLimit],
            endKey: keys[keys.length - 1],
          ),
        );
      }
      final List<WalletNotification> notifications = notificationsBox.keys
          .map<WalletNotification>(
            (e) => notificationsBox.get(e)!,
          )
          .toList();
      _notificationResponse.sink.add(notifications);
      return notifications;
    } catch (e, stackTrace) {
      Logger('NotificationsProvider').log(
        Level.SEVERE,
        'getNotificationsFromDb',
        e,
        stackTrace,
      );
      return [];
    }
  }

  Future<void> markNotificationsAsRead() async {
    final Box<WalletNotification> notificationsBox =
        Hive.box<WalletNotification>(
      kNotificationsBox,
    );

    for (final WalletNotification item in notificationsBox.values) {
      item.isRead = true;
      await item.save();
    }
  }

  Future<void> deleteNotificationsFromDb() async {
    final Box notificationsBox =
        Hive.box<WalletNotification>(kNotificationsBox);
    await notificationsBox.clear();
    _notificationResponse.sink.add([]);
  }

  Future<void> deleteNotification(int? notificationTimestamp) async {
    final Box notificationsBox =
        Hive.box<WalletNotification>(kNotificationsBox);
    final notificationKey = notificationsBox.keys.firstWhere(
      (key) {
        final WalletNotification notification =
            notificationsBox.get(key) as WalletNotification;
        return notification.timestamp == notificationTimestamp;
      },
    );
    await notificationsBox.delete(notificationKey);
  }
}
