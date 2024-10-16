import 'package:syrius_mobile/widgets/wallet_connect/wc_connection_widget/wc_connection_model.dart';
import 'package:syrius_mobile/widgets/wallet_connect/wc_connection_widget/wc_connection_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class ConnectionWidgetBuilder {
  List<WCConnectionWidget> buildFromRequiredNamespaces(
      Map<String, Namespace> generatedNamespaces,
      ) {
    final List<WCConnectionWidget> views = [];
    for (final key in generatedNamespaces.keys) {
      final namespaces = generatedNamespaces[key]!;
      final chains = NamespaceUtils.getChainsFromAccounts(namespaces.accounts);
      final List<WCConnectionModel> models = [];
      // If the chains property is present, add the chain data to the models
      models.add(
        WCConnectionModel(
          title: 'Chains',
          elements: chains,
        ),
      );
      models.add(
        WCConnectionModel(
          title: 'Methods',
          elements: namespaces.methods,
        ),
      );
      if (namespaces.events.isNotEmpty) {
        models.add(
          WCConnectionModel(
            title: 'Events',
            elements: namespaces.events,
          ),
        );
      }

      views.add(
        WCConnectionWidget(
          title: key,
          info: models,
        ),
      );
    }

    return views;
  }
}
