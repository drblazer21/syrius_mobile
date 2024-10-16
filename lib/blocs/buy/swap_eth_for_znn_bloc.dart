import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';

class SwapEthForZnnBloc extends BaseBloc<String> {
  Future<void> swap({required SwapEthForZnnData data}) async {
    try {
      final String hash = await eth.swapExactETHForTokens(data: data);
      addEvent(hash);
    } catch (e) {
      addError(e);
    }
  }
}
