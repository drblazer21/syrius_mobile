import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:syrius_mobile/btc/electrum/request_completer.dart';

class ElectrumTCPService with BitcoinBaseElectrumRPCService {
  ElectrumTCPService._(
    this.url,
    Socket channel, {
    this.defaultRequestTimeOut = const Duration(seconds: 30),
  }) : _socket = channel {
    _subscription =
        _socket!.listen(_onMessage, onError: _onClose, onDone: _onDone);
  }

  Socket? _socket;
  StreamSubscription<List<int>>? _subscription;
  final Duration defaultRequestTimeOut;

  Map<int, AsyncRequestCompleter> requests = {};
  bool _isDisconnect = false;

  bool get isConnected => _isDisconnect;

  @override
  final String url;

  void add(List<int> params) {
    if (_isDisconnect) {
      throw StateError("socket has been disconnected");
    }
    _socket?.add(params);
  }

  void _onClose(Object? error) {
    _isDisconnect = true;

    _socket = null;
    _subscription?.cancel().catchError((e) {});
    _subscription = null;
  }

  void _onDone() {
    _onClose(null);
  }

  void disconnect() {
    _onClose(null);
  }

  static Future<ElectrumTCPService> connect(
    String url, {
    Iterable<String>? protocols,
    Duration defaultRequestTimeOut = const Duration(seconds: 30),
    Duration connectionTimeOut = const Duration(seconds: 30),
  }) async {
    final parts = url.split(":");
    final channel = await Socket.connect(parts[0], int.parse(parts[1]))
        .timeout(connectionTimeOut);

    return ElectrumTCPService._(
      url,
      channel,
      defaultRequestTimeOut: defaultRequestTimeOut,
    );
  }

  void _onMessage(List<int> event) {
    final Map<String, dynamic> decode =
        json.decode(utf8.decode(event)) as Map<String, dynamic>;
    if (decode.containsKey("id")) {
      final int id = int.parse(decode["id"]!.toString());
      final request = requests.remove(id);
      request?.completer.complete(decode);
    }
  }

  @override
  Future<Map<String, dynamic>> call(
    ElectrumRequestDetails params, [
    Duration? timeout,
  ]) async {
    final AsyncRequestCompleter completer =
        AsyncRequestCompleter(params.params);

    try {
      requests[params.id] = completer;
      add(params.toWebSocketParams());
      final result = await completer.completer.future
          .timeout(timeout ?? defaultRequestTimeOut);
      return result;
    } finally {
      requests.remove(params.id);
    }
  }
}
