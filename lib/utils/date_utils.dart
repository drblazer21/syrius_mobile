import 'package:intl/intl.dart';
import 'package:syrius_mobile/l10n/all_locales.dart';

DateTime timestampToDateTime(int timestampMs) {
  return DateTime.fromMillisecondsSinceEpoch(
    timestampMs,
  );
}

String getNotificationFormattedDate(DateTime dateTime) {
  final DateFormat format = DateFormat('dd MMM');
  return format.format(dateTime);
}

String formatTxsDateTime(DateTime dateTime) {
  final String localeFormattedDate =
      DateFormat.yMMMMd(kDefaultLocale.toString()).add_jms().format(dateTime);
  return localeFormattedDate;
}
