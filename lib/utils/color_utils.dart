import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

Color getTokenColor(Token token) {
  return kCoinIdColor[token.tokenStandard] ??
      getColorFromHexCode(
        _getHexCodeFromTokenZts(token.tokenStandard),
      );
}

Color getColorFromHexCode(String hexCode) {
  return Color(int.parse(hexCode, radix: 16) + 0xFF000000);
}

String _getHexCodeFromTokenZts(TokenStandard tokenStandard) {
  final List<int> bytes = tokenStandard.getBytes().sublist(
        tokenStandard.getBytes().length - 3,
      );
  return BytesUtils.bytesToHex(bytes);
}
