import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
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
            amount: amount.toStringWithDecimals(coinDecimals),
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
    sl.get<NotificationsService>().addNotification(
          WalletNotificationsCompanion.insert(
            title: 'Staked $amount ${kZnnCoin.symbol} '
                'for ${kSelectedAddress!.label}',
            details: 'Staked $amount ${kZnnCoin.symbol} '
                'for ${kSelectedAddress!.label}',
            type: NotificationType.stakeSuccess,
          ),
        );
  }
}
