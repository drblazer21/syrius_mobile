import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:syrius_mobile/utils/ui/notification_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DeepLinkHandler {
  Future<void> goTo(
    String scheme, {
    int delay = 100,
    String? modalTitle,
    String? modalMessage,
    bool success = true,
  }) async {
    if (kIsWeb) return;
    if (scheme.isEmpty) return;
    await Future.delayed(Duration(milliseconds: delay));
    debugPrint('[WALLET] [DeepLinkHandler] redirecting to $scheme');
    try {
      await launchUrlString(scheme, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint(
        '[WALLET] [DeepLinkHandler] error re-opening dapp ($scheme). $e',
      );
      sendNotificationError('Error going back to the dApp', e);
    }
  }
}
