import 'package:syrius_mobile/model/model.dart';

class GroupedNotifications {
  final DateTime notificationDate;
  final List<WalletNotification> notifications;

  const GroupedNotifications({
    required this.notificationDate,
    required this.notifications,
  });
}
