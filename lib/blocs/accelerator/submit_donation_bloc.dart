import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class SubmitDonationBloc extends BaseBloc<AccountBlockTemplate?> {
  Future<void> submitDonation(BigInt znnAmount, BigInt qsrAmount) async {
    try {
      addEvent(null);
      if (znnAmount > BigInt.zero) {
        await _sendDonationBlock(
          zenon.embedded.accelerator.donate(
            znnAmount,
            kZnnCoin.tokenStandard,
          ),
        );
      }
      if (qsrAmount > BigInt.zero) {
        await _sendDonationBlock(
          zenon.embedded.accelerator.donate(
            qsrAmount,
            kQsrCoin.tokenStandard,
          ),
        );
      }
    } catch (e, _) {
      addError(e);
      sendNotificationError(
        'Error while submitting donation',
        e,
      );
    }
  }

  Future<void> _sendDonationBlock(
    AccountBlockTemplate transactionParams,
  ) async {
    final Token selectedToken = kDualCoin.firstWhere(
      (e) => e.tokenStandard == transactionParams.tokenStandard,
    );
    await createAccountBlock(
      transactionParams,
      'donate for accelerator',
    ).then(
      (block) {
        addEvent(block);
        sl.get<NotificationsService>().addNotification(
              WalletNotificationsCompanion.insert(
                title: 'Submitted accelerator donation',
                details: '${transactionParams.amount.toStringWithDecimals(
                  selectedToken.decimals,
                )} ${selectedToken.symbol}',
                type: NotificationType.paymentSent,
              ),
            );
        dispose();
      },
    ).onError(
      (error, stackTrace) {
        addError(error ?? 'No error available');
        sendNotificationError(
          'Error while submitting donation',
          error,
        );
      },
    );
  }
}
