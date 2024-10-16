import 'package:flutter/cupertino.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/global.dart';

class SelectedNetworkNotifier extends ChangeNotifier {
  Future<void> change(AppNetwork newNetwork) async {
    await db.networkAssetsDao.getAllByNetworkId(newNetwork.id).then(
      (assets) {
        kSelectedAppNetworkWithAssets = (
          assets: assets,
          network: newNetwork,
        );
        notifyListeners();
      },
    );
  }
}
