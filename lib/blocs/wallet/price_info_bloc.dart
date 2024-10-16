import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/constants.dart';

class PriceInfoBloc extends BaseBloc<PriceInfo?> {
  Future<void> getPrice() async {
    try {
      String response = '';
      final int cacheTimestamp =
          sharedPrefs.getInt(kPriceInfoApiResponseTimestampKey) ?? 0;
      final DateTime cacheTime =
          DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
      final DateTime now = DateTime.now();
      if (now.difference(cacheTime) < kPriceInfoResponseCacheDuration) {
        response = sharedPrefs.getString(kPriceInfoApiResponseKey)!;
      } else {
        final uri = Uri.parse(kPriceInfoApi);
        response = (await http.get(uri)).body;
        await sharedPrefs.setString(kPriceInfoApiResponseKey, response);
        await sharedPrefs.setInt(
          kPriceInfoApiResponseTimestampKey,
          now.millisecondsSinceEpoch,
        );
      }
      final decodedResponse = await compute(
        (body) => jsonDecode(body),
        response,
      );
      final PriceInfo priceInfo = PriceInfo.fromJson(
        (decodedResponse as Map)['data'] as Map<String, dynamic>,
      );
      addEvent(priceInfo);
    } catch (e) {
      addError(e);
    }
  }
}
