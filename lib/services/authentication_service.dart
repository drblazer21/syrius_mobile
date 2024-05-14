import 'dart:convert';
import 'dart:io';

import 'package:argon2_ffi_base/argon2_ffi_base.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:secp256r1/secp256r1.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/constants.dart';
import 'package:syrius_mobile/utils/wallet/wallet_file.dart';
import 'package:tuple/tuple.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AuthenticationService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<Uint8List> _getSharedSecret() async {
    const String alice = 'alice';
    const String bob = 'bob';

    final bobPublicKey = await SecureP256.getPublicKey(bob);
    await SecureP256.getPublicKey(alice);
    final Uint8List sharedSecretInt = await SecureP256.getSharedSecret(
      alice,
      bobPublicKey,
    );

    return sharedSecretInt;
  }

  Future<Tuple2<Uint8List, Uint8List>> _getSavedEncryptedPin() async {
    final String iv = await secureStorageUtil.read(
      'initializationVector',
    );

    final String cipher = await secureStorageUtil.read(
      'cipher',
    );

    final Uint8List ivDecoded = Uint8List.fromList(HEX.decode(iv));
    final Uint8List cipherDecoded = Uint8List.fromList(HEX.decode(cipher));

    return Tuple2<Uint8List, Uint8List>(ivDecoded, cipherDecoded);
  }

  Future<String> _decryptPin({
    required Tuple2<Uint8List, Uint8List> encryptedPin,
  }) async {
    final Uint8List sharedSecret = await _getSharedSecret();

    final Uint8List iv = encryptedPin.item1;
    final Uint8List cipher = encryptedPin.item2;

    final Uint8List pin = await SecureP256.decrypt(
      sharedSecret: sharedSecret,
      iv: iv,
      cipher: cipher,
    );

    return utf8.decode(pin);
  }

  Future<String> decryptPassword({
    required String pin,
  }) async {
    try {
      final String encodedSalt = await secureStorageUtil.read('salt');

      final Uint8List salt = Uint8List.fromList(HEX.decode(encodedSalt));

      final String encodedSecretBox = await secureStorageUtil.read('secretBox');

      final List<int> decodedSecretBox = HEX.decode(encodedSecretBox);

      final SecretBox secretBox = SecretBox.fromConcatenation(
        decodedSecretBox,
        nonceLength: 12,
        macLength: 16,
      );

      final key = initArgon2().argon2(
        Argon2Arguments(
          Uint8List.fromList(utf8.encode(pin)),
          salt,
          64 * 1024,
          1,
          32,
          4,
          2,
          13,
        ),
      );
      final algorithm = AesGcm.with256bits();
      final entropy = await compute(
        (message) => algorithm.decrypt(
          message,
          secretKey: SecretKey(key),
          aad: utf8.encode('zenon'),
        ),
        secretBox,
      );

      return HEX.encode(entropy);
    } on Exception {
      throw IncorrectPasswordException();
    }
  }

  Future<String> _getPinFromEnclave() async {
    final Tuple2<Uint8List, Uint8List> encryptedPin =
        await _getSavedEncryptedPin();

    final String pin = await _decryptPin(encryptedPin: encryptedPin);

    return pin;
  }

  Future<bool> _userAuthenticated() async {
    bool didAuthenticate = false;
    try {
      didAuthenticate = await auth.authenticate(
        localizedReason: 'Authentication required!',
      );
    } on PlatformException catch (e, stackTrace) {
      Logger('LocalAuthentication')
          .log(Level.SEVERE, '_userAuthenticated', e, stackTrace);
    }
    return didAuthenticate;
  }

  Future<bool> _canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<List<BiometricType>> getAvailableBiometry() async {
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    return availableBiometrics;
  }

  Future<void> triggerBiometricAuthentication({
    required File keyStoreFile,
    required VoidCallback onCantAuthenticate,
    required Future<void> Function(String) onSuccess,
  }) async {
    if (await _canAuthenticate()) {
      if ((await getAvailableBiometry()).isNotEmpty) {
        if (await _userAuthenticated()) {
          final String pin = await _getPinFromEnclave();

          final String password = await decryptPassword(pin: pin);

          final WalletFile walletFile =
              await WalletFile.decrypt(keyStoreFile.path, password);

          await walletFile.open().then((wallet) async {
            // Set kKeyStore as wallet
            await secureStorageUtil.write(
              key: kKeyStoreKey,
              value: (wallet as KeyStore).entropy,
            );

            await onSuccess(pin);
          });
        } else {
          onCantAuthenticate();
        }
      } else {
        onCantAuthenticate();
      }
    } else {
      onCantAuthenticate();
    }
  }

  Future<void> encryptPinWithBiometry(String pin) async {
    final Tuple2<Uint8List, Uint8List> encryptedPin =
        await _encryptPinThroughEnclave(
      pin: pin,
    );

    await _saveEncryptedPin(encryptedPin: encryptedPin);
  }

  Future<Tuple2<Uint8List, Uint8List>> _encryptPinThroughEnclave({
    required String pin,
  }) async {
    final Uint8List sharedSecret = await _getSharedSecret();

    final Tuple2<Uint8List, Uint8List> encryptedPin = await SecureP256.encrypt(
      sharedSecret: Uint8List.fromList(
        sharedSecret,
      ),
      message: Uint8List.fromList(utf8.encode(pin)),
    );

    return encryptedPin;
  }

  Future<void> _saveEncryptedPin({
    required Tuple2<Uint8List, Uint8List> encryptedPin,
  }) async {
    final String initializationVector = HEX.encode(encryptedPin.item1);
    final String cipher = HEX.encode(encryptedPin.item2);

    await secureStorageUtil.write(
      key: 'initializationVector',
      value: initializationVector,
    );

    await secureStorageUtil.write(
      key: 'cipher',
      value: cipher,
    );
  }
}
