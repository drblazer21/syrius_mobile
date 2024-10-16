import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';

void copyToClipboard({
  required String data,
  bool sendSuccessNotification = true,
  VoidCallback? afterCopying,
}) {
  Clipboard.setData(
    ClipboardData(
      text: data,
    ),
  ).then(
    (value) {
      afterCopying?.call();
      if (sendSuccessNotification) {
        sl.get<NotificationsService>().addNotification(
              WalletNotificationsCompanion.insert(
                type: NotificationType.copiedToClipboard,
                title: 'Successfully copied to clipboard',
                details: '',
                isRead: const Value(true),
              ),
            );
      }
    },
  );
}

void pasteToClipboard(Function(String) callback) {
  Clipboard.getData(Clipboard.kTextPlain).then(
    (value) {
      if (value != null) {
        if (value.text?.isNotEmpty ?? false) {
          callback(value.text!);
          clearClipboard();
        }
      } else {
        sendNotificationError(
          'Something went wrong while getting the clipboard data',
          Exception('The clipboard data could not be obtained'),
        );
      }
    },
  );
}

void clearClipboard() {
  copyToClipboard(
    data: '',
    sendSuccessNotification: false,
  );
}
