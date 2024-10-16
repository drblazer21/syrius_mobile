import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:syrius_mobile/btc/electrum/request_completer.dart';

class ElectrumSSLService with BitcoinBaseElectrumRPCService {
  ElectrumSSLService._(
    this.url,
    SecureSocket channel, {
    this.defaultRequestTimeOut = const Duration(seconds: 30),
  }) : _socket = channel {
    _subscription =
        _socket!.listen(_onMessge, onError: _onClose, onDone: _onDone);
  }

  SecureSocket? _socket;
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

  Future<void> _onClose(Object? error) async {
    await _socket?.close();
    _isDisconnect = true;
    _socket = null;
    _subscription?.cancel().catchError((e) {});
    _subscription = null;
  }

  void _onDone() {
    _onClose(null);
  }

  Future<void> disconnect() => _onClose(null);

  static Future<ElectrumSSLService> connect(
    Uri uri, {
    Iterable<String>? protocols,
    Duration defaultRequestTimeOut = const Duration(seconds: 30),
    Duration connectionTimeOut = const Duration(seconds: 30),
  }) async {
    final channel = await SecureSocket.connect(
      uri.host,
      uri.port,
      onBadCertificate: (certificate) => true,
    ).timeout(connectionTimeOut);

    return ElectrumSSLService._(
      uri.host,
      channel,
      defaultRequestTimeOut: defaultRequestTimeOut,
    );
  }

  void _onMessge(List<int> event) {
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
    final AsyncRequestCompleter compeleter =
        AsyncRequestCompleter(params.params);

    try {
      requests[params.id] = compeleter;
      add(params.toTCPParams());
      final result = await compeleter.completer.future
          .timeout(timeout ?? defaultRequestTimeOut);
      return result;
    } finally {
      requests.remove(params.id);
    }
  }
}
