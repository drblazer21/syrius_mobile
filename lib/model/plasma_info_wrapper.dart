import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PlasmaInfoWrapper {
  final String address;
  final PlasmaInfo plasmaInfo;
  final PlasmaLevel plasmaLevel;

  PlasmaInfoWrapper({
    required this.address,
    required this.plasmaInfo,
  }) : plasmaLevel = _getPlasmaLevel(plasmaInfo);

  static PlasmaLevel _getPlasmaLevel(PlasmaInfo plasmaInfo) {
    if (plasmaInfo.currentPlasma >= kPillarPlasmaAmountNeeded) {
      return PlasmaLevel.high;
    } else if (plasmaInfo.currentPlasma >= kIssueTokenPlasmaAmountNeeded &&
        plasmaInfo.currentPlasma < kPillarPlasmaAmountNeeded) {
      return PlasmaLevel.average;
    } else if (plasmaInfo.currentPlasma >= minPlasmaAmount.toInt() &&
        plasmaInfo.currentPlasma < kIssueTokenPlasmaAmountNeeded) {
      return PlasmaLevel.low;
    } else {
      return PlasmaLevel.insufficient;
    }
  }
}
