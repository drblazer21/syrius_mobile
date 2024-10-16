import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PillarDetailScreen extends StatefulWidget {
  final PillarInfo pillarInfo;
  final DelegationInfo? delegationInfo;
  final PillarsListBloc bloc;
  final DelegationInfoBloc delegationInfoBloc;

  const PillarDetailScreen({
    super.key,
    required this.pillarInfo,
    required this.bloc,
    this.delegationInfo,
    required this.delegationInfoBloc,
  });

  @override
  State<PillarDetailScreen> createState() => _PillarDetailScreenState();
}

class _PillarDetailScreenState extends State<PillarDetailScreen> {
  String? _currentlyDelegatingToPillar;

  final DelegateButtonBloc _delegateButtonBloc = DelegateButtonBloc();
  final UndelegateButtonBloc _undelegateButtonBloc = UndelegateButtonBloc();


  @override
  void dispose() {
    _delegateButtonBloc.dispose();
    _undelegateButtonBloc.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _delegateButtonBloc.stream.listen(
          (event) {
        if (event != null) {
          widget.delegationInfoBloc.updateStream();
          setState(() {
            _currentlyDelegatingToPillar = null;
          });
        }
      },
      onError: (error) {
        if (!mounted) return;
        sendNotificationError(
          AppLocalizations.of(context)!.delegateError,
          error,
        );
        setState(() {
          _currentlyDelegatingToPillar = null;
        });
      },
    );
    _undelegateButtonBloc.stream.listen(
          (event) async {
        if (event != null) {
          await widget.delegationInfoBloc.updateStream();
          widget.bloc.refreshResults();
        }
      },
      onError: (error) {
        if (!mounted) return;
        sendNotificationError(
          AppLocalizations.of(context)!.undelegateError,
          error,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listViewChildren = _buildListViewChildren();

    return CustomAppbarScreen(
      appbarTitle: widget.pillarInfo.name,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (_, index) => listViewChildren[index],
              itemCount: listViewChildren.length,
              separatorBuilder: (_, __) => kVerticalSpacer,
            ),
          ),
          _getDelegateContainer(
            widget.pillarInfo,
            widget.bloc,
          ),
        ],
      ),
    );
  }

  String getWeight() {
    return widget.pillarInfo.weight.toStringWithDecimals(
      kZnnCoin.decimals,
    );
  }

  Widget _getDelegateButtonViewModel(
    PillarInfo pillarInfo,
    PillarsListBloc pillarsModel,
    AccountInfo accountInfo,
  ) {
    return Visibility(
      visible: accountInfo.znn()! >= kMinDelegationAmount &&
          (_currentlyDelegatingToPillar == null ||
              _currentlyDelegatingToPillar == pillarInfo.name),
      child: _getDelegateButton(
        pillarInfo,
        _delegateButtonBloc,
      ),
    );
  }

  Widget _getDelegateButton(
    PillarInfo pillarInfo,
    DelegateButtonBloc model,
  ) {
    return SyriusFilledButton(
      onPressed: () {
        setState(() {
          _currentlyDelegatingToPillar = pillarInfo.name;
        });
        model.votePillar(pillarInfo.name);
        Navigator.pop(context);
      },
      text: AppLocalizations.of(context)!.delegateAction,
    );
  }

  Widget _getUndelegateButton(
    UndelegateButtonBloc model,
  ) {
    return SyriusFilledButton.color(
      color: context.colorScheme.primaryContainer,
      onPressed: () {
        model.undelegate(pillarName: widget.pillarInfo.name);
        widget.bloc.refreshResults();
        Navigator.pop(context);
      },
      text: AppLocalizations.of(context)!.undelegate,
    );
  }

  Widget _getBalanceStreamBuilder(
    PillarInfo pillarInfo,
    PillarsListBloc pillarsModel,
  ) {
    return StreamBuilder<AccountInfo>(
      stream: sl.get<BalanceBloc>().stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            Logger('PillarDetailScreen').log(Level.INFO, snapshot.data);
            return _getDelegateButtonViewModel(
              pillarInfo,
              pillarsModel,
              snapshot.data!,
            );
          }
          return const SyriusLoadingWidget();
        }
        return const SyriusLoadingWidget();
      },
    );
  }

  Widget _getDelegateContainer(
    PillarInfo pillarInfo,
    PillarsListBloc model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Visibility(
          visible: _currentlyDelegatingToPillar == null ||
              _currentlyDelegatingToPillar == pillarInfo.name,
          child: widget.delegationInfo == null
              ? _getBalanceStreamBuilder(pillarInfo, model)
              : Container(),
        ),
        if (widget.delegationInfo != null)
          Visibility(
            visible: pillarInfo.name == widget.delegationInfo!.name,
            child: _getUndelegateButton(_undelegateButtonBloc),
          ),
      ],
    );
  }

  List<Widget> _buildListViewChildren() {
    return [
      _PillarInfoWidget(
        title: AppLocalizations.of(context)!.ownerInfo,
        value: '${widget.pillarInfo.ownerAddress}',
      ),
      _PillarInfoWidget(
        title: AppLocalizations.of(context)!.momentumsInfo,
        value:
            '${widget.pillarInfo.expectedMomentums} / ${widget.pillarInfo.producedMomentums}',
      ),
      _PillarInfoWidget(
        title: AppLocalizations.of(context)!.pillarRewardsInfo,
        value:
            '${widget.pillarInfo.giveMomentumRewardPercentage}% / ${widget.pillarInfo.giveDelegateRewardPercentage}%',
      ),
      FormattedAmountWithTooltip(
        amount: getWeight(),
        tokenSymbol: kZnnCoin.symbol,
        builder: (formattedAmount, tokenSymbol) => _PillarInfoWidget(
          title: AppLocalizations.of(context)!.weightInfo,
          value: formattedAmount,
        ),
      ),
    ];
  }
}

class _PillarInfoWidget extends StatelessWidget {
  final String title;
  final String value;

  const _PillarInfoWidget({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15.0,
          top: 15.0,
          bottom: 15.0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            CopyToClipboardButton(
              text: value,
            ),
          ],
        ),
      ),
    );
  }
}
