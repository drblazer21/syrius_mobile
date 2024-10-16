import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class ZenonNodeStats {
  final Momentum frontierMomentum;
  final ProcessInfo processInfo;
  final NetworkInfo networkInfo;
  final OsInfo osInfo;

  ZenonNodeStats({
    required this.frontierMomentum,
    required this.processInfo,
    required this.networkInfo,
    required this.osInfo,
  });
}
