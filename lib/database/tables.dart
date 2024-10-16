import 'package:drift/drift.dart';
import 'package:syrius_mobile/database/app_network_asset_entries.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/constants.dart';

@DataClassName('AppAddress')
class AppAddresses extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get index => integer()();

  IntColumn get blockChain => intEnum<BlockChain>()();

  TextColumn get hex => text().unique().withLength(max: kAddressHexMaxLength)();

  TextColumn get label => text().withLength(max: kAddressLabelMaxLength)();

  /// Matters only Bitcoin, because Bitcoin testnet addresses differ from
  /// Bitcoin mainnet addresses
  ///
  /// 0 - mainnet
  /// 1 - testnet
  IntColumn get bitcoinNetVersion => integer().nullable()();
}

class AppNetworks extends Table {
  TextColumn get assets => text().map(AppNetworkAssetEntries.converter)();

  IntColumn get id => integer().autoIncrement()();

  IntColumn get blockChain => intEnum<BlockChain>()();

  TextColumn get blockExplorerUrl => text()();

  IntColumn get chainId => integer().nullable()();

  TextColumn get currencySymbol => text()();

  TextColumn get name => text().unique()();

  TextColumn get url => text()();

  IntColumn get type => intEnum<NetworkType>()();
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get faviconUrl => text().nullable()();

  TextColumn get title => text()();

  TextColumn get url => text()();
}

class EthereumTxs extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get from => text().withLength(max: kAddressHexMaxLength)();

  IntColumn get gas => integer()();

  TextColumn get hash => text()();

  TextColumn get input => text()();

  IntColumn get network => integer().references(AppNetworks, #id)();

  TextColumn get to =>
      text().nullable().withLength(max: kAddressHexMaxLength)();

  Int64Column get value => int64()();

  DateTimeColumn get txDateTime => dateTime()();

  IntColumn get status => intEnum<EthereumTransactionStatus>()();
}

class NetworkAssets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get contractAddressHex =>
      text().nullable().unique().withLength(max: kAddressHexMaxLength)();

  IntColumn get decimals => integer()();

  TextColumn get logoUrl => text().nullable()();

  TextColumn get name => text().nullable()();

  IntColumn get network => integer().references(AppNetworks, #id)();

  TextColumn get symbol => text()();

  BoolColumn get isCurrency => boolean()();
}

class WalletNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  TextColumn get title => text()();

  TextColumn get details => text()();

  IntColumn get type => intEnum<NotificationType>()();

  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}
