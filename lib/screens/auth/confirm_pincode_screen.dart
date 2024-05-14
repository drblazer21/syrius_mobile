import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class ConfirmPincodeScreen extends StatefulWidget {
  final String pin;

  const ConfirmPincodeScreen({
    required this.pin,
    super.key,
  });

  @override
  State<ConfirmPincodeScreen> createState() => _ConfirmPincodeScreenState();
}

class _ConfirmPincodeScreenState extends State<ConfirmPincodeScreen> {
  final GlobalKey<NumericVirtualKeyboardState> _formOneKey =
      GlobalKey<NumericVirtualKeyboardState>();

  final CreateKeyStoreBloc _createKeyStoreBloc = CreateKeyStoreBloc();

  late String _pin;

  @override
  void initState() {
    super.initState();
    _createKeyStoreBloc.stream.listen((event) async {
      if (event != null) {
        await establishConnectionToNode(kDefaultNode);
        await loadDbNodes();
        await sharedPrefsService.put(kSelectedNodeKey, kDefaultNode);
        kCurrentNode = kDefaultNode;
        if (!mounted) return;
        Navigator.pop(context);
        await showActivateBiometryScreen(
          context: context,
          pin: _pin,
          predicate: (_) => false,
        );
      }
    }).onError((error) {
      Navigator.pop(context);
      _showErrorBottomSheet(error);
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.setPinConfirmationTitle,
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.setPinConfirmationDescription,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          WarningWidget(
            iconData: Icons.info,
            fillColor: context.colorScheme.primaryContainer,
            textColor: context.colorScheme.onPrimaryContainer,
            text: AppLocalizations.of(context)!.setPinInfo,
          ),
          const Spacer(),
          NumericVirtualKeyboard(
            key: _formOneKey,
            pinThatNeedsToBeMatched: widget.pin,
            onFillPinBoxes: (bool isValid, String pin) async {
              _pin = pin;
              showLoadingDialog(context);
              await _createKeyStoreBloc.createAndDoInit(
                context: context,
                pin: widget.pin,
              );
              if (_formOneKey.currentState != null) {
                _formOneKey.currentState!.clearPin();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pin = '';
    _createKeyStoreBloc.dispose();
    super.dispose();
  }

  Future<dynamic> _showErrorBottomSheet(error) {
    return showModalBottomSheetWithButtons(
      btn1Color: context.colorScheme.errorContainer,
      context: context,
      title: AppLocalizations.of(context)!.error,
      subTitle: error.toString(),
      dialogImage: Icon(
        Icons.warning,
        color: context.colorScheme.errorContainer,
        size: 45.0,
      ),
      btn1Text: AppLocalizations.of(context)!.ok,
      btn1Action: () {
        Navigator.pop(context);
      },
    );
  }
}
