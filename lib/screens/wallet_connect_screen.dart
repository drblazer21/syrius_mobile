import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  State<WalletConnectScreen> createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
  final TextEditingController _uriController = TextEditingController();
  final FocusNode _uriFocusNode = FocusNode();

  final WalletConnectPairingBloc _walletConnectPairingBloc =
      WalletConnectPairingBloc();

  @override
  void initState() {
    super.initState();
    _handleWalletConnectPairingBlocUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.walletConnectTitle,
      withLateralPadding: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: _buildPageDescription(context),
          ),
          Padding(
            padding: context.listTileTheme.contentPadding!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WalletConnectUriField(
                  uriController: _uriController,
                  uriFocusNode: _uriFocusNode,
                ),
                ValueListenableBuilder(
                  valueListenable: _uriController,
                  builder: (_, uri, __) {
                    return PairWithDAppButton(
                      onPressed: canParseWalletConnectUri(uri.text)
                          ? () {
                              _pairWithDApp(_uriController.text);
                            }
                          : null,
                    );
                  },
                ),
                _buildScanQrCodeButton(context),
              ].addSeparator(kVerticalSpacer),
            ),
          ),
          const PairingsWidget(),
        ].addSeparator(kVerticalSpacer),
      ),
    );
  }

  @override
  void dispose() {
    _uriController.dispose();
    _uriFocusNode.dispose();
    _walletConnectPairingBloc.dispose();
    super.dispose();
  }

  Widget _buildPageDescription(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.walletConnectScreenDescription,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildScanQrCodeButton(BuildContext context) {
    return SyriusFilledButton(
      text: AppLocalizations.of(context)!.walletConnectScanQR,
      onPressed: () async {
        await showWalletConnectCodeScanner(
          context: context,
          onScan: _pairWithDApp,
        );
      },
    );
  }

  void _pairWithDApp(String uri) {
    _walletConnectPairingBloc.pair(uri);
  }

  void _handleWalletConnectPairingBlocUpdates() {
    _walletConnectPairingBloc.stream.listen(
      (event) {
        if (event == null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const SyriusLoadingWidget(),
          );
        } else {
          Navigator.pop(context);
        }
      },
      onError: (error) {
        Navigator.pop(context);
        sendNotificationError(
          AppLocalizations.of(context)!.walletConnectPairingFailure,
          error,
        );
      },
    );
  }
}
