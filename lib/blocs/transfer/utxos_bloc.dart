import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:syrius_mobile/blocs/base_bloc.dart';
import 'package:syrius_mobile/btc/bitcoin_utils.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';

sealed class UtxosState {}

class UtxosStateInitialState extends UtxosState {}

class UtxosStateLoading extends UtxosState {}

class UtxosStateLoaded extends UtxosState {
  final List<UtxoWithAddress> utxos;

  UtxosStateLoaded(this.utxos);
}

class UtxosStateError extends UtxosState {
  final String message;

  UtxosStateError(this.message);
}

class UtxosBloc extends BaseBloc<UtxosState> {
  Future<void> fetch({required String addressHex}) async {
    try {
      addEvent(UtxosStateLoading());
      final List<ElectrumUtxo> electrumUtxos =
          await btc.fetchUtxos(addressHex: addressHex);
      final BitcoinBaseAddress sender = generateTestnetBitcoinBaseAddress(
        addressHex: addressHex,
      );

      final AppAddress appAddress = findAppAddress(addressHex);

      final ECPublic senderPublicKey = await generateBtcTestnetPublicKey(
        index: appAddress.index,
      );

      final List<UtxoWithAddress> utxos = electrumUtxos
          .map(
            (e) => UtxoWithAddress(
              utxo: e.toUtxo(sender.type),
              ownerDetails: UtxoAddressDetails(
                publicKey: senderPublicKey.toHex(),
                address: sender,
              ),
            ),
          )
          .toList();
      addEvent(UtxosStateLoaded(utxos));
    } catch (e) {
      addEvent(UtxosStateError(e.toString()));
    }
  }
}
