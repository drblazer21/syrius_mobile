import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/shape_toggle_widget.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({super.key});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  List<Color> get _primaryColors => kSelectedAppNetworkWithAssets!
      .network.blockChain.animateGradientPrimaryColors;

  List<Color> get _secondaryColors => kSelectedAppNetworkWithAssets!
      .network.blockChain.animateGradientSecondaryColors;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: AnimateGradient(
        duration: const Duration(seconds: 10),
        primaryEnd: Alignment.bottomLeft,
        secondaryBegin: Alignment.bottomRight,
        secondaryEnd: Alignment.topRight,
        primaryColors: _primaryColors,
        secondaryColors: _secondaryColors,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Positioned(
              right: 20.0,
              top: 25.0,
              child: Stack(
                children: [
                  ShapeToggleWidget(
                    viewBoxWidth: 256.0,
                    viewBoxHeight: 256.0,
                    svgPath: getSvgImagePath('star_card'),
                    pathData:
                        'M105.92,205.52l13.22,40.9c2,6.19,10.76,6.19,12.76,0l13.22-40.9c4.54-14.13,12.4-27,22.92-37.48,10.51-10.49,23.35-18.34,37.48-22.92l40.88-13.22c6.19-2,6.19-10.76,0-12.76l-40.88-13.22c-14.13-4.54-27-12.4-37.48-22.92-10.49-10.51-18.34-23.35-22.92-37.48l-13.22-40.88c-2-6.19-10.76-6.19-12.76,0l-13.22,40.9c-4.54,14.13-12.4,27-22.92,37.48-10.51,10.51-23.35,18.34-37.48,22.92l-40.88,13.2c-6.19,2-6.19,10.76,0,12.76l40.9,13.22c28.64,9.23,51.09,31.71,60.37,60.4Z',
                    width: 90.0,
                    height: 90.0,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                top: 15.0,
                right: 10.0,
                bottom: 15.0,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BalanceAndAddressWidget(),
                  kVerticalSpacer,
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: DashboardNavigationContainer(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardNavigationContainer extends StatelessWidget {
  const DashboardNavigationContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (BlockChain.nom.isSelected)
          DashboardNavigationButton(
            onClick: () {
              showPlasmaFusingScreen(context);
            },
            iconData: Icons.flash_on,
            text: AppLocalizations.of(context)!.fuse,
          ),
        DashboardNavigationButton(
          onClick: () {
            switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
              case BlockChain.btc:
                showSendBtcScreen(context: context);
              case BlockChain.evm:
                showSendEthScreen(context: context);
              case BlockChain.nom:
                showSendScreen(context: context);
            }
          },
          iconData: Icons.arrow_upward_sharp,
          text: AppLocalizations.of(context)!.send,
        ),
        DashboardNavigationButton(
          onClick: () {
            showModalBottomSheetWithBody(
              context: context,
              body: const ReceiveModalBottomSheet(),
            );
          },
          iconData: Icons.arrow_downward_sharp,
          text: AppLocalizations.of(context)!.receiveButton,
        ),
      ],
    );
  }

  // TODO: to be used in a future release
  DashboardNavigationButton _buildBuyButton(BuildContext context) {
    return DashboardNavigationButton(
      onClick: () {
        showBuyScreen(context);
      },
      iconData: Icons.wallet,
      text: AppLocalizations.of(context)!.buy,
    );
  }
}

class DashboardNavigationButton extends StatelessWidget {
  final VoidCallback onClick;
  final IconData iconData;
  final String text;

  const DashboardNavigationButton({
    super.key,
    required this.onClick,
    required this.iconData,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onClick,
          icon: Icon(
            iconData,
            color: context.colorScheme.surface,
            size: 20,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white54,
          ),
        ),
        Text(
          text,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class ReceiveModalBottomSheet extends StatelessWidget {
  const ReceiveModalBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ReceiveQrImage(
            data: selectedAddress.hex,
            size: 180.0,
            token: kZnnCoin,
            context: context,
          ),
        ),
        WarningWidget(
          iconData: Icons.info,
          fillColor: context.colorScheme.primaryContainer,
          textColor: context.colorScheme.onPrimaryContainer,
          text: AppLocalizations.of(context)!.receiveModalWarning,
        ),
        Container(
          padding: const EdgeInsets.only(
            left: 15.0,
            top: 15.0,
            bottom: 15.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: context.colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedAddress.hex,
                  style: context.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),
              CopyToClipboardButton(
                text: selectedAddress.hex,
              ),
            ],
          ),
        ),
        FilledButton.icon(
          icon: const Icon(
            Icons.share,
          ),
          label: Text(AppLocalizations.of(context)!.shareAddress),
          onPressed: () async {
            await Share.share(selectedAddress.hex);
          },
        ),
      ].addSeparator(kVerticalSpacer),
    );
  }
}
