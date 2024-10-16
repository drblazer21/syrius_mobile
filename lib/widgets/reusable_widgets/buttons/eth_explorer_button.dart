import 'package:syrius_mobile/utils/global.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/buttons/explorer_button.dart';

class EthExplorerButton extends ExplorerButton {
  EthExplorerButton({
    required String hash,
    super.iconColor,
  }): super(
    url: '${Uri.parse(kSelectedAppNetworkWithAssets!.network.blockExplorerUrl).resolve(hash)}',
  );
}
