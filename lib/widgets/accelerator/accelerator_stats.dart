import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/accelerator/accelerator.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AcceleratorStats extends StatefulWidget {
  const AcceleratorStats({super.key});

  @override
  State<AcceleratorStats> createState() => _AcceleratorStatsState();
}

class _AcceleratorStatsState extends State<AcceleratorStats> {
  String? _touchedSectionTitle;

  final AcceleratorBalanceBloc _acceleratorBalanceBloc = AcceleratorBalanceBloc();

  @override
  void initState() {
    super.initState();
    _acceleratorBalanceBloc.getAcceleratorBalance();
  }


  @override
  void dispose() {
    _acceleratorBalanceBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.acceleratorStats,
      child: RefreshIndicator.adaptive(
        onRefresh: _acceleratorBalanceBloc.getAcceleratorBalance,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _getWidgetBodyFutureBuilder(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getWidgetBodyFutureBuilder(BuildContext context) {
    return StreamBuilder<AccountInfo?>(
      stream: _acceleratorBalanceBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return _getWidgetBody(context, snapshot.data!);
          }
          return const SyriusLoadingWidget();
        }
        return const SyriusLoadingWidget();
      },
    );
  }

  Widget _getWidgetBody(BuildContext context, AccountInfo accountInfo) {
    return Row(
      children: [
        Expanded(child: _getPieChart(accountInfo)),
        Expanded(child: _getPieChartLegend(context, accountInfo)),
      ],
    );
  }

  Widget _getPieChartLegend(BuildContext context, AccountInfo accountInfo) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChartLegend(
          dotColor: znnColor,
          mainText: 'Available',
          detailsWidget: FormattedAmountWithTooltip(
            amount: accountInfo
                .getBalance(
                  kZnnCoin.tokenStandard,
                )
                .toStringWithDecimals(coinDecimals),
            tokenSymbol: kZnnCoin.symbol,
            builder: (amount, tokenSymbol) => Text(
              '$amount $tokenSymbol',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        kVerticalSpacer,
        ChartLegend(
          dotColor: qsrColor,
          mainText: 'Available',
          detailsWidget: FormattedAmountWithTooltip(
            amount: accountInfo
                .getBalance(
                  kQsrCoin.tokenStandard,
                )
                .toStringWithDecimals(kQsrCoin.decimals),
            tokenSymbol: kQsrCoin.symbol,
            builder: (amount, tokenSymbol) => Text(
              '$amount $tokenSymbol',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getPieChart(AccountInfo accountInfo) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: StandardPieChart(
        sections: showingSections(accountInfo),
        centerSpaceRadius: 0.0,
        sectionsSpace: 4.0,
        onChartSectionTouched: (pieTouchedSection) {
          setState(() {
            _touchedSectionTitle = pieTouchedSection?.touchedSection?.title;
          });
        },
      ),
    );
  }

  List<PieChartSectionData> showingSections(AccountInfo accountInfo) {
    return [
      if (accountInfo.findTokenByTokenStandard(kZnnCoin.tokenStandard) != null)
        _getPieCharSectionsData(kZnnCoin, accountInfo),
      if (accountInfo.findTokenByTokenStandard(kQsrCoin.tokenStandard) != null)
        _getPieCharSectionsData(kQsrCoin, accountInfo),
    ];
  }

  PieChartSectionData _getPieCharSectionsData(
    Token token,
    AccountInfo accountInfo,
  ) {
    final BigInt value = token.tokenStandard == kZnnCoin.tokenStandard
        ? accountInfo.znn()!
        : accountInfo.qsr()!;
    final BigInt sumValues = accountInfo.znn()! + accountInfo.qsr()!;

    final isTouched = token.symbol == _touchedSectionTitle;
    final double opacity = isTouched ? 1.0 : 0.5;

    return PieChartSectionData(
      color: getTokenColor(token).withOpacity(opacity),
      value: value / sumValues,
      title: accountInfo.findTokenByTokenStandard(token.tokenStandard)!.symbol,
      radius: 60.0,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
