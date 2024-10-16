import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/global.dart';

class EthActivityBloc extends InfiniteScrollBloc<EthereumTx> {
  @override
  Future<List<EthereumTx>> getData(int pageKey, int pageSize) async {
    return db.ethereumTxsDao.getItems(
      address: kEthSelectedAddress!.hex,
      pageNumber: pageKey,
      itemsPerPage: pageSize,
    );
  }
}
