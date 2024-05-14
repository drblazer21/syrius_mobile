import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
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
      final bool requireOtpConfirmation = sharedPrefsService.get(
        kUseOtpForTxConfirmationKey,
        defaultValue: false,
      )!;
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
    addEvent(null);
    final AccountBlockTemplate transactionParams = AccountBlockTemplate.send(
      Address.parse(toAddress),
      token.tokenStandard,
      amount,
      data,
    );

    final KeyPair blockSigningKeyPair =
        await getKeyPairFromAddress(fromAddress);

    createAccountBlock(
      transactionParams,
      'send transaction',
      blockSigningKey: blockSigningKeyPair,
      waitForRequiredPlasma: true,
      actionType: ActionType.sendFund,
    ).then(
      (response) {
        refreshBalanceAndTx();
        addEvent(response);
        _sendSuccessPaymentNotification(
          amount: amount.addDecimals(token.decimals),
          recipient: toAddress,
          tokenSymbol: token.symbol,
        );
      },
    ).onError(
      (error, stackTrace) {
        addError(error.toString());
        _sendErrorPaymentNotification(
          amount: amount.addDecimals(token.decimals),
          error: error,
          recipient: toAddress,
          tokenSymbol: token.symbol,
        );
      },
    );
  }

  void _sendSuccessPaymentNotification({
    required String amount,
    required String recipient,
    required String tokenSymbol,
  }) {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Sent $amount $tokenSymbol '
                'to ${getLabel(recipient)}',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Sent $amount $tokenSymbol '
                'from ${getLabel(kSelectedAddress!)} to ${getLabel(recipient)}',
            type: NotificationType.paymentSent,
          ),
        );
  }

  void _sendErrorPaymentNotification({
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
