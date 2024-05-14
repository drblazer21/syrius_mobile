import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class PairingsWidget extends StatelessWidget {
  const PairingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final IWeb3WalletService walletConnectService = sl<IWeb3WalletService>();

    return ValueListenableBuilder(
      valueListenable: walletConnectService.pairings,
      builder: (_, pairings, __) {
        if (pairings.isEmpty) {
          return _buildEmptyState(context: context);
        }
        return _buildList(pairings: pairings);
      },
    );
  }

  Widget _buildEmptyState({required BuildContext context}) {
    return Text(
      AppLocalizations.of(context)!.walletConnectPairingsListEmpty,
      style: context.textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildList({required List<PairingInfo> pairings}) {
    return Expanded(
      child: ListView.separated(
        itemCount: pairings.length,
        itemBuilder: (_, index) => PairingWidget(
          pairingInfo: pairings[index],
        ),
        separatorBuilder: (_, __) => kVerticalSpacer,
      ),
    );
  }
}
