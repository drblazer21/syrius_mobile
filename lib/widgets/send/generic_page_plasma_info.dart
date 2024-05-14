import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class GenericPagePlasmaInfo extends StatefulWidget {
  const GenericPagePlasmaInfo({
    required this.accountInfo,
    super.key,
  });

  final AccountInfo accountInfo;

  @override
  State<GenericPagePlasmaInfo> createState() => _GenericPagePlasmaInfoState();
}

class _GenericPagePlasmaInfoState extends State<GenericPagePlasmaInfo> {
  @override
  void initState() {
    super.initState();
    sl.get<PlasmaStatsBloc>().get();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 11.0,
          vertical: 17.0,
        ),
        child: AppStreamBuilder<List<PlasmaInfoWrapper>>(
          stream: sl.get<PlasmaStatsBloc>().stream,
          builder: (snapshot) {
            return _getBody(
              context,
              _getPlasmaInfoForCurrentAddress(snapshot),
            );
          },
          customErrorWidget: (error) => SyriusErrorWidget(error),
          customLoadingWidget: const SyriusLoadingWidget(),
        ),
      ),
    );
  }

  PlasmaInfoWrapper _getPlasmaInfoForCurrentAddress(
    List<PlasmaInfoWrapper> plasmaInfoWrapperList,
  ) =>
      plasmaInfoWrapperList.firstWhere(
        (plasmaInfoWrapper) => plasmaInfoWrapper.address == kSelectedAddress!,
      );

  Column _getBody(BuildContext context, PlasmaInfoWrapper plasmaInfoWrapper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  _buildAvailablePlasma(context, plasmaInfoWrapper),
                ],
              ),
              Icon(
                Icons.flash_on,
                size: 45.0,
                color: plasmaInfoWrapper.plasmaLevel.color,
              ),
            ],
          ),
        ),
        Visibility(
          visible: !_isPlasmaLevelHigh(plasmaInfoWrapper),
          child: _buildPlasmaWarning(
            context: context,
            plasmaInfoWrapper: plasmaInfoWrapper,
          ),
        ),
        Visibility(
          visible: !_isPlasmaLevelHigh(plasmaInfoWrapper),
          child: _buildButton(context, widget.accountInfo),
        ),
      ],
    );
  }

  bool _isPlasmaLevelHigh(PlasmaInfoWrapper plasmaInfoWrapper) =>
      plasmaInfoWrapper.plasmaLevel == PlasmaLevel.high;

  Widget _buildAvailablePlasma(
    BuildContext context,
    PlasmaInfoWrapper plasmaInfoWrapper,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.plasmaModalTitle,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          '${plasmaInfoWrapper.plasmaInfo.currentPlasma} units',
          style: context.textTheme.bodyMedium
              ?.copyWith(
                color: plasmaInfoWrapper.plasmaLevel.color,
              )
              .copyWith(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildPlasmaWarning({
    required BuildContext context,
    required PlasmaInfoWrapper plasmaInfoWrapper,
  }) {
    final Color plasmaColor = plasmaInfoWrapper.plasmaLevel.color;
    return Padding(
      padding: const EdgeInsets.only(
        top: 15.0,
      ),
      child: WarningWidget(
        iconData: Icons.info,
        fillColor: plasmaColor.withOpacity(0.3),
        textColor: plasmaColor,
        text: AppLocalizations.of(context)!.plasmaModalLowDescription,
      ),
    );
  }

  Widget _buildButton(BuildContext context, AccountInfo accountInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        kVerticalSpacer,
        Stack(
          alignment: Alignment.centerRight,
          fit: StackFit.passthrough,
          children: [
            OutlinedButton(
              onPressed: () {
                showPlasmaFusingScreen(context);
              },
              child: Text(
                '${AppLocalizations.of(context)!.fuse} ${kQsrCoin.symbol}',
              ),
            ),
            Positioned(
              right: 15.0,
              child: Icon(
                Icons.chevron_right_rounded,
                color: context.colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
