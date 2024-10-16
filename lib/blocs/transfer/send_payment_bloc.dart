import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class SendPaymentBloc extends BaseBloc<AccountBlockTemplate?> {
  void sendTransfer({
    required BuildContext context,
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required Token token,
    List<int>? data,
  }) {
    try {
      final bool requireOtpConfirmation = sharedPrefs.getBool(
            kUseOtpForTxConfirmationKey,
          ) ??
          false;
      if (requireOtpConfirmation) {
        showModalBottomSheetWithBody(
          context: context,
          title: AppLocalizations.of(context)!.otpConfirmation,
          body: OtpCodeConfirmation(
            onCodeInvalid: () {
              Navigator.pop(context);
              addError(AppLocalizations.of(context)!.totpError);
              sendNotificationError(
                AppLocalizations.of(context)!.totpNotificationErrorTitle,
                AppLocalizations.of(context)!.totpError,
              );
            },
            onCodeValid: (String secretKey) {
              Navigator.pop(context);
              _sendBlock(
                amount: amount,
                data: data,
                fromAddress: fromAddress,
                toAddress: toAddress,
                token: token,
              );
            },
          ),
        );
      } else {
        _sendBlock(
          amount: amount,
          data: data,
          fromAddress: fromAddress,
          toAddress: toAddress,
          token: token,
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _sendBlock({
    required String fromAddress,
    required String toAddress,
    required BigInt amount,
    required Token token,
    List<int>? data,
  }) async {
    try {
      addEvent(null);
      final AccountBlockTemplate transactionParams = AccountBlockTemplate.send(
        Address.parse(toAddress),
        token.tokenStandard,
        amount,
        data,
      );

      createAccountBlock(
        transactionParams,
        'send transaction',
        blockSigningAddress: fromAddress,
        waitForRequiredPlasma: true,
        actionType: ActionType.sendFund,
      ).then(
        (response) {
          refreshBalanceAndTx();
          addEvent(response);
          sendSuccessPaymentNotification(
            amount: amount.toStringWithDecimals(token.decimals),
            recipient: toAddress,
            tokenSymbol: token.symbol,
          );
        },
      );
    } catch (error) {
      addError(error.toString());
      sendErrorPaymentNotification(
        amount: amount.toStringWithDecimals(token.decimals),
        error: error,
        recipient: toAddress,
        tokenSymbol: token.symbol,
      );
    }
  }

  static void sendSuccessPaymentNotification({
    required String amount,
    required String recipient,
    required String tokenSymbol,
  }) {
    final String recipientLabel = getLabel(recipient);

    sl.get<NotificationsService>().addNotification(
          WalletNotificationsCompanion.insert(
            title: 'Sent $amount $tokenSymbol '
                'to $recipientLabel',
            details: 'Sent $amount $tokenSymbol '
                'from ${kSelectedAddress!.label} to $recipientLabel',
            type: NotificationType.paymentSent,
          ),
        );
  }

  static void sendErrorPaymentNotification({
    required String amount,
    required dynamic error,
    required String recipient,
    required String tokenSymbol,
  }) {
    sendNotificationError(
      'Could not send $amount $tokenSymbol to $recipient',
      error,
    );
  }
}
