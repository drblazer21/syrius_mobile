import 'package:syrius_mobile/btc/cross_platform_websocket/core.dart';

Future<WebSocketCore> connectSoc(String url, {List<String>? protocols}) =>
    throw UnsupportedError(
      'Cannot create an instance without dart:html or dart:io.',
    );
