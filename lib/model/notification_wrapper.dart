import 'package:syrius_mobile/database/export.dart';

class GroupedNotifications {
  final DateTime notificationDate;
  final List<WalletNotification> notifications;

  const GroupedNotifications({
    required this.notificationDate,
    required this.notifications,
  });
}
