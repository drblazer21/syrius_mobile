import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:mutex/mutex.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

abstract class WalletFile {
  final String _path;

  static Future<WalletFile> decrypt(String walletPath, String password) async {
    final encrypted = await WalletFile.read(walletPath);
    final walletType =
        encrypted.metadata != null ? encrypted.metadata![walletTypeKey] : null;
    if (walletType == null || walletType == keyStoreWalletType) {
      return await KeyStoreWalletFile.decrypt(walletPath, password);
    } else {
      throw WalletException(
        'Wallet type (${encrypted.metadata![walletTypeKey]}) is not supported',
      );
    }
  }

  static Future<EncryptedFile> read(String walletPath) async {
    final file = File(walletPath);

    final bool fileExists = await file.exists();

    if (!fileExists) {
      throw WalletException('Given wallet path does not exist ($walletPath)');
    }

    final dynamic decodingResult = await compute(
      json.decode,
      file.readAsStringSync(),
    );

    return EncryptedFile.fromJson(
      decodingResult as Map<String, dynamic>,
    );
  }

  static Future<void> write(
    String walletPath,
    String password,
    List<int> data, {
    Map<String, dynamic>? metadata,
  }) async {
    final file = File(walletPath);
    final encrypted =
        await EncryptedFile.encrypt(data, password, metadata: metadata);
    file.writeAsString(json.encode(encrypted), mode: FileMode.writeOnly);
  }

  WalletFile(this._path);

  String get walletPath => _path;

  String get walletType;

  bool get isOpen;

  Future<Wallet> open();

  void close();

  Future<T> access<T>(Future<T> Function(Wallet) accessSection) async {
    final wallet = await open();
    try {
      return await accessSection(wallet);
    } finally {
      close();
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final file = await WalletFile.read(walletPath);
    final decrypted = await file.decrypt(currentPassword);
    await WalletFile.write(
      walletPath,
      newPassword,
      decrypted,
      metadata: file.metadata,
    );
  }
}

class KeyStoreWalletFile extends WalletFile {
  final Mutex _lock = Mutex();
  final String _walletSeed;
  KeyStore? _keyStore;

  static Future<KeyStoreWalletFile> create(
    String mnemonic,
    String password, {
    String? name,
  }) async {
    final KeyStore wallet = await compute(KeyStore.fromMnemonic, mnemonic);

    final KeyStoreManager keyStoreWalletManager = KeyStoreManager(
      walletPath: (await getZnnDefaultWalletDirectory()).absolute,
    );

    name ??= await _generateWalletName(wallet);

    final KeyStoreDefinition walletDefinition =
        await keyStoreWalletManager.saveKeyStore(
      wallet,
      password,
      name: name,
    );
    return KeyStoreWalletFile._internal(
      walletDefinition.walletId,
      wallet.entropy,
    );
  }

  static Future<String> _generateWalletName(KeyStore wallet) async {
    final Address firstAddress = await compute(_generateFirstAddress, wallet);

    return firstAddress.toString();
  }

  static Future<KeyStoreWalletFile> decrypt(
    String walletPath,
    String password,
  ) async {
    final encrypted = await WalletFile.read(walletPath);
    if (encrypted.metadata != null &&
        encrypted.metadata![walletTypeKey] != null &&
        encrypted.metadata![walletTypeKey] != keyStoreWalletType) {
      throw WalletException(
        'Wallet type (${encrypted.metadata![walletTypeKey]}) is not supported',
      );
    }
    final decrypted = await compute(encrypted.decrypt, password);
    return KeyStoreWalletFile._internal(walletPath, HEX.encode(decrypted));
  }

  KeyStoreWalletFile._internal(super._path, this._walletSeed);

  @override
  String get walletType => keyStoreWalletType;

  @override
  bool get isOpen => _lock.isLocked;

  @override
  Future<Wallet> open() async {
    await _lock.acquire();
    try {
      _keyStore ??= await compute(KeyStore.fromEntropy, _walletSeed);
      return _keyStore!;
    } catch (_) {
      _lock.release();
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    if (_lock.isLocked) _lock.release();
  }

  static Future<Address> _generateFirstAddress(KeyStore keyStore) async {
    final KeyPair keyPair = await compute(
      (index) => keyStore.getKeyPair(index),
      0,
    );

    final Address address = await compute(
      (_) => keyPair.getAddress(),
      '',
    );

    return address;
  }
}
