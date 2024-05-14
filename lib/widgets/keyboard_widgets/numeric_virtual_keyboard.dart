import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NumericVirtualKeyboard extends StatefulWidget {
  final bool isEnabled;
  final Function(bool, String) onFillPinBoxes;
  final VoidCallback? thumbTapped;
  final bool showThumb;
  final String? pinThatNeedsToBeMatched;

  const NumericVirtualKeyboard({
    required this.onFillPinBoxes,
    super.key,
    this.isEnabled = true,
    this.pinThatNeedsToBeMatched,
    this.showThumb = false,
    this.thumbTapped,
  });

  @override
  State<NumericVirtualKeyboard> createState() => NumericVirtualKeyboardState();
}

class NumericVirtualKeyboardState extends State<NumericVirtualKeyboard> {
  late AnimationController _animationController;
  final List<String> _pinNumbers = [];
  bool _isInErrorState = false;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double gridHeight = screenSize.height * 0.6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ShakeWidget(
          controller: (controller) {
            _animationController = controller;
          },
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: kIconAndTextHorizontalSpacer.width!,
            runSpacing: kIconAndTextHorizontalSpacer.width!,
            children: [
              for (int i = 0; i < 6; i++) ...[
                PinItem(
                  text: _getPinNumber(i),
                  isInErrorState: _isInErrorState,
                  isActive: (_pinNumbers.length) == i,
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          height: gridHeight,
          child: _buildKeyboardGrid(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pinNumbers.clearSecurely();
    super.dispose();
  }

  Widget _buildKeyboardGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (_, index) {
        final bool isBack = index == 11;
        final bool isThumb = index == 9;
        final bool isZero = index == 10;
        final int value = index + 1;
        final valueToBeInputted = isBack
            ? -2
            : isZero
                ? 0
                : value;
        final Function(int) onTapped = isThumb
            ? (int d) {
                widget.thumbTapped?.call();
              }
            : (int d) {
                _enterNumber(valueToBeInputted);
              };
        final String text = isZero ? '0' : value.toString();
        if (isThumb && !widget.showThumb) {
          return const SizedBox.shrink();
        }
        final bool backKeyShouldBeVisible = _pinNumbers.isNotEmpty;

        return NumericVirtualKeyboardItem(
          isBack: isBack,
          isThumb: isThumb,
          isEnabled: widget.isEnabled,
          text: text,
          index: value,
          backKeyShouldBeVisible: backKeyShouldBeVisible,
          tapped: onTapped,
        );
      },
    );
  }

  void _removeLastPinDigit(int position) {
    if (position > 0) {
      _pinNumbers.removeLast();
      setState(() {});
    }
  }

  void _enterNumber(int index) {
    if (index == -2) {
      _removeLastPinDigit(_pinNumbers.length);
    } else if (_pinNumbers.length <= 6) {
      _pinNumbers.add((index).toString());
      setState(() {});
    }
    _checkPin();
  }

  void _checkPin() {
    if (_pinNumbers.length == 6) {
      if (widget.pinThatNeedsToBeMatched != null) {
        if (_pinNumbers.join() == widget.pinThatNeedsToBeMatched) {
          widget.onFillPinBoxes(true, _pinNumbers.join());
        } else {
          triggerErrorState();
        }
      } else {
        widget.onFillPinBoxes(true, _pinNumbers.join());
      }
    }
  }

  String _getPinNumber(int position) {
    if (position >= _pinNumbers.length) {
      return '';
    }
    return _pinNumbers[0];
  }

  void clearPin() {
    setState(() {
      _pinNumbers.clear();
    });
  }

  void triggerErrorState() {
    _setErrorState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isInErrorState = false;
      });
    });
  }

  void _setErrorState() {
    setState(() {
      _isInErrorState = true;
      _pinNumbers.clear();
      _animationController.forward(from: 0.0);
      Vibrate.vibrate();
    });
  }
}
