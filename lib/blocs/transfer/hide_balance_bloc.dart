import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';

class HideBalanceBloc extends BaseBloc<bool> {
  void toggleHideBalance() {
    try {
      final bool isHideBalance = sharedPrefs.getBool(
        kIsHideBalanceKey,
      ) ?? false;
      addEvent(isHideBalance);
    } catch (e) {
      addError(e);
      addEvent(false);
    }
  }
}
