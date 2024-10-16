import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NotificationsPageChild extends StatefulWidget {
  const NotificationsPageChild({
    super.key,
  });

  @override
  State<NotificationsPageChild> createState() => _NotificationsPageChildState();
}

class _NotificationsPageChildState extends State<NotificationsPageChild> {
  List<GroupedNotifications> _groupedNotifications = [];

  @override
  void initState() {
    super.initState();
    sl.get<NotificationsService>().markNotificationsAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return AppStreamBuilder<List<WalletNotification>>(
      stream: sl.get<NotificationsService>().notifications,
      builder: (notifications) {
        _groupedNotifications = getSortedWalletNotificationItems(notifications);
        return CustomAppbarScreen(
          appbarTitle: AppLocalizations.of(context)!.notifications,
          withLateralPadding: false,
          actionWidget: Visibility(
            visible: _groupedNotifications.isNotEmpty,
            child: IconButton(
              splashRadius: 20.0,
              icon: const Icon(
                Icons.delete_forever_outlined,
              ),
              onPressed: () async {
                await sl.get<NotificationsService>().deleteNotificationsFromDb();
                setState(() {});
              },
            ),
          ),
          child: notifications.isNotEmpty
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _groupedNotifications.length,
                  itemBuilder: (BuildContext context, int index) {
                    final GroupedNotifications notificationWrapper =
                        _groupedNotifications[index];
                    return NotificationItem(
                      walletTransactionWrapper: notificationWrapper,
                      onCloseClick: (notificationId) async {
                        await sl.get<NotificationsService>().deleteNotification(
                          notificationId,
                        );
                        setState(() {});
                      },
                    );
                  },
                )
              : Center(
                  child: SyriusErrorWidget(
                    AppLocalizations.of(context)!.nothingToShow,
                  ),
                ),
        );
      },
    );
  }
}

class NotificationItem extends StatelessWidget {
  final GroupedNotifications walletTransactionWrapper;
  final Function(int) onCloseClick;

  const NotificationItem({
    required this.onCloseClick,
    required this.walletTransactionWrapper,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.listTileTheme.contentPadding!,
          child: Text(
            getNotificationFormattedDate(
              walletTransactionWrapper.notificationDate,
            ),
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ),
        ...walletTransactionWrapper.notifications.map(
          (e) {
            final WalletNotification item = e;
            final bool isRead = item.isRead;

            return ListTile(
              leading: _prefixNotificationIcon(
                context: context,
                isRead: isRead,
              ),
              subtitle: _buildSubtitle(item),
              title: _buildTitle(item),
              trailing: iconRight(item, context),
            );
          },
        ),
      ],
    );
  }

  void onRightIconClick(
    WalletNotification walletNotification,
    BuildContext context,
  ) {
    final HistoryScreenControllerNotifier historyScreenControllerNotifier =
        context.read<HistoryScreenControllerNotifier>();
    final NotificationType notificationType = walletNotification.type;

    if (notificationType == NotificationType.stakeSuccess) {
      showStakingScreen(context);
    } else if (notificationType == NotificationType.delegateSuccess) {
      showDelegateScreen(context);
    } else if (notificationType == NotificationType.plasmaSuccess) {
      showPlasmaFusingScreen(context);
    } else if (notificationType == NotificationType.paymentSent) {
      Navigator.pop(context);
      historyScreenControllerNotifier.redirectToHistoryScreen();
    } else if (notificationType == NotificationType.paymentReceived) {
      Navigator.pop(context);
      historyScreenControllerNotifier.redirectToHistoryScreen();
    } else if (notificationType == NotificationType.stakingDeactivated) {
      showStakingScreen(context);
    } else {
      onCloseClick(walletNotification.id);
    }
  }

  Widget iconRight(
    WalletNotification walletNotification,
    BuildContext context,
  ) {
    final NotificationType notificationType = walletNotification.type;
    final Color iconColor = context.colorScheme.outlineVariant;
    IconData iconData = Icons.close;
    if (notificationType == NotificationType.stakeSuccess ||
        notificationType == NotificationType.delegateSuccess ||
        notificationType == NotificationType.plasmaSuccess ||
        notificationType == NotificationType.paymentSent ||
        notificationType == NotificationType.paymentReceived ||
        notificationType == NotificationType.stakingDeactivated) {
      iconData = Icons.arrow_forward;
    }
    return GestureDetector(
      onTap: () {
        onRightIconClick(walletNotification, context);
      },
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: ShapeDecoration(
          shape: CircleBorder(
            side: BorderSide(
              color: iconColor,
              width: 2.0,
            ),
          ),
        ),
        child: Icon(
          iconData,
          size: 18.0,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }

  Text _buildSubtitle(WalletNotification item) {
    return Text(
      item.details,
      maxLines: 3,
    );
  }

  Text _buildTitle(WalletNotification item) {
    return Text(
      item.title,
    );
  }

  Widget _prefixNotificationIcon({
    required BuildContext context,
    required bool isRead,
  }) {
    return CircleAvatar(
      backgroundColor: context.colorScheme.outlineVariant,
      child: Icon(
        Icons.notifications,
        color: isRead
            ? context.colorScheme.onSurface
            : context.colorScheme.primary,
      ),
    );
  }
}
