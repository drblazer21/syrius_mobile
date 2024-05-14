import 'package:syrius_mobile/model/app_integrity.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class GeneralStats {
  final Momentum frontierMomentum;
  final ProcessInfo processInfo;
  final NetworkInfo networkInfo;
  final OsInfo osInfo;
  final AppIntegrity appIntegrity;

  GeneralStats({
    required this.frontierMomentum,
    required this.processInfo,
    required this.networkInfo,
    required this.osInfo,
    required this.appIntegrity,
  });
}
