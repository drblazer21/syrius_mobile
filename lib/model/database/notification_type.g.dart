// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 101;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.paymentSent;
      case 1:
        return NotificationType.error;
      case 2:
        return NotificationType.stakingDeactivated;
      case 3:
        return NotificationType.paymentReceived;
      case 4:
        return NotificationType.stakeSuccess;
      case 5:
        return NotificationType.delegateSuccess;
      case 6:
        return NotificationType.plasmaSuccess;
      default:
        return NotificationType.paymentSent;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.paymentSent:
        writer.writeByte(0);
        break;
      case NotificationType.error:
        writer.writeByte(1);
        break;
      case NotificationType.stakingDeactivated:
        writer.writeByte(2);
        break;
      case NotificationType.paymentReceived:
        writer.writeByte(3);
        break;
      case NotificationType.stakeSuccess:
        writer.writeByte(4);
        break;
      case NotificationType.delegateSuccess:
        writer.writeByte(5);
        break;
      case NotificationType.plasmaSuccess:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
