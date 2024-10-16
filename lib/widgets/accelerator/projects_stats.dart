import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class ProjectsStats extends StatelessWidget {
  final Project project;

  const ProjectsStats({
    required this.project,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _getWidgetBody(context);
  }

  Widget _getWidgetBody(BuildContext context) {
    return Column(
      children: [
        AcceleratorProjectDetails(
          owner: project.owner,
          hash: project.id,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 2,
              child: _getChart(_getZnnChartSections(context)),
            ),
            kHorizontalSpacer,
            Expanded(
              flex: 3,
              child: _getProjectStats(_getZnnProjectLegends(context)),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _getChart(_getQsrChartSections(context)),
            ),
            kHorizontalSpacer,
            Expanded(
              flex: 3,
              child: _getProjectStats(_getQsrProjectLegends(context)),
            ),
          ],
        ),
      ].addSeparator(kVerticalSpacer),
    );
  }

  Widget _getChart(List<PieChartSectionData> sections) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 150.0,
        maxHeight: 150.0,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: StandardPieChart(
          sections: sections,
        ),
      ),
    );
  }

  PieChartSectionData _getBalanceChartSection(
    Color color,
    double value,
  ) {
    return PieChartSectionData(
      showTitle: false,
      radius: 7.0,
      color: color,
      value: value,
    );
  }

  List<PieChartSectionData> _getZnnChartSections(BuildContext context) {
    return [
      _getBalanceChartSection(
        znnColor,
        project.znnFundsNeeded == BigInt.zero
            ? 1
            : project.getPaidZnnFunds() / project.znnFundsNeeded,
      ),
      _getBalanceChartSection(
        znnColor.withOpacity(0.2),
        project.znnFundsNeeded == BigInt.zero
            ? 0
            : project.getRemainingZnnFunds() / project.znnFundsNeeded,
      ),
    ];
  }

  List<PieChartSectionData> _getQsrChartSections(BuildContext context) {
    return [
      _getBalanceChartSection(
        qsrColor,
        project.qsrFundsNeeded == BigInt.zero
            ? 1
            : project.getPaidQsrFunds() / project.qsrFundsNeeded,
      ),
      _getBalanceChartSection(
        qsrColor.withOpacity(0.5),
        project.qsrFundsNeeded == BigInt.zero
            ? 0
            : project.getRemainingQsrFunds() / project.qsrFundsNeeded,
      ),
    ];
  }

  Widget _getProjectStats(Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        child,
      ],
    );
  }

  Widget _getZnnProjectLegends(BuildContext context) {
    return SizedBox(
      height: 100.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartLegend(
            dotColor: znnColor,
            mainText: 'Received',
            detailsWidget: FormattedAmountWithTooltip(
              amount:
                  project.getPaidZnnFunds().toStringWithDecimals(coinDecimals),
              tokenSymbol: kZnnCoin.symbol,
              builder: (amount, tokenSymbol) => Text(
                '$amount $tokenSymbol',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          ChartLegend(
            dotColor: znnColor.withOpacity(0.2),
            mainText: 'Remaining',
            detailsWidget: FormattedAmountWithTooltip(
              amount: project
                  .getRemainingZnnFunds()
                  .toStringWithDecimals(coinDecimals),
              tokenSymbol: kZnnCoin.symbol,
              builder: (amount, tokenSymbol) => Text(
                '$amount $tokenSymbol',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          ChartLegend(
            dotColor: znnColor.withOpacity(0.4),
            mainText: 'Total',
            detailsWidget: FormattedAmountWithTooltip(
              amount:
                  project.getTotalZnnFunds().toStringWithDecimals(coinDecimals),
              tokenSymbol: kZnnCoin.symbol,
              builder: (amount, tokenSymbol) => Text(
                '$amount $tokenSymbol',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getQsrProjectLegends(BuildContext context) {
    return SizedBox(
      height: 100.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartLegend(
            dotColor: qsrColor,
            mainText: 'Received',
            detailsWidget: FormattedAmountWithTooltip(
              amount:
                  project.getPaidQsrFunds().toStringWithDecimals(coinDecimals),
              tokenSymbol: kQsrCoin.symbol,
              builder: (amount, tokenSymbol) => Text(
                '$amount $tokenSymbol',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          ChartLegend(
            dotColor: qsrColor.withOpacity(0.2),
            mainText: 'Remaining',
            detailsWidget: FormattedAmountWithTooltip(
              amount: project
                  .getRemainingQsrFunds()
                  .toStringWithDecimals(coinDecimals),
              tokenSymbol: kQsrCoin.symbol,
              builder: (amount, tokenSymbol) => Text(
                '$amount $tokenSymbol',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          ChartLegend(
            dotColor: qsrColor.withOpacity(0.4),
            mainText: 'Total',
            detailsWidget: FormattedAmountWithTooltip(
              amount:
                  project.getTotalQsrFunds().toStringWithDecimals(coinDecimals),
              tokenSymbol: kQsrCoin.symbol,
              builder: (amount, tokenSymbol) => Text(
                '$amount $tokenSymbol',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
