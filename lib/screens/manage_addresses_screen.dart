import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/main.dart';
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
    final addressesCards = _buildCards();

    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.manageAddressesTitle,
      floatingActionButton: FloatingActionButton(
        onPressed: _generateNewAddress,
        child: const Icon(Icons.add),
      ),
      withLateralPadding: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: addressesCards,
      ),
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

  List<Widget> _buildCards() => kDefaultAddressList
      .map(
        (address) => ManageAddressesCard(
          address: address,
          onPressed: _changeDefaultAddress,
        ),
      )
      .toList();

  Future<void> _changeDefaultAddress(String newDefaultAddress) async {
    try {
      final Box box = Hive.box(kSharedPrefsBox);
      await box.put(kDefaultAddressKey, newDefaultAddress);
      if (!mounted) return;
      Provider.of<SelectedAddressNotifier>(
        context,
        listen: false,
      ).changeAddress(newDefaultAddress);
      setState(() {});
      zenon.defaultKeyPair = await getKeyPairFromAddress(newDefaultAddress);
    } catch (e, stackTrace) {
      Logger('ManageAddressesScreen')
          .log(Level.SEVERE, '_changeDefaultAddress', e, stackTrace);
      rethrow;
    }
  }
}
