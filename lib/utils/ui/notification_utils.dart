import 'package:collection/collection.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

void sendNotificationError(
  String title,
  dynamic error,
) {
  sl.get<NotificationsService>().addErrorNotification(
        title,
        error as Object,
      );
}

void sendNodeSyncingNotification() {
  zenon.stats.syncInfo().then(
    (SyncInfo syncInfo) {
      if (syncInfo.targetHeight == 0 ||
          syncInfo.currentHeight == 0 ||
          (syncInfo.targetHeight - syncInfo.currentHeight) > 20) {
        sl.get<NotificationsService>().addNotification(
              WalletNotificationsCompanion.insert(
                type: NotificationType.nodeSyncing,
                title:
                    'The node is still syncing with the network. Please wait '
                    'until the loading circle turns green before sending '
                    'any transactions',
                details:
                    'The information displayed in the wallet does not reflect '
                    'the most recent network state. Operations should not '
                    'be performed, as they will likely become invalid by '
                    'the time the node is fully synced',
              ),
            );
      }
    },
  );
}

List<GroupedNotifications> getSortedWalletNotificationItems(
  List<WalletNotification> items,
) {
  ///transaction date: 2022-04-18 12:50:01.000
  ///grouping transactions by transaction date only (not including time)
  final Map<DateTime, List<WalletNotification>> groupedItems = groupBy(
    items,

    ///taking only 2022-04-18 part from 2022-04-18 12:50:01.000
    (WalletNotification item) {
      final DateTime dateTime = item.createdAt;
      return DateTime(dateTime.year, dateTime.month, dateTime.day);
    },
  );
  final List<GroupedNotifications> wrappers = [];

  ///sorting the grouped transactions on the basis of transaction date
  final List<MapEntry<DateTime, List<WalletNotification>>> mapToList =
      groupedItems.entries.toList();
  mapToList.sort((a, b) => b.key.compareTo(a.key));
  for (final item in mapToList) {
    wrappers.add(
      GroupedNotifications(
        notificationDate: item.key,
        notifications: item.value,
      ),
    );
  }
  return wrappers;
}
