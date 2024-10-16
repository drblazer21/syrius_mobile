import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/database/tables.dart';
import 'package:syrius_mobile/model/database/database.dart';
import 'package:syrius_mobile/utils/global.dart';
import 'package:web3dart/web3dart.dart';

part 'ethereum_txs_dao.g.dart';

@DriftAccessor(tables: [EthereumTxs])
class EthereumTxsDao extends DatabaseAccessor<Database>
    with _$EthereumTxsDaoMixin {
  EthereumTxsDao(super.db);

  Future<List<EthereumTx>> getItems({
    required String address,
    required int pageNumber,
    required int itemsPerPage,
  }) async {
    final offset = pageNumber * itemsPerPage;
    final int networkId = kSelectedAppNetworkWithAssets!.network.id;
    return (select(ethereumTxs)
          ..where(
            (f) =>
                f.network.equals(networkId) &
                Expression.or(
                  [f.from.equals(address), f.to.equals(address)],
                ),
          )
          ..orderBy([
            (f) => OrderingTerm(
                  expression: f.txDateTime,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(itemsPerPage, offset: offset))
        .get();
  }

  Future<int> insert({
    required TransactionInformation info,
    required DateTime dateTime,
    required EthereumTransactionStatus status,
  }) async {
    final EthereumTxsCompanion ethereumTxsCompanion =
        EthereumTxsCompanion.insert(
      from: info.from.hex,
      gas: info.gas,
      hash: info.hash,
      input: base64Encode(info.input),
      network: kSelectedAppNetworkWithAssets!.network.id,
      status: status,
      to: Value(info.to?.hex),
      txDateTime: dateTime,
      value: info.value.getInWei,
    );

    return into(ethereumTxs).insert(ethereumTxsCompanion);
  }
}
