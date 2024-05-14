import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PlasmaOptionsBloc extends BaseBloc<AccountBlockTemplate?> {
  void generatePlasma(String beneficiaryAddress, BigInt amount) {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams = zenon.embedded.plasma.fuse(
        Address.parse(beneficiaryAddress),
        amount,
      );
      createAccountBlock(
        transactionParams,
        'fuse ${kQsrCoin.symbol} for Plasma',
        waitForRequiredPlasma: true,
        actionType: ActionType.plasma,
      ).then(
        (response) {
          _sendSuccessPlasmaNotification(
            amount: amount.addDecimals(coinDecimals),
            beneficiary: beneficiaryAddress,
          );
          refreshBalanceAndTx();
          addEvent(response);
        },
      ).onError(
        (error, stackTrace) {
          addError(error.toString());
        },
      );
    } catch (e) {
      addError(e);
    }
  }

  void _sendSuccessPlasmaNotification({
    required String amount,
    required String beneficiary,
  }) {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Fused $amount ${kQsrCoin.symbol} '
                'for ${getLabel(beneficiary)}',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Fused $amount ${kQsrCoin.symbol} '
                'for ${getLabel(beneficiary)} from ${getLabel(kSelectedAddress!)}',
            type: NotificationType.plasmaSuccess,
          ),
        );
  }
}
