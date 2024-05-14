import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';

part 'wallet_notification.g.dart';

@HiveType(typeId: kWalletNotificationHiveTypeId)
class WalletNotification extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final int? timestamp;

  @HiveField(2)
  final String? details;

  @HiveField(3)
  final NotificationType? type;

  @HiveField(4)
  late bool isRead;

  WalletNotification({
    required this.title,
    required this.timestamp,
    this.details,
    this.type,
    this.isRead = false,
  });

  Widget getIcon(BuildContext context) {
    switch (type) {
      case NotificationType.stakeSuccess:
        return _getCircledIcon('staked');
      case NotificationType.delegateSuccess:
        return _getCircledIcon('pillar');
      case NotificationType.plasmaSuccess:
        return const Icon(
          Icons.flash_on,
          color: znnColor,
        );
      case NotificationType.paymentReceived:
        return const Icon(
          Icons.arrow_downward,
          color: znnColor,
        );
      case NotificationType.paymentSent:
        return const Icon(
          Icons.arrow_upward,
          color: znnColor,
        );
      case NotificationType.error:
        return Icon(
          Icons.error,
          color: context.colorScheme.error,
        );

      default:
        return const Icon(
          Icons.notifications_active,
          color: znnColor,
        );
    }
  }

  Widget _getCircledIcon(
    String icon, {
    Color? iconColor,
  }) {
    iconColor ??= znnColor;
    return SvgPicture.asset(
      getSvgImagePath(icon),
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      height: 20.0,
    );
  }
}
