import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/eth_to_znn_quota.dart';

class EthToZnnQuotaBloc extends BaseBloc<EthToZnnQuota> {

  Future<void> fetch({required BigInt weiAmount}) async {
    try {
      final EthToZnnQuota result = await eth.getAmountsOut(weiAmount: weiAmount);
      addEvent(result);
    } catch (e) {
      addError(e);
    }
  }
}
