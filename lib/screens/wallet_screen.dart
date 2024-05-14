import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/notifiers/backed_up_seed_notifier.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late NotificationsProvider _getNotificationProvider;

  final TextEditingController _chainIdController = TextEditingController();
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();

  String get _chainId => _chainIdController.text;

  @override
  void initState() {
    super.initState();
    _getNotificationProvider = context.read<NotificationsProvider>();
    _getNotificationProvider.getNotificationsFromDb();
    sl.get<ZenonToolsPriceBloc>().getPrice();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      leadingWidth: double.infinity,
      leadingWidget: Consumer<SelectedAddressNotifier>(
        builder: (_, __, ___) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddressLabel(context),
                  _buildChainIdDropdown(context),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: kMinInteractiveDimension),
                child: _getGenerationStatus(),
              ),
            ],
          );
        },
      ),
      withLateralPadding: false,
      withBottomPadding: false,
      actionWidget: notificationsIcon(
        context,
      ),
      child: Column(
        children: [
          Padding(
            padding: context.listTileTheme.contentPadding!,
            child: Consumer<SelectedAddressNotifier>(
              builder: (_, __, ___) {
                return AccountCard(
                  key: UniqueKey(),
                );
              },
            ),
          ),
          kVerticalSpacer,
          Consumer<BackedUpSeedNotifier>(
            builder: (_, notifier, __) {
              return Visibility(
                visible: !notifier.isBackedUp,
                child: Padding(
                  padding: context.listTileTheme.contentPadding!.add(
                    EdgeInsets.only(
                      bottom:
                          !notifier.isBackedUp ? kVerticalSpacer.height! : 0.0,
                    ),
                  ),
                  child: BackupWarning(),
                ),
              );
            },
          ),
          const Expanded(
            child: AssetsZenonTools(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chainIdController.dispose();
    _getNotificationProvider.dispose();
    super.dispose();
  }

  Widget _buildChainIdDropdown(BuildContext context) {
    final Text child = Text(
      'Chain ID',
      style: TextStyle(
        color: context.colorScheme.primary,
      ),
    );

    void onTap() {
      showLoadingDialog(context);
      getChainId().then(
        (chainId) {
          Navigator.pop(context);
          showModalBottomSheetWithBody(
            context: context,
            title: AppLocalizations.of(context)!.chainIdentifier,
            body: _buildChangeNodeIdDialog(currentChainId: chainId),
          );
        },
      );
    }

    return _buildLeadingWidgetTextButton(
      context: context,
      child: child,
      onTap: onTap,
    );
  }

  Widget _buildAddressLabel(BuildContext context) {
    final Text child = Text(
      kAddressLabelMap[getAddress()]!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    void onTap() {
      showManageAddressScreen(context);
    }

    return _buildLeadingWidgetTextButton(
      context: context,
      child: child,
      onTap: onTap,
    );
  }

  TextButton _buildLeadingWidgetTextButton({
    required BuildContext context,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: context.colorScheme.onBackground,
        minimumSize: const Size(30.0, 15.0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
      ),
      onPressed: onTap,
      child: child,
    );
  }

  Widget _buildChangeNodeIdDialog({
    required int currentChainId,
  }) {
    final String suffix = currentChainId == 1 ? ' - Alphanet' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Current chain ID: $currentChainId$suffix',
        ),
        TextField(
          controller: _chainIdController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            errorText: chainIdValidator(_chainId),
            hintText: AppLocalizations.of(context)!.chainIdentifier,
          ),
          onChanged: (String? value) {
            setState(() {});
          },
        ),
        ValueListenableBuilder(
          valueListenable: _chainIdController,
          builder: (_, __, ___) {
            return FilledButton(
              onPressed: _isInputValid()
                  ? () {
                      saveChainId(_chainId);
                      chainId = int.parse(_chainId);
                      _chainIdController.clear();
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(
                AppLocalizations.of(context)!.save,
              ),
            );
          },
        ),
      ].addSeparator(kVerticalSpacer),
    );
  }

  bool _isInputValid() =>
      chainIdValidator(_chainIdController.text) == null &&
      _chainIdController.text.isNotEmpty;

  Widget _getGenerationStatus() {
    return StreamBuilder<PowStatus>(
      stream: sl.get<PowGeneratingStatusBloc>().stream,
      builder: (_, snapshot) {
        if (snapshot.hasData && snapshot.data == PowStatus.generating) {
          return Tooltip(
            message: AppLocalizations.of(context)!.generatingPlasma,
            child: const SyriusLoadingWidget(
              size: 20.0,
              strokeWidth: 2.0,
            ),
          );
        }
        return Tooltip(
          message: AppLocalizations.of(context)!.plasmaGenerationIdle,
          child: const Icon(
            Icons.flash_on,
          ),
        );
      },
    );
  }
}
