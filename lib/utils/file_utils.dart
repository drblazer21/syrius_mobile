import 'dart:io';

import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/constants.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

mixin FileUtils {
  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      } else {
        throw 'There is no file at the following path: $path';
      }
    } catch (e, stackTrace) {
      Logger('FileUtils').log(Level.SEVERE, 'deleteFile', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> deleteDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      } else {
        throw 'There is no directory at the following path: $path';
      }
    } catch (e, stackTrace) {
      Logger('FileUtils').log(Level.SEVERE, 'deleteDirectory', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> deleteZnnDefaultWalletDirectory() async {
    final Directory znnDefaultWalletDirectory =
        await getZnnDefaultWalletDirectory();
    if (znnDefaultWalletDirectory.existsSync()) {
      znnDefaultWalletDirectory.deleteSync(recursive: true);
    }
  }

  static Future<void> deleteZnnDefaultCacheDirectory() async {
    final Directory znnDefaultCacheDirectory =
        await getZnnDefaultCacheDirectory();
    if (znnDefaultCacheDirectory.existsSync()) {
      znnDefaultCacheDirectory.deleteSync(recursive: true);
    }
  }

  static Future<void> deleteWallet() async {
    await secureStorageUtil.delete(
      key: kKeyStoreKey,
    );
    await secureStorageUtil.deleteAll();
    await Hive.deleteFromDisk();
    await FileUtils.deleteZnnDefaultCacheDirectory();
    await FileUtils.deleteZnnDefaultWalletDirectory();
    exit(0);
  }
}
