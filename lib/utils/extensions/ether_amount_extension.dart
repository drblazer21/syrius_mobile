import 'package:syrius_mobile/utils/utils.dart';
import 'package:web3dart/web3dart.dart';

extension EtherAmountExtension on EtherAmount {
  bool isBiggerOrEqualTo({required EtherAmount otherAmount}) {
    final BigInt wei = getInWei;
    final BigInt otherWei = otherAmount.getInWei;
    return wei >= otherWei;
  }

  String toEthWithDecimals() {
    final BigInt wei = getValueInUnitBI(EtherUnit.wei);
    final String ethWithDecimals = wei.toStringWithDecimals(kEvmCurrencyDecimals);

    return ethWithDecimals;
  }
}
