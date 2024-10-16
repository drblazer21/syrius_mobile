import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PillarReward extends StatefulWidget {
  final PillarRewardsHistoryBloc pillarRewardsHistoryBloc;

  const PillarReward({super.key, required this.pillarRewardsHistoryBloc});

  @override
  State<PillarReward> createState() => _PillarRewardState();
}

class _PillarRewardState extends State<PillarReward> {
  final PillarUncollectedRewardsBloc _pillarCollectRewardsBloc =
      PillarUncollectedRewardsBloc();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 12.0,
        ),
        child: _buildStreamBuilder(),
      ),
    );
  }

  Column _buildBody(BigInt znnAmountToCollect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 75.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.delegateRewards,
                    style: context.textTheme.titleSmall,
                  ),
                  _buildAmountToCollect(znnAmountToCollect),
                ],
              ),
              _buildIcon(),
            ],
          ),
        ),
        kVerticalSpacer,
        PillarCollect(
          pillarRewardsHistoryBloc: widget.pillarRewardsHistoryBloc,
        ),
      ],
    );
  }

  Widget _buildAmountToCollect(BigInt znnAmountToCollect) {
    return Text(
      '${NumberFormat().format(znnAmountToCollect.toStringWithDecimals(kZnnCoin.decimals).toNum())} ${kZnnCoin.symbol}',
      style: context.textTheme.headlineLarge?.copyWith(
        color: context.colorScheme.primary,
      ),
    );
  }

  Widget _buildIcon() {
    return SvgPicture.asset(
      getSvgImagePath('rewards/delegate'),
      fit: BoxFit.fitHeight,
      height: 75.0,
    );
  }

  StreamBuilder<UncollectedReward?> _buildStreamBuilder() {
    return StreamBuilder<UncollectedReward?>(
      stream: _pillarCollectRewardsBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        } else if (snapshot.hasData) {
          Logger('PillarReward')
              .log(Level.INFO, '_buildStreamBuilder', snapshot.data);
          final amountToCollect = snapshot.data!.znnAmount;

          if (amountToCollect > BigInt.zero) {
            return _buildBody(snapshot.data!.znnAmount);
          } else {
            return const NoRewardsToCollect();
          }
        }
        return const SyriusLoadingWidget();
      },
    );
  }
}
