import 'package:hive/hive.dart';
import 'package:syrius_mobile/utils/utils.dart';

part 'notification_type.g.dart';

@HiveType(typeId: kNotificationTypeEnumHiveTypeId)
enum NotificationType {
  @HiveField(0)
  paymentSent,

  @HiveField(1)
  error,

  @HiveField(2)
  stakingDeactivated,

  @HiveField(3)
  paymentReceived,

  @HiveField(4)
  stakeSuccess,

  @HiveField(5)
  delegateSuccess,

  @HiveField(6)
  plasmaSuccess,
}
