import 'package:flutter/material.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';

class CustomAppbarScreen extends StatelessWidget {
  final String? appbarTitle;
  final Widget? appbarTitleWidget;
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
    this.appbarTitleWidget,
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
        title: title ?? appbarTitleWidget,
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
    color: context.colorScheme.onSurface,
  );
  return StreamBuilder<List<WalletNotification?>>(
    stream: sl.get<NotificationsService>().notifications,
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
          );
        },
        icon: icon,
      );
    },
  );
}
