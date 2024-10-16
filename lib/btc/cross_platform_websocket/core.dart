import 'package:syrius_mobile/btc/cross_platform_websocket/cross.dart'
    if (dart.library.html) 'web.dart'
    if (dart.library.io) 'io.dart';

abstract class WebSocketCore {
  void close({int? code});

  void sink(List<int> message);

  Stream<dynamic> get stream;

  bool get isConnected;

  static Future<WebSocketCore> connect(
    String url, {
    List<String>? protocols,
  }) async =>
      connectSoc(url, protocols: protocols);
}
