import 'package:syrius_mobile/utils/utils.dart';

enum AppNetwork {
  znn;

  String get imagePath {
    switch (this) {
      case znn:
        return getSvgImagePath('zn_icon');
    }
  }
}
