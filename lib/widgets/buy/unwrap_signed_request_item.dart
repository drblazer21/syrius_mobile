import 'package:flutter/material.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class UnwrapSignedRequest extends StatelessWidget {
  final UnwrapTokenRequest unwrapTokenRequest;

  const UnwrapSignedRequest({required this.unwrapTokenRequest, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(unwrapTokenRequest.toJson().toString());
  }
}
