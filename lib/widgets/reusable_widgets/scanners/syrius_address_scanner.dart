import 'package:syrius_mobile/utils/input_validators.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class SyriusAddressScanner extends SyriusQrCodeScanner {
  SyriusAddressScanner({
    required super.context,
    required super.onScan,
    super.key,
  }) : super(
          validator: (value) {
            for (final barcode in value.barcodes) {
              final String? displayValue = barcode.displayValue;
              if (displayValue != null && checkAddress(displayValue) == null) {
                return true;
              }
            }

            return false;
          },
        );
}
