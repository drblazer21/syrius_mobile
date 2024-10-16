import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class ManageAddressesScreen extends StatefulWidget {
  const ManageAddressesScreen({super.key});

  @override
  State<ManageAddressesScreen> createState() => _ManageAddressesScreenState();
}

class _ManageAddressesScreenState extends State<ManageAddressesScreen> {
  @override
  Widget build(BuildContext context) {
    final BlockChain blockChain =
        kSelectedAppNetworkWithAssets!.network.blockChain;
    // We discard the network type for addresses that are not for BTC
    final NetworkType? networkType = BlockChain.btc.isSelected
        ? kSelectedAppNetworkWithAssets!.network.type
        : null;

    final String appbarTitle =
        AppLocalizations.of(context)!.manageAddressesTitle;

    final Widget? appbarTitleWidget = BlockChain.btc.isSelected
        ? Column(
            children: [
              Text(AppLocalizations.of(context)!.manageAddressesTitle),
              Text(
                networkType == NetworkType.testnet
                    ? 'Segwit Testnet (BIP84)'
                    : 'Taproot (BIP 86)',
                style: context.textTheme.titleSmall,
              ),
            ],
          )
        : null;
    return CustomAppbarScreen(
      appbarTitle: appbarTitleWidget == null ? appbarTitle : null,
      appbarTitleWidget: appbarTitleWidget,
      floatingActionButton: FloatingActionButton(
        onPressed: _generateNewAddress,
        child: const Icon(Icons.add),
      ),
      withLateralPadding: false,
      child: StreamBuilder<List<AppAddress>>(
        stream: db.appAddressesDao.watch(
          blockChain: blockChain,
          networkType: networkType,
        ),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final List<AppAddress> appAddresses = snapshot.data!;

            final addressesCards = _buildCards(addresses: appAddresses);

            return _buildListView(addressesCards);
          } else if (snapshot.hasError) {
            return SyriusErrorWidget(snapshot.error.toString());
          }
          return const SyriusLoadingWidget();
        },
      ),
    );
  }

  ListView _buildListView(List<Widget> addressesCards) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      children: addressesCards,
    );
  }

  Future<void> _generateNewAddress() async {
    showLoadingDialog(context);
    await generateNewAddress();
    if (mounted) {
      Navigator.pop(context);
    }
    setState(() {});
  }

  List<Widget> _buildCards({required List<AppAddress> addresses}) => addresses
      .map(
        (address) => ManageAddressesCard(
          address: address,
          onPressed: _changeDefaultAddress,
          onChangedLabel: () {
            setState(() {});
          },
        ),
      )
      .toList();

  Future<void> _changeDefaultAddress(AppAddress newDefaultAddress) async {
    try {
      await sharedPrefs.setInt(defaultAddressKey, newDefaultAddress.id);
      if (!mounted) return;
      Provider.of<SelectedAddressNotifier>(
        context,
        listen: false,
      ).changeAddress(newDefaultAddress);
      setState(() {});
    } catch (e, stackTrace) {
      Logger('ManageAddressesScreen')
          .log(Level.SEVERE, '_changeDefaultAddress', e, stackTrace);
      rethrow;
    }
  }
}
