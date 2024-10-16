import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class BtcSendTransactionBloc extends BaseBloc<String> {
  Future<void> send({
    required String amount,
    required String changeAddress,
    required BuildContext context,
    required bool enableRbf,
    required BigInt estimatedFee,
    required String recipient,
    required List<UtxoWithAddress> utxos,
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
              _buildAndSendTx(
                changeAddress,
                amount,
                recipient,
                utxos,
                estimatedFee,
                enableRbf,
              );
            },
          ),
        );
      } else {
        _buildAndSendTx(
          changeAddress,
          amount,
          recipient,
          utxos,
          estimatedFee,
          enableRbf,
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _buildAndSendTx(
    String changeAddress,
    String amount,
    String recipient,
    List<UtxoWithAddress> utxos,
    BigInt estimatedFee,
    bool enableRbf,
  ) async {
    try {
      final BitcoinNetwork bitcoinNetwork =
          kSelectedAppNetworkWithAssets!.network.bitcoinBaseNetwork;

      final BitcoinBaseAddress changeBitcoinBaseAddress =
          bitcoinNetwork.bitcoinBaseAddressGenerator(addressHex: changeAddress);

      final BitcoinOutput output = _getOutput(
        amount: amount,
        bitcoinNetwork: bitcoinNetwork,
        recipient: recipient,
      );

      final BigInt changeValue =
          utxos.sumOfUtxosValue() - output.value - estimatedFee;

      final BitcoinOutput changeOutput = BitcoinOutput(
        address: changeBitcoinBaseAddress,
        value: changeValue,
      );

      final List<BitcoinOutput> outputs = [output, changeOutput];

      final BitcoinTransactionBuilder builder = BitcoinTransactionBuilder(
        outPuts: outputs,
        fee: estimatedFee,
        network: bitcoinNetwork,
        utxos: utxos,
        enableRBF: enableRbf,
      );

      final ECPrivate senderPrivate = await bitcoinNetwork.privateKeyGenerator(
        index: selectedAddress.index,
      );

      final BtcTransaction transaction =
          builder.buildTransaction((trDigest, utxo, publicKey, sighash) {
        if (utxo.utxo.isP2tr()) {
          return senderPrivate.signTapRoot(trDigest, sighash: sighash);
        }
        return senderPrivate.signInput(trDigest, sigHash: sighash);
      });

      final String raw = transaction.serialize();

      final String hash = await btc.sendRawTx(rawTx: raw);
      addEvent(hash);
    } catch (e) {
      addError(e);
    }
  }

  BitcoinOutput _getOutput({
    required String amount,
    required BitcoinNetwork bitcoinNetwork,
    required String recipient,
  }) {
    final BigInt value = BtcUtils.toSatoshi(amount);

    final BitcoinBaseAddress receiver =
        bitcoinNetwork.bitcoinBaseAddressGenerator(
      addressHex: recipient,
    );

    return BitcoinOutput(
      address: receiver,
      value: value,
    );
  }

  /// Lock time occupies the last 4 bytes in the transaction, and this functions
  /// helps convert the int number inputted by the user into a value of four bytes
  List<int> _getLockTimeAsBytes({required String lockTime}) {
    final int number;

    if (lockTime.isEmpty) {
      number = 0;
    } else {
      number = int.parse(lockTime);
    }

    final List<int> bytes = [
      (number >> 24) & 0xFF, // Extract the first (most significant) byte
      (number >> 16) & 0xFF, // Extract the second byte
      (number >> 8) & 0xFF, // Extract the third byte
      number & 0xFF, // Extract the fourth (least significant) byte
    ];

    return bytes;
  }
}
