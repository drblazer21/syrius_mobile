import 'package:syrius_mobile/model/eth_to_znn_quota.dart';

class SwapEthForZnnData {
  String? fromEthAddress;
  EthToZnnQuota? quota;
  double slippage;
  String? toZnnAddress;

  SwapEthForZnnData({
    this.fromEthAddress,
    this.quota,
    // TODO: The user should be able to select the slippage
    this.slippage = 0.02,
    this.toZnnAddress,
  });
}
