import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:syrius_mobile/utils/utils.dart';

Future<String> generateBtcTestnetAddress({required int index}) async {
  final ECPublic public = await generateBtcTestnetPublicKey(index: index);

  return public.toSegwitAddress().toAddress(BitcoinNetwork.testnet);
}

Future<ECPublic> generateBtcTestnetPublicKey({required int index}) async {
  final ECPrivate private = await generateBtcTestnetPrivateKey(index: index);
  final ECPublic public = private.getPublic();

  return public;
}

Future<ECPrivate> generateBtcTestnetPrivateKey({required int index}) async {
  final String? mnemonic = await getMnemonic();

  final seedBytes = Bip39SeedGenerator(
    Mnemonic.fromString(
      mnemonic!,
    ),
  ).generate();

  final bip32 = Bip32Slip10Secp256k1.fromSeed(seedBytes);
  final Bip32Base bip32base = bip32.derivePath("m/84'/1'/0'/0/$index");
  return ECPrivate.fromBytes(bip32base.privateKey.raw);
}

BitcoinBaseAddress generateTestnetBitcoinBaseAddress({
  required String addressHex,
}) {
  final BitcoinBaseAddress bitcoinBaseAddress = P2wpkhAddress.fromAddress(
    address: addressHex,
    network: BitcoinNetwork.testnet,
  );

  return bitcoinBaseAddress;
}

Future<ECPrivate> generateTaprootPrivateKey({required int index}) async {
  final String? mnemonic = await getMnemonic();

  final seedBytes = Bip39SeedGenerator(
    Mnemonic.fromString(
      mnemonic!,
    ),
  ).generate();

  final bip32 = Bip32Slip10Secp256k1.fromSeed(seedBytes);
  final Bip32Base bip32base = bip32.derivePath("m/86'/0'/0'/0/$index");
  return ECPrivate.fromBytes(bip32base.privateKey.raw);
}

Future<String> generateTaprootAddress({required int index}) async {
  final ECPublic public = await generateTaprootPublicKey(index: index);

  return public.toTaprootAddress().toAddress(BitcoinNetwork.mainnet);
}

Future<ECPublic> generateTaprootPublicKey({required int index}) async {
  final ECPrivate private = await generateTaprootPrivateKey(index: index);
  final ECPublic public = private.getPublic();

  return public;
}

BitcoinBaseAddress generateTaprootBitcoinBaseAddress({
  required String addressHex,
}) {
  final BitcoinBaseAddress bitcoinBaseAddress = P2trAddress.fromAddress(
    address: addressHex,
    network: BitcoinNetwork.mainnet,
  );

  return bitcoinBaseAddress;
}

bool btcAddressValidator(String address) {
  try {
    generateTestnetBitcoinBaseAddress(addressHex: address);
    return true;
  } catch (e) {
    rethrow;
  }
}
