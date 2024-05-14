import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';

class CustomAppbarScreen extends StatelessWidget {
  final String? appbarTitle;
  final Widget child;
  final Widget? actionWidget;
  final Widget? floatingActionButton;
  final Widget? leadingWidget;
  final double? leadingWidth;
  final bool withBottomPadding;
  final bool withLateralPadding;

  const CustomAppbarScreen({
    required this.child,
    super.key,
    this.actionWidget,
    this.appbarTitle,
    this.floatingActionButton,
    this.leadingWidget,
    this.leadingWidth,
    this.withBottomPadding = true,
    this.withLateralPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final Text? title = appbarTitle != null
        ? Text(
            appbarTitle!,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55.0,
        leading: leadingWidget,
        leadingWidth: leadingWidth,
        title: title,
        actions: actionWidget != null ? [actionWidget!] : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: withLateralPadding ? kHorizontalPagePaddingDimension : 0.0,
            right: withLateralPadding ? kHorizontalPagePaddingDimension : 0.0,
          ),
          child: child,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

Widget notificationsIcon(
  BuildContext context,
) {
  const Icon unreadNotificationsIcon = Icon(
    Icons.notifications,
  );

  final Icon readNotificationsIcon = Icon(
    Icons.notifications_outlined,
    color: context.colorScheme.onBackground,
  );
  return StreamBuilder<List<WalletNotification?>>(
    stream: context.read<NotificationsProvider>().getNotifications,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Container();
      }

      final List<WalletNotification?> walletNotifications = snapshot.data!;
      final int unreadCount =
          walletNotifications.where((e) => !e!.isRead).toList().length;

      final Icon icon =
          unreadCount > 0 ? unreadNotificationsIcon : readNotificationsIcon;
      return IconButton(
        onPressed: () {
          showNotificationScreen(
            context,
            getNotificationProvider: context.read<NotificationsProvider>(),
          );
        },
        icon: icon,
      );
    },
  );
}
