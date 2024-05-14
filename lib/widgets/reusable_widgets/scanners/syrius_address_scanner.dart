import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class SyriusAddressScanner extends SyriusQrCodeScanner {
  SyriusAddressScanner({
    required super.context,
    required super.onScan,
    super.key,
  }) : super(
          validator: Address.isValid,
        );
}
