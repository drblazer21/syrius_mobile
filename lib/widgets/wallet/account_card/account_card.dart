import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/shape_toggle_widget.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({super.key});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  void initState() {
    super.initState();
    sl.get<BalanceBloc>().getForAllAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: AnimateGradient(
        duration: const Duration(seconds: 10),
        primaryEnd: Alignment.bottomLeft,
        secondaryBegin: Alignment.bottomRight,
        secondaryEnd: Alignment.topRight,
        primaryColors: const [
          Color.fromARGB(255, 2, 46, 16),
          Color.fromARGB(255, 11, 206, 60),
          Color.fromARGB(255, 70, 235, 111),
        ],
        secondaryColors: const [
          Color.fromARGB(255, 6, 21, 140),
          Color.fromARGB(255, 10, 90, 195),
          Color.fromARGB(255, 24, 231, 217),
        ],
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
                left: 25.0,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BalanceAndAddressWidgetZenonTools(),
                  kVerticalSpacer,
                  DashboardNavigationContainer(),
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
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (kSelectedNetwork == AppNetwork.znn)
                DashboardNavigationButton(
                  onClick: () {
                    showPlasmaFusingScreen(context);
                  },
                  icon: Icon(
                    Icons.flash_on,
                    color: context.colorScheme.background,
                    size: 20,
                  ),
                  text: AppLocalizations.of(context)!.fuse,
                ),
              DashboardNavigationButton(
                onClick: () {
                  showSendScreen(context: context);
                },
                icon: Icon(
                  Icons.arrow_upward_sharp,
                  color: context.colorScheme.background,
                  size: 20,
                ),
                text: AppLocalizations.of(context)!.send,
              ),
              DashboardNavigationButton(
                onClick: () {
                  showModalBottomSheetWithBody(
                    context: context,
                    body: const ReceiveModalBottomSheet(),
                  );
                },
                icon: Icon(
                  Icons.arrow_downward_sharp,
                  color: context.colorScheme.background,
                  size: 20,
                ),
                text: AppLocalizations.of(context)!.receiveButton,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }
}

class DashboardNavigationButton extends StatelessWidget {
  final VoidCallback onClick;
  final Icon icon;
  final String text;

  const DashboardNavigationButton({
    super.key,
    required this.onClick,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onClick,
          icon: icon,
          style: IconButton.styleFrom(
            backgroundColor: context.colorScheme.secondary,
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
            data: getAddress(),
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
          padding: const EdgeInsets.only(left: 15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: context.colorScheme.surfaceVariant,
          ),
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  getAddress(),
                  style: context.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CopyToClipboardButton(
                text: getAddress(),
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
            await Share.share(getAddress());
          },
        ),
      ].addSeparator(kVerticalSpacer),
    );
  }
}
