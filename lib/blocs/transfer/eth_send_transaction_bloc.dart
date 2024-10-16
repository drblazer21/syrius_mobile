import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/eth_support/ethereum_service.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/screens/settings/otp/otp_code_confirmation.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:web3dart/web3dart.dart';

class EthSendTransactionBloc extends BaseBloc<String> {
  Future<void> send({
    required BuildContext context,
    required Transaction tx,
  }) async {
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
              _sendTransactionAndUpdateStream(tx);
            },
          ),
        );
      } else {
        _sendTransactionAndUpdateStream(tx);
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _sendTransactionAndUpdateStream(
    Transaction tx,
  ) async {
    try {
      final String hash = await _sendTransaction(tx);
      addEvent(hash);
    } catch (e) {
      sendNotificationError(
        e.toString(),
        e,
      );
    }
  }

  Future<String> _sendTransaction(
    Transaction tx,
  ) async {
    final EthereumService ethereumService = sl.get<EthereumService>();

    final String hash = await ethereumService.sendEthereumAssetTx(
      tx: tx,
    );

    return hash;
  }
}
