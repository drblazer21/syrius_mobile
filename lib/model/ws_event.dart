import 'package:znn_sdk_dart/znn_sdk_dart.dart';

/// A sketch for the events send by [Zenon] through the web socket

class WsEvent {
  final String? method;
  final WsParam? params;

  WsEvent({this.method, required this.params});

  factory WsEvent.fromJson(Map<String, dynamic> json) => WsEvent(
        method: json['method'] as String?,
        params: json['params'] != null
            ? WsParam.fromJson(json['params'] as Map<String, dynamic>)
            : null,
      );
}

class WsParam {
  final String subscription;
  final List<WsResult> results;

  WsParam({
    required this.subscription,
    required this.results,
  });

  factory WsParam.fromJson(Map<String, dynamic> json) {
    final String subscription = json['subscription'] as String;
    final List<dynamic> resultsDynamic = json['result'] as List;
    final List<Map<String, dynamic>> resultsMap = List.generate(
      resultsDynamic.length,
      (index) => resultsDynamic[index] as Map<String, dynamic>,
    );
    final List<WsResult> results =
        resultsMap.map((map) => WsResult.fromJson(map)).toList();

    return WsParam(subscription: subscription, results: results);
  }
}

class WsResult {
  final String hash;
  final int height;

  WsResult({required this.hash, required this.height});

  factory WsResult.fromJson(Map<String, dynamic> json) => WsResult(
        hash: json['hash'] as String,
        height: json['height'] as int,
      );
}

// {jsonrpc: 2.0,
// method: ledger.subscription,
// params:
//   {
//     subscription: 0xdc9c7d558cf98e6be9fccc18ffb8311d,
//     result: [
//         {
//           hash: bd1dba9c12b9d38a0bd2e070dac1e95bfcadc5c2f0bbf6b0bfddd44949227fba,
//           height: 2288727,
//         },
//     ],
//   },
// }
