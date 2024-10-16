import 'package:drift/drift.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/database/tables.dart';

part 'network_assets_dao.g.dart';

@DriftAccessor(tables: [NetworkAssets])
class NetworkAssetsDao extends DatabaseAccessor<Database>
    with _$NetworkAssetsDaoMixin {
  NetworkAssetsDao(super.db);

  Future<List<NetworkAsset>> getAllByNetworkId(int id) async {
    return (select(networkAssets)..where((f) => f.network.equals(id))).get();
  }

  Future<int> insert(NetworkAssetsCompanion asset) async {
    final NetworkAssetsCompanion updatedAppAddress = _generateNetworkAssetWithCurrency(asset);

    return into(networkAssets).insert(updatedAppAddress);
  }
  
  Future<void> insertMultiple(List<NetworkAssetsCompanion> assets) async {
    return await batch((batch) {
      batch.insertAll(networkAssets, assets);
    });
  }

  Future<bool> updateData(NetworkAssetsCompanion asset) async {
    final NetworkAssetsCompanion updatedAppAddress = _generateNetworkAssetWithCurrency(asset);

    return update(networkAssets).replace(updatedAppAddress);
  }

  NetworkAssetsCompanion _generateNetworkAssetWithCurrency(
    NetworkAssetsCompanion asset,
  ) {
    final bool isCurrency = asset.contractAddressHex.value == null;

    return asset.copyWith(
      isCurrency: Value(isCurrency),
    );
  }
}
