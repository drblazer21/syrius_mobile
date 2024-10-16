import 'package:flutter/material.dart' hide Step, StepState, Stepper;
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/eth_to_znn_quota.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:web3dart/web3dart.dart';

class BuyStepperScreen extends StatefulWidget {
  const BuyStepperScreen({super.key});

  @override
  State<BuyStepperScreen> createState() => _BuyStepperScreenState();
}

class _BuyStepperScreenState extends State<BuyStepperScreen> {
  final EthAccountBalanceBloc _ethBalanceBloc = sl.get<EthAccountBalanceBloc>();
  final EthToZnnQuotaBloc _ethToZnnQuotaBloc = EthToZnnQuotaBloc();
  final SwapEthForZnnBloc _swapEthForZnnBloc = SwapEthForZnnBloc();

  final TextEditingController _znnAddressController = TextEditingController();
  final TextEditingController _ethAddressController = TextEditingController();
  final TextEditingController _ethAmountController = TextEditingController();

  int _index = 0;
  final SwapEthForZnnData _swapEthForZnnData = SwapEthForZnnData();

  late EthAccountBalance _ethAccountBalance;

  EthereumAddress get _currentActiveEthAddress =>
      kEthSelectedAddress!.toEthAddress();

  String get _ethAmountToSwap => _ethAmountController.text;

  @override
  void initState() {
    super.initState();
    _znnAddressController.text = kSelectedAddress!.hex;
    _ethAddressController.text = kEthSelectedAddress!.hex;
    _ethBalanceBloc.fetch(address: _currentActiveEthAddress);
  }

  @override
  Widget build(BuildContext context) {
    if (kSelectedAppNetworkWithAssets!.network.blockChain == BlockChain.nom) {
      return const SyriusErrorWidget(
        'Switch to Ethereum to buy wZNN',
      );
    }
    return AppStreamBuilder(
      builder: (data) {
        _ethAccountBalance = data;
        _ethAmountController.text = data.eth;
        return _buildStepper();
      },
      stream: _ethBalanceBloc.stream,
    );
  }

  SyriusStepper _buildStepper() {
    return SyriusStepper(
      controlsBuilder: stepperControlsBuilder,
      currentStep: _index,
      onStepCancel: () {
        if (_index == 0) {
          Navigator.pop(context);
        } else {
          setState(() {
            _index -= 1;
          });
        }
      },
      onStepContinue: _index <= 2
          ? () {
              if (_index == 0) {
                if (_ethAccountBalance.wei >= kMinimumWeiNeededForSwapping) {
                  _swapEthForZnnData.fromEthAddress =
                      _ethAddressController.text;
                  _swapEthForZnnData.toZnnAddress = _znnAddressController.text;
                  setState(() {
                    _index += 1;
                  });
                }
              } else if (_index == 1) {
                _ethToZnnQuotaBloc.fetch(
                  weiAmount: _ethAmountToSwap.extractDecimals(kEvmCurrencyDecimals),
                );
                setState(() {
                  _index += 1;
                });
              } else if (_index == 2) {
                _swapEthForZnnBloc.swap(
                  data: _swapEthForZnnData,
                );
                setState(() {
                  _index += 1;
                });
              } else {
                setState(() {
                  _index += 1;
                });
              }
            }
          : () {
              Navigator.pop(context);
            },
      onStepTapped: (int index) {
        setState(() {
          _index = index;
        });
      },
      steps: <Step>[
        Step(
          title: const Text('Step 1 title'),
          content: _buildFirstStepContentStreamBuilder(),
          isActive: _index == 0,
          state: _handleStepState(0),
        ),
        Step(
          title: const Text('Step 2 title'),
          content: _buildSecondStepContent(),
          isActive: _index == 1,
          state: _handleStepState(1),
        ),
        Step(
          title: const Text('Step 3 title'),
          content: _buildThirdStepContent(),
          isActive: _index == 2,
          state: _handleStepState(2),
        ),
        Step(
          title: const Text('Step 4 title'),
          content: _buildFourthStepContent(),
          isActive: _index == 3,
          state: _handleStepState(3),
        ),
      ],
    );
  }

  StepState _handleStepState(int stepIndex) {
    if (_index == stepIndex) {
      return StepState.editing;
    } else {
      return StepState.disabled;
    }
  }

  Widget _buildFirstStepContentStreamBuilder() {
    return BuyStepperFirstStepContent(
      ethAddressController: _ethAddressController,
      ethBalance: _ethAccountBalance.eth,
      onRefreshButtonPressed: () {
        _ethBalanceBloc.fetch(address: _currentActiveEthAddress);
      },
      znnAddressController: _znnAddressController,
    );
  }

  Widget _buildSecondStepContent() {
    return BuyStepperSecondStepContent(
      weiBalance: _ethAccountBalance.wei,
      ethAmountController: _ethAmountController,
    );
  }

  Widget _buildThirdStepContent() {
    return AppStreamBuilder<EthToZnnQuota>(
      stream: _ethToZnnQuotaBloc.stream,
      builder: (data) {
        _swapEthForZnnData.quota = data;
        return BuyStepperThirdStepContent(
          swapEthForZnnData: _swapEthForZnnData,
        );
      },
    );
  }

  Widget _buildFourthStepContent() {
    return AppStreamBuilder<String>(
      stream: _swapEthForZnnBloc.stream,
      builder: (data) {
        return Text(data);
      },
    );
  }
}
