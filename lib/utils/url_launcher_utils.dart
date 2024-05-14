import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> launchUrl(String url) async {
  String urlCopy = url;

  if (!RegExp('^http').hasMatch(url)) {
    urlCopy = 'http://$url';
  }
  if (await canLaunchUrlString(urlCopy)) {
    await launchUrlString(urlCopy);
  } else {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Error while trying to open external link',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Something went wrong while trying to open $urlCopy',
            type: NotificationType.error,
          ),
        );
  }
}
