import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class StakingOptionsBloc extends BaseBloc<AccountBlockTemplate?> {
  void stakeForQsr(
    Duration stakeDuration,
    BigInt amount,
  ) {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams = zenon.embedded.stake.stake(
        stakeDuration.inSeconds,
        amount,
      );
      createAccountBlock(
        transactionParams,
        'create stake',
        waitForRequiredPlasma: true,
        actionType: ActionType.stake,
      ).then(
        (response) async {
          await Future.delayed(kDelayAfterBlockCreationCall);
          refreshBalanceAndTx();
          _sendSuccessStakingNotification(
            amount: amount.addDecimals(coinDecimals),
          );
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

  void _sendSuccessStakingNotification({
    required String amount,
  }) {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Staked $amount ${kZnnCoin.symbol} '
                'for ${getLabel(kSelectedAddress!)}',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Staked $amount ${kZnnCoin.symbol} '
                'for ${getLabel(kSelectedAddress!)}',
            type: NotificationType.stakeSuccess,
          ),
        );
  }
}
