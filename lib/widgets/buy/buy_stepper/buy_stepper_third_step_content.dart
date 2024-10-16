import 'package:flutter/material.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';

class BuyStepperThirdStepContent extends StatefulWidget {
  final SwapEthForZnnData swapEthForZnnData;

  const BuyStepperThirdStepContent({
    required this.swapEthForZnnData,
    super.key,
  });

  @override
  State<BuyStepperThirdStepContent> createState() =>
      _BuyStepperThirdStepContentState();
}

class _BuyStepperThirdStepContentState
    extends State<BuyStepperThirdStepContent> {
  final double _minSlippage = 0.0;
  final double _maxSlippage = 1.0;
  final int _divisions = 100;

  @override
  Widget build(BuildContext context) {
    final String eth = widget.swapEthForZnnData.quota!.wei.toStringWithDecimals(
      kEvmCurrencyDecimals,
    );
    final String znn = widget.swapEthForZnnData.quota!.znn.toStringWithDecimals(
      kZnnCoin.decimals,
    );

    return Column(
      children: [
        _buildQuotaInfo(eth, znn),
        Text('Current slippage: ${(widget.swapEthForZnnData.slippage * 100).round()}%'),
        _buildSlippageSlider(),
      ],
    );
  }

  Text _buildQuotaInfo(String eth, String znn) =>
      Text('Press continue to swap $eth ETH for $znn ${kZnnCoin.symbol}');

  Widget _buildSlippageSlider() {
    final double currentSlippage = widget.swapEthForZnnData.slippage;
    final double divisionValue = _maxSlippage / _divisions;

    final IconButton minusButton = IconButton(
      onPressed: () {
        if (currentSlippage > _minSlippage) {
          updateSlippage(currentSlippage - divisionValue);
        }
      },
      icon: const Icon(Icons.remove_circle_outline),
    );

    final IconButton addButton = IconButton(
      onPressed: () {
        if (currentSlippage < _maxSlippage) {
          updateSlippage(currentSlippage + divisionValue);
        }
      },
      icon: const Icon(Icons.add_circle_outline),
    );

    final Slider slider = Slider.adaptive(
      min: _minSlippage,
      max: _maxSlippage,
      divisions: _divisions,
      value: currentSlippage,
      onChanged: (value) {
        updateSlippage(value);
      },
    );

    return Row(
      children: [minusButton, Expanded(child: slider), addButton],
    );
  }

  void updateSlippage(double newValue) {
    setState(() {
      widget.swapEthForZnnData.slippage = newValue;
    });
  }
}
