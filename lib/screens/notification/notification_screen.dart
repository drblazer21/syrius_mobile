import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationsProvider getNotificationProvider;

  @override
  void initState() {
    super.initState();
    getNotificationProvider = context.read<NotificationsProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        getNotificationProvider.getNotificationsFromDb();
        Navigator.pop(context);
      },
      child: NotificationsPageChild(
        notificationsProvider: getNotificationProvider,
      ),
    );
  }

  @override
  void dispose() {
    getNotificationProvider.dispose();
    super.dispose();
  }
}
