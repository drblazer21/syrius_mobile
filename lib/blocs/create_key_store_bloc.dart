import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:argon2_ffi_base/argon2_ffi_base.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/utils/wallet/wallet_file.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class CreateKeyStoreBloc extends BaseBloc<String?> {
  Future<void> createAndDoInit({
    required BuildContext context,
    required String pin,
  }) async {
    try {
      await _createKeyStoreAndSavePin(
        mnemonic: await getMnemonic(),
        pin: pin,
      );
      await initWalletAfterDecrypt();

      // Overwrite pin
      pin = '' * pin.length;
      addEvent("Done");
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _createKeyStoreAndSavePin({
    required String? mnemonic,
    required String pin,
  }) async {
    // Generate random keyStore password
    final keyStorePassword = await _generateRandomKeyStorePassword();

    // Check if mnemonic is null
    if (mnemonic != null) {
      await KeyStoreWalletFile.create(mnemonic, keyStorePassword);
    } else {
      final String mnemonic = await compute(
        Mnemonic.generateMnemonic,
        128,
      );
      await KeyStoreWalletFile.create(
        mnemonic,
        keyStorePassword,
      );
    }

    final WalletFile walletFile = await WalletFile.decrypt(
      File(
        KeyStoreManager(
          walletPath: (await getZnnDefaultWalletDirectory()).absolute,
        ).walletPath.listSync().first.path,
      ).path,
      keyStorePassword,
    );
    await walletFile.open().then((wallet) async {
      // Set kKeyStore as wallet
      await saveEntropy((wallet as KeyStore).entropy);
    });

    final secretBox = await _encryptKeyStorePasswordWithUserPIN(
      keyStorePassword: keyStorePassword,
      pin: pin,
    );

    await _saveEncryptedKeyStorePassword(secretBox: secretBox);
  }

  Future<String> _generateRandomKeyStorePassword() async {
    final SecretKeyData secretKeyData = await compute(
      (length) => SecretKeyData.random(length: length).extract(),
      16,
    );

    return HEX.encode(secretKeyData.bytes);
  }

  Future<SecretBox> _encryptKeyStorePasswordWithUserPIN({
    required String keyStorePassword,
    required String pin,
  }) async {
    final salt_1 = await SecretKeyData.random(length: 16).extract();
    final salt = Uint8List.fromList(salt_1.bytes);

    final String encodedSalt = HEX.encode(salt);

    await secureStorageUtil.write(key: 'salt', value: encodedSalt);

    final nonce_1 = await SecretKeyData.random(length: 12).extract();
    final nonce = Uint8List.fromList(nonce_1.bytes);
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
    final encryptedKeyStorePassword = await compute(
      (message) => algorithm.encrypt(
        message,
        secretKey: SecretKey(key),
        nonce: nonce,
        aad: utf8.encode('zenon'),
      ),
      HEX.decode(keyStorePassword),
    );

    return encryptedKeyStorePassword;
  }

  Future<void> _saveEncryptedKeyStorePassword({
    required SecretBox secretBox,
  }) {
    final String encodedSecretBox = HEX.encode(
      secretBox.concatenation(),
    );

    return secureStorageUtil.write(
      key: 'secretBox',
      value: encodedSecretBox,
    );
  }
}
