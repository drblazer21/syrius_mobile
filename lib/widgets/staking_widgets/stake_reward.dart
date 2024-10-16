import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class StakeReward extends StatefulWidget {
  const StakeReward({
    super.key,
  });

  @override
  State<StakeReward> createState() => _StakeRewardState();
}

class _StakeRewardState extends State<StakeReward> {
  final StakingUncollectedRewardsBloc _stakingUncollectedRewardsBloc =
      StakingUncollectedRewardsBloc();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.fromSeed(seedColor: qsrColor);

    return Card(
      color: scheme.onSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 12.0,
        ),
        child: _buildStreamBuilder(),
      ),
    );
  }

  @override
  void dispose() {
    _stakingUncollectedRewardsBloc.dispose();
    super.dispose();
  }

  Column _buildBody(BigInt qsrAmountToCollect) {
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
                    AppLocalizations.of(context)!.stakingRewards,
                    style: context.textTheme.titleSmall,
                  ),
                  Text(
                    '${NumberFormat().format(qsrAmountToCollect.toStringWithDecimals(kQsrCoin.decimals).toNum())} ${kQsrCoin.symbol}',
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: qsrColor,
                    ),
                  ),
                ],
              ),
              _buildIcon(),
            ],
          ),
        ),
        kVerticalSpacer,
        const StakeCollect(),
      ],
    );
  }

  Widget _buildIcon() {
    return SvgPicture.asset(
      getSvgImagePath('rewards/staking'),
      fit: BoxFit.fitHeight,
      height: 75.0,
    );
  }

  StreamBuilder<UncollectedReward?> _buildStreamBuilder() {
    return StreamBuilder<UncollectedReward?>(
      stream: _stakingUncollectedRewardsBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        } else if (snapshot.hasData) {
          Logger('StakeReward')
              .log(Level.INFO, '_buildStreamBuilder', snapshot.data);
          final amountToCollect = snapshot.data!.qsrAmount;
          if (amountToCollect > BigInt.zero) {
            return _buildBody(snapshot.data!.qsrAmount);
          } else {
            return const NoRewardsToCollect();
          }
        }
        return const SyriusLoadingWidget();
      },
    );
  }
}
