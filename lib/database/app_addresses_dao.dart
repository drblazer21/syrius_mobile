import 'package:drift/drift.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/database/tables.dart';
import 'package:syrius_mobile/model/model.dart';

part 'app_addresses_dao.g.dart';

@DriftAccessor(tables: [AppAddresses])
class AppAddressesDao extends DatabaseAccessor<Database>
    with _$AppAddressesDaoMixin {
  AppAddressesDao(super.db);

  Future<int> insert(AppAddressesCompanion appAddress) async {
    return into(appAddresses).insert(appAddress);
  }

  Future<void> insertMultiple(List<Insertable<AppAddress>> rows) {
    return batch((batch) {
      batch.insertAll(appAddresses, rows);
    });
  }

  Future<bool> updateData(Insertable<AppAddress> appAddress) async {
    return update(appAddresses).replace(appAddress);
  }

  Stream<List<AppAddress>> watch({
    required BlockChain blockChain,
    required NetworkType? networkType,
  }) {
    return _filter(blockChain, networkType).watch();
  }

  Future<List<AppAddress>> filter({
    required BlockChain blockChain,
    required NetworkType? networkType,
  }) {
    return _filter(blockChain, networkType).get();
  }

  SimpleSelectStatement<$AppAddressesTable, AppAddress> _filter(
      BlockChain blockChain,
      NetworkType? networkType,
      ) {
    return select(appAddresses)
      ..where(
            (f) =>
        f.blockChain.equals(blockChain.index) &
        (blockChain != BlockChain.btc
            ? f.bitcoinNetVersion.isNull()
            : f.bitcoinNetVersion.equals(networkType!.index)),
      );
  }
}
