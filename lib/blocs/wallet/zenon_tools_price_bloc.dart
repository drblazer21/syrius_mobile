import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/constants.dart';

class ZenonToolsPriceBloc extends BaseBloc<ZenonToolsPriceInfo?> {
  Future<void> getPrice() async {
    try {
      final uri = Uri.parse(kZenonToolsPriceEndpoint);
      final response = await http.get(uri);
      final decodedResponse = await compute(
        (bytes) => jsonDecode(utf8.decode(bytes)),
        response.bodyBytes,
      );
      final ZenonToolsPriceInfo priceInfo = ZenonToolsPriceInfo.fromJson(
        decodedResponse as Map<String, dynamic>,
      );
      addEvent(priceInfo);
    } catch (e) {
      addError(e);
    }
  }
}
