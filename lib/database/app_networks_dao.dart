import 'package:drift/drift.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/database/tables.dart';

part 'app_networks_dao.g.dart';

@DriftAccessor(tables: [AppNetworks])
class AppNetworksDao extends DatabaseAccessor<Database>
    with _$AppNetworksDaoMixin {
  AppNetworksDao(super.db);

  Future<int> deleteData(Insertable<AppNetwork> network) =>
      delete(appNetworks).delete(network);

  Future<int> insert(AppNetworksCompanion network) async {
    return into(appNetworks).insert(network);
  }

  Future<void> insertMultiple(List<AppNetworksCompanion> networks) {
    return batch((batch) {
      batch.insertAll(appNetworks, networks);
    });
  }

  Future<bool> updateData(Insertable<AppNetwork> network) async {
    return update(appNetworks).replace(network);
  }

  Future<int> upsert(Insertable<AppNetwork> network) =>
      into(appNetworks).insertOnConflictUpdate(network);
}
