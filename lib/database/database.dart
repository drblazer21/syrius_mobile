import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:syrius_mobile/database/app_network_asset_entries.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/database/wallet_notifications_dao.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/constants.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    AppAddresses,
    AppNetworks,
    Bookmarks,
    EthereumTxs,
    NetworkAssets,
    WalletNotifications,
  ],
  daos: [
    AppAddressesDao,
    AppNetworksDao,
    BookmarksDao,
    EthereumTxsDao,
    NetworkAssetsDao,
    WalletNotificationsDao,
  ],
)
class Database extends _$Database {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/getting-started/#open
  Database() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    // `driftDatabase` from `package:drift_flutter` stores the database in
    // `getApplicationDocumentsDirectory()`.
    return driftDatabase(name: kDatabaseName);
  }
}
