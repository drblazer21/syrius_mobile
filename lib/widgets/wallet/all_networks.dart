import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/screens/add_network_screen.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AllNetworks extends StatelessWidget {
  final VoidCallback onNetworkChanged;
  final ScrollController scrollController;

  const AllNetworks({
    required this.onNetworkChanged,
    required this.scrollController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.allNetworks,
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: StreamBuilder<List<AppNetwork>>(
            stream: db.managers.appNetworks.watch(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                final List<AppNetwork> appNetworks = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: appNetworks.length,
                        itemBuilder: (BuildContext context, int index) =>
                            _buildListTile(
                          appNetwork: appNetworks[index],
                          context: context,
                          savedNetworks: appNetworks,
                        ),
                      ),
                    ),
                    Padding(
                      padding: context.listTileTheme.contentPadding!,
                      child: _buildAddNetworkButton(context),
                    ),
                  ].addSeparator(kVerticalSpacer),
                );
              } else if (snapshot.hasError) {
                return SyriusErrorWidget(snapshot.error.toString());
              }
              return const SyriusLoadingWidget();
            },
          ),
        ),
      ].addSeparator(kVerticalSpacer),
    );
  }

  OutlinedButton _buildAddNetworkButton(
    BuildContext context,
  ) {
    return OutlinedButton(
      onPressed: () {
        showAddNetworkScreen(
          context: context,
          mode: AddNetworkScreenMode.add,
        );
      },
      child: Text(
        AppLocalizations.of(context)!.addNetwork,
      ),
    );
  }

  Widget _buildListTile({
    required AppNetwork appNetwork,
    required BuildContext context,
    required List<AppNetwork> savedNetworks,
  }) {
    final bool isSelected =
        kSelectedAppNetworkWithAssets!.network.id == appNetwork.id;

    final BorderRadius borderRadius = BorderRadius.circular(16.0);
    final Color selectedTileColor =
        appNetwork.blockChain.bgColor.withOpacity(0.1);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: appNetwork.blockChain.bgColor,
        child: SvgIcon(
          iconFileName: appNetwork.blockChain.iconFileName,
        ),
      ),
      onTap: () async {
        final PowStatus? lastPowStatus =
            sl.get<PowGeneratingStatusBloc>().lastValue;
        final bool isPowBeingGenerated = lastPowStatus == PowStatus.generating;
        if (!isPowBeingGenerated) {
          if (!context.mounted) return;
          if (kSelectedAppNetworkWithAssets!.network == appNetwork) {
            Navigator.pop(context);
          } else {
            _changeDefaultNetwork(appNetwork, context);
          }
        } else {
          Navigator.pop(context);
          sendNotificationError(
            'PoW is being generated',
            'Please wait until PoW generation finishes '
                'in order to change the default network',
          );
        }
      },
      selected: isSelected,
      selectedTileColor: selectedTileColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      title: Text(
        appNetwork.name,
      ),
      trailing: _buildTrailing(
        appNetwork: appNetwork,
        context: context,
        savedNetworks: savedNetworks,
      ),
    );
  }

  void _changeDefaultNetwork(AppNetwork appNetwork, BuildContext context) {
    final bool isTheSameAsCurrentNetwork =
        kSelectedAppNetworkWithAssets!.network.id == appNetwork.id;

    if (!isTheSameAsCurrentNetwork) {
      sharedPrefs
          .setInt(
        kSelectedAppNetworkIdKey,
        appNetwork.id,
      )
          .then(
        (_) async {
          if (!context.mounted) return;
          switch (appNetwork.blockChain) {
            case BlockChain.btc:
              zenon.wsClient.stop();
              sl.get<GasPriceBloc>().stop();
              eth.dispose();
              await btc.switchNetwork(appNetwork: appNetwork);
              sl.get<BtcEstimateFeeBloc>().start();
            case BlockChain.evm:
              await eth.switchNetwork(appNetwork.url);
              sl.get<BtcEstimateFeeBloc>().stop();
              sl.get<GasPriceBloc>().start();
              zenon.wsClient.stop();
              btc.disconnect();
            case BlockChain.nom:
              chainId = appNetwork.chainId!;
              zenon.wsClient.stop();
              initZnnWebSocketClient(url: appNetwork.url);
              sl.get<GasPriceBloc>().stop();
              sl.get<BtcEstimateFeeBloc>().stop();
              eth.dispose();
              btc.disconnect();
          }
          if (!context.mounted) return;
          await context.read<SelectedNetworkNotifier>().change(appNetwork);
          refreshBlocs();
          if (!context.mounted) return;
          Navigator.pop(context);
          onNetworkChanged.call();
        },
      );
    }
  }

  Widget? _buildTrailing({
    required AppNetwork appNetwork,
    required BuildContext context,
    required List<AppNetwork> savedNetworks,
  }) {
    // The name of the AppNetwork is unique
    final bool isDefaultNetwork =
        kDefaultAppNetworks.map((e) => e.name.value).contains(
              appNetwork.name,
            );

    final bool isCurrentNetwork =
        kSelectedAppNetworkWithAssets!.network.id == appNetwork.id;

    final Widget editButton = IconButton(
      onPressed: isCurrentNetwork
          ? null
          : () {
              showAddNetworkScreen(
                appNetwork: appNetwork,
                context: context,
                mode: AddNetworkScreenMode.edit,
              );
            },
      icon: const Icon(Icons.edit),
    );

    final Widget deleteButton = IconButton(
      onPressed: isCurrentNetwork
          ? null
          : () {
              db.appNetworksDao.deleteData(appNetwork);
            },
      icon: const Icon(Icons.delete_forever_outlined),
    );

    final Widget infoButton = IconButton(
      onPressed: () {
        showAddNetworkScreen(
          appNetwork: appNetwork,
          context: context,
          mode: AddNetworkScreenMode.info,
        );
      },
      icon: const Icon(Icons.info_outline),
    );

    final List<Widget> children = [];
    final double width;

    if (isDefaultNetwork) {
      width = 100.0;
    } else {
      width = 150.0;
      children.add(editButton);
    }

    children.addAll([deleteButton, infoButton]);

    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
