import 'dart:convert';
import 'dart:io';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:web3_provider/web3_provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

final Logger _logger = Logger('WebView');

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with AutomaticKeepAliveClientMixin {
  late InAppWebViewController _controller;
  late PullToRefreshController _pullToRefreshController;

  final TextEditingController _urlController = TextEditingController();

  bool _isSharing = false;

  final GasFeeDetailsBloc _gasFeeDetailsBloc = GasFeeDetailsBloc();

  String get _url => _urlController.text;

  final ValueNotifier<double> _progress = ValueNotifier(0.0);
  final ValueNotifier<bool> _canGoBack = ValueNotifier(false);
  final ValueNotifier<bool> _canGoForward = ValueNotifier(false);
  final ValueNotifier<Uri?> _currentUri = ValueNotifier(null);
  final ValueNotifier<bool> _isSecureConnection = ValueNotifier(false);
  final ValueNotifier<bool> _hasLoadedWithError = ValueNotifier(false);

  final BookmarkBloc _bookmarkBloc = BookmarkBloc();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      onRefresh: () {
        _controller.reload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      stream: db.managers.bookmarks.watch(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return _buildScaffold(context: context, bookmarks: snapshot.data!);
        } else if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        return const SyriusLoadingWidget();
      },
    );
  }

  Scaffold _buildScaffold({
    required List<Bookmark> bookmarks,
    required BuildContext context,
  }) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size(
            double.infinity,
            5.0,
          ),
          child: ValueListenableBuilder(
            valueListenable: _progress,
            builder: (_, value, __) => Visibility(
              visible: value < 1.0,
              child: LinearProgressIndicator(
                value: value,
                valueColor: const AlwaysStoppedAnimation<Color>(znnColor),
              ),
            ),
          ),
        ),
        title: _buildUrlTextField(),
      ),
      body: _buildWebView(context: context, bookmarks: bookmarks),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder(
              valueListenable: _canGoBack,
              builder: (_, canGoBack, __) {
                final VoidCallback? onPressed =
                    canGoBack ? _controller.goBack : null;

                return IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                  ),
                  onPressed: onPressed,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _canGoForward,
              builder: (_, canGoForward, __) {
                final VoidCallback? onPressed =
                    canGoForward ? _controller.goForward : null;

                return IconButton(
                  icon: const Icon(
                    Icons.chevron_right,
                  ),
                  onPressed: onPressed,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _currentUri,
              builder: (_, url, __) {
                final VoidCallback? onPressed =
                    isValidUrl(url?.toString() ?? '')
                        ? () {
                            _controller.reload();
                          }
                        : null;
                return IconButton(
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  onPressed: onPressed,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _currentUri,
              builder: (_, url, __) {
                final VoidCallback? onPressed = isValidUrl(
                  url?.toString() ?? '',
                )
                    ? () {
                        if (!_isSharing) {
                          _isSharing = true;
                          Share.share(_url).then((_) => _isSharing = false);
                        }
                      }
                    : null;

                return IconButton(
                  icon: const Icon(
                    Icons.share,
                  ),
                  onPressed: onPressed,
                );
              },
            ),
            StreamBuilder(
              initialData: InitialBookmarkState(),
              stream: _bookmarkBloc.stream,
              builder: (_, snapshot) {
                IconData? iconData = Icons.bookmark_outline;
                VoidCallback? onPressed;
                switch (snapshot.data!) {
                  case InitialBookmarkState():
                    break;
                  case CanBookmarkState():
                    final CanBookmarkState state =
                        snapshot.data! as CanBookmarkState;

                    onPressed = () {
                      _bookmarkBloc.save(
                        controller: _controller,
                        url: state.url,
                      );
                    };
                  case FoundBookmarkState():
                    final FoundBookmarkState state =
                        snapshot.data! as FoundBookmarkState;
                    iconData = Icons.bookmark;
                    onPressed = () {
                      _bookmarkBloc.delete(bookmark: state.bookmark);
                    };
                }

                return IconButton(
                  onPressed: onPressed,
                  icon: Icon(iconData),
                );
              },
            ),
            IconButton(
              onPressed: () {
                _controller.loadData(
                  data: generateBookmarkHtml(bookmarks),
                );
              },
              icon: const Icon(
                Icons.home,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InAppWebViewEIP1193 _buildWebView({
    required BuildContext context,
    required List<Bookmark> bookmarks,
  }) {
    return InAppWebViewEIP1193(
      initialData: InAppWebViewInitialData(
        data: generateBookmarkHtml(
          bookmarks,
        ),
      ),
      chainId: kSelectedAppNetworkWithAssets!.network.chainId,
      rpcUrl: kSelectedAppNetworkWithAssets!.network.url,
      walletAddress: selectedAddress.hex,
      onLoadError: (_, __, ___, ____) {
        _isSecureConnection.value = false;
        _hasLoadedWithError.value = true;
        _pullToRefreshController.endRefreshing();
      },
      onLoadHttpError: (_, __, ___, ____) {
        _isSecureConnection.value = false;
        _hasLoadedWithError.value = true;
      },
      onLoadStart: (controller, Uri? uri) async {
        await controller.evaluateJavascript(
          source: """
              (function() {
                var oldLog = console.log;
                console.log = function(message) {
                  oldLog(message);
                  window.flutter_inappwebview.callHandler('consoleLog', message);
                };

                var oldWarn = console.warn;
                console.warn = function(message) {
                  oldWarn(message);
                  window.flutter_inappwebview.callHandler('consoleWarn', message);
                };

                var oldError = console.error;
                console.error = function(message) {
                  oldError(message);
                  window.flutter_inappwebview.callHandler('consoleError', message);
                };
              })();
            """,
        );

        // Add a handler to receive messages from the JavaScript
        controller.addJavaScriptHandler(
          handlerName: 'consoleLog',
          callback: (args) {
            _logger.info(args);
          },
        );

        controller.addJavaScriptHandler(
          handlerName: 'consoleWarn',
          callback: (args) {
            _logger.warning(args);
          },
        );

        controller.addJavaScriptHandler(
          handlerName: 'consoleError',
          callback: (args) {
            _logger.severe(args);
          },
        );
        _isSecureConnection.value = false;
        _hasLoadedWithError.value = false;
        if (uri != null) {
          _currentUri.value = uri;
          if (uri.toString() != 'about:blank') {
            _urlController.text = uri.toString();
          }
          _bookmarkBloc.update(url: uri.toString());
        }
        _updateNavigationButtonsState(controller);
      },
      onLoadStop: (controller, Uri? uri) {
        _pullToRefreshController.endRefreshing();
        if (uri != null) {
          if (!_hasLoadedWithError.value && uri.scheme == 'https') {
            _isSecureConnection.value = true;
          }
          _currentUri.value = uri;
          if (uri.toString() != 'about:blank') {
            _urlController.text = uri.toString();
          }
          _bookmarkBloc.update(url: uri.toString());
        }
        _progress.value = 1.0;
        _updateNavigationButtonsState(controller);
      },
      onProgressChanged: (_, progress) {
        _progress.value = progress / 100;
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        Logger('WebView').log(
          Level.WARNING,
          'Issues with the SSL certificate',
          challenge.toString(),
        );

        final String? sslError = challenge.protectionSpace.sslError?.message;

        final String reason = sslError != null ? ' Reason: $sslError' : '';

        if (Platform.isIOS &&
            reason.contains('user intent was not explicitly specified')) {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        }

        final bool? shouldAllowNavigation =
            await showDialogWithNoAndYesOptions<bool?>(
          context: context,
          description:
              'You are trying to access a website without a valid SSL certificate.$reason\n'
              'Press Yes if you are still willing to access the website',
          title: 'SSL Certificate invalid',
        );

        if (shouldAllowNavigation ?? false) {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        } else {
          _controller.stopLoading();
          return ServerTrustAuthResponse();
        }
      },
      onWebViewCreated: (controller) {
        _controller = controller;
        controller.addJavaScriptHandler(
          handlerName: 'openUrl',
          callback: (args) {
            final String url = args[0] as String;
            controller.loadUrl(
              urlRequest: URLRequest(url: Uri.parse(url)),
            );
          },
        );
      },
      initialOptions: InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
        ),
      ),
      pullToRefreshController: _pullToRefreshController,
      signCallback: (params, eip1193, controller) {
        final id = params["id"] as int;
        switch (eip1193) {
          case EIP1193.requestAccounts:
            controller?.setAddress(selectedAddress.hex, id);
          case EIP1193.signTransaction:
            final Map<String, dynamic> object =
                params["object"] as Map<String, dynamic>;
            final JsBridgeParams bridge = JsBridgeParams.fromJson(object);
            _signTransaction(
              bridge: bridge,
              chainId: kSelectedAppNetworkWithAssets!.network.chainId!,
              cancel: () {
                controller?.cancel(id);
              },
              success: (idHash) {
                controller?.sendResult(idHash, id);
              },
            );
          case EIP1193.signMessage:
            final Map<String, dynamic> object =
                params["object"] as Map<String, dynamic>;
            final Uint8List raw = object["raw"] as Uint8List;
            showModalBottomSheetWithButtons(
              context: context,
              isDismissible: false,
              subTitleWidget: SizedBox(
                height: 400.0,
                child: Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                            bytesToHex(raw),
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: 'Sign Message',
              btn1Text: 'Confirm',
              btn1Action: () async {
                final String signature = EthSigUtil.signMessage(
                  privateKey: await getPrivateKey(address: selectedAddress.hex),
                  message: raw,
                );
                final String result = signature;
                controller?.sendResult(result, id);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              btn2Text: 'Reject',
              btn2Action: () {
                controller?.cancel(id);
                Navigator.pop(context);
              },
            );
          case EIP1193.signPersonalMessage:
            final Map<String, dynamic> object =
                params["object"] as Map<String, dynamic>;
            final String data = object["data"] as String;
            showModalBottomSheetWithButtons(
              context: context,
              isDismissible: false,
              subTitleWidget: SizedBox(
                height: 400.0,
                child: Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                            data,
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                    kVerticalSpacer,
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                            utf8.decode(hexToBytes(data)),
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: 'Sign Personal Message',
              btn1Text: 'Confirm',
              btn1Action: () async {
                final credentials = await generateCredentials(
                  address: selectedAddress.hex,
                );
                final Uint8List message =
                    credentials.signPersonalMessageToUint8List(
                  hexToBytes(data),
                );
                final String result = bytesToHex(message, include0x: true);
                controller?.sendResult(result, id);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              btn2Text: 'Reject',
              btn2Action: () {
                controller?.cancel(id);
                Navigator.pop(context);
              },
            );
          case EIP1193.signTypedMessage:
            final Map<String, dynamic> object =
                params["object"] as Map<String, dynamic>;
            final String raw = object["raw"] as String;
            showModalBottomSheetWithButtons(
              context: context,
              isDismissible: false,
              subTitleWidget: SizedBox(
                height: 400.0,
                child: Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Text(
                            raw,
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: 'Sign Typed Message',
              btn1Text: 'Confirm',
              btn1Action: () async {
                final String signature = EthSigUtil.signTypedData(
                  privateKey: await getPrivateKey(address: selectedAddress.hex),
                  jsonData: raw,
                  version: TypedDataVersion.V1,
                );
                final String result = signature;
                controller?.sendResult(result, id);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              btn2Text: 'Reject',
              btn2Action: () {
                controller?.cancel(id);
                Navigator.pop(context);
              },
            );
          case EIP1193.addEthereumChain:
        }
      },
    );
  }

  void _updateNavigationButtonsState(InAppWebViewController controller) {
    controller.canGoBack().then((value) => _canGoBack.value = value);
    controller.canGoForward().then((value) => _canGoForward.value = value);
  }

  Future<void> _signTransaction({
    required JsBridgeParams bridge,
    required int chainId,
    required VoidCallback cancel,
    required Function(String idHash) success,
  }) async {
    final from = EthereumAddress.fromHex(bridge.from ?? '');
    try {
      final Transaction tx = Transaction(
        from: from,
        maxGas: bridge.gas,
        to: bridge.to,
        value: bridge.value,
        data: bridge.data,
        nonce: bridge.nonce,
      );

      _gasFeeDetailsBloc.addEvent(GasFeeDetailsLoading());

      _showConfirmTxBottomSheet(onSigned: success);

      _gasFeeDetailsBloc.fetch(
        fetchAsset: tx.isContractInteraction,
        tx: tx,
      );
    } catch (e) {
      sendNotificationError('Signing transaction from the dApp failed', e);
      cancel.call();
      return;
    }
  }

  Widget _buildUrlTextField() {
    return ValueListenableBuilder(
      valueListenable: _urlController,
      builder: (_, __, ___) => TextField(
        controller: _urlController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          hintText: 'Enter dApp URL',
          prefixIcon: ValueListenableBuilder(
            valueListenable: _isSecureConnection,
            builder: (_, isSecure, ___) {
              final IconData iconData =
                  isSecure ? Icons.lock_outline : Icons.info_outline;
              return Icon(iconData);
            },
          ),
          suffixIcon: Visibility(
            visible: _urlController.text.isNotEmpty,
            child: ClearTextFormFieldButton(
              onTap: () {
                _urlController.clear();
              },
            ),
          ),
        ),
        keyboardType: TextInputType.url,
        onSubmitted: (value) {
          String? finalUrl;
          if (Uri.parse(_url).isAbsolute) {
            finalUrl = _url;
          } else {
            finalUrl = 'https://duckduckgo.com/?q=$_url';
          }
          _controller.loadUrl(
            urlRequest: URLRequest(
              url: Uri.parse(finalUrl),
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> _showConfirmTxBottomSheet({
    required void Function(String) onSigned,
  }) {
    return showModalBottomSheetWithBody(
      context: context,
      title: AppLocalizations.of(context)!.confirmTransaction,
      body: AppStreamBuilder<EthAccountBalance>(
        errorHandler: (a) {},
        stream: sl.get<EthAccountBalanceBloc>().stream,
        builder: (ethereumAccountBalance) {
          return _buildGasFeeListenerWidget(
            ethAccountBalance: ethereumAccountBalance,
            onSigned: onSigned,
          );
        },
        customErrorWidget: (String error) {
          return SyriusErrorWidget(error);
        },
        customLoadingWidget: const SyriusLoadingWidget(),
      ),
    );
  }

  StreamBuilder<GasFeeDetailsState> _buildGasFeeListenerWidget({
    required void Function(String) onSigned,
    required EthAccountBalance ethAccountBalance,
  }) {
    return StreamBuilder(
      initialData: GasFeeDetailsInitialState(),
      stream: _gasFeeDetailsBloc.stream,
      builder: (_, snapshot) {
        switch (snapshot.data!) {
          case GasFeeDetailsInitialState():
            return const SyriusLoadingWidget();
          case GasFeeDetailsLoading():
            return const SyriusLoadingWidget();
          case GasFeeDetailsLoaded():
            final GasFeeDetailsLoaded loaded =
                snapshot.data! as GasFeeDetailsLoaded;
            return StatefulBuilder(
              builder: (_, setState) => _buildConfirmTxBottomSheetBody(
                ethAccountBalance: ethAccountBalance,
                gasDetails: loaded.ethereumTxGasDetailsData,
                onSigned: onSigned,
              ),
            );
          case GasFeeDetailsError():
            return SyriusErrorWidget(snapshot.error!);
        }
      },
    );
  }

  Column _buildConfirmTxBottomSheetBody({
    required EthAccountBalance ethAccountBalance,
    required EthereumTxGasDetailsData gasDetails,
    required void Function(String) onSigned,
  }) {
    String? readableAmount;
    String? symbol;
    EthereumAddress? to;

    if (gasDetails.tx.isContractInteraction) {
      final Uint8List data = gasDetails.tx.data!;
      if (eth.dataMatchesTransferTokenFunction(data: data)) {
        final List<dynamic> decodedParameters = decodeParameters(
          eth.getTokenTransferFunction(),
          data,
        );

        to = decodedParameters[0] as EthereumAddress;

        final BigInt amount = decodedParameters[1] as BigInt;

        final NetworkAssetsCompanion asset = gasDetails.asset!;

        readableAmount = amount.toStringWithDecimals(asset.decimals.value);

        symbol = asset.symbol.value;
      }
    } else {
      readableAmount = gasDetails.tx.value!.toEthWithDecimals();
      symbol = kSelectedAppNetworkWithAssets!.network.currencySymbol;
      to = gasDetails.tx.to;
    }

    BigInt totalNeededEthForTx = gasDetails.maxFee.getInWei;

    if (gasDetails.tx.value != null) {
      totalNeededEthForTx += gasDetails.tx.value!.getInWei;
    }

    final bool hasEnoughEth = _ethAmountValidator(
          totalNeededEthForTx.toStringWithDecimals(
            kEvmCurrencyDecimals,
          ),
          ethAccountBalance.getCurrency(),
        ) ==
        null;

    final Widget subtitleWidget = Text(
      AppLocalizations.of(context)!.reviewTransaction,
      style: context.textTheme.titleSmall?.copyWith(
        color: context.colorScheme.secondary,
      ),
      textAlign: TextAlign.center,
    );

    final Widget confirmButton = SyriusFilledButton(
      text: AppLocalizations.of(context)!.confirm,
      onPressed: () {
        _onConfirmPressed(
          onSigned: onSigned,
          tx: gasDetails.txWithGasFee,
        );
      },
    );

    final Widget ethBalanceWarning = Text(
      'Not enough ETH to cover the gas fees',
      style: TextStyle(
        color: context.colorScheme.error,
      ),
      textAlign: TextAlign.center,
    );

    final String currencySymbol =
        kSelectedAppNetworkWithAssets!.network.currencySymbol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        subtitleWidget,
        Column(
          children: [
            ..._buildEthereumTxSpeedListTiles(
              data: gasDetails,
            ),
          ],
        ),
        BottomSheetInfoRow(
          context: context,
          leftContent: 'Estimated gas',
          rightContent:
              '${gasDetails.estimatedGas.toEthWithDecimals()} $currencySymbol',
        ),
        BottomSheetInfoRow(
          context: context,
          leftContent: 'Maximum gas',
          rightContent:
              '${gasDetails.maxFee.toEthWithDecimals()} $currencySymbol',
        ),
        BottomSheetInfoRow(
          context: context,
          leftContent: AppLocalizations.of(context)!.fromAddress,
          rightContent: shortenWalletAddress(
            selectedAddress.hex,
          ),
        ),
        if (to != null)
          BottomSheetInfoRow(
            context: context,
            leftContent: AppLocalizations.of(context)!.toAddress,
            rightContent: shortenWalletAddress(
              to.hex,
            ),
          ),
        if (readableAmount != null && symbol != null)
          BottomSheetInfoRow(
            context: context,
            leftContent: AppLocalizations.of(context)!.amount,
            rightContent: '$readableAmount $symbol',
          ),
        TextButton(
          onPressed: () {
            showEditGasFeeScreen(
              context: context,
              data: gasDetails,
              gasFeeDetailsBloc: _gasFeeDetailsBloc,
            );
          },
          child: const Text('Edit gas fee'),
        ),
        if (hasEnoughEth) confirmButton else ethBalanceWarning,
      ].addSeparator(kVerticalSpacer),
    );
  }

  String? _ethAmountValidator(String input, EthAccountBalanceItem balanceItem) {
    if (input.isNotEmpty) {
      return correctValueSyrius(
        input,
        balanceItem.balance,
        balanceItem.ethAsset.decimals,
        BigInt.zero,
      );
    }
    return null;
  }

  List<Widget> _buildEthereumTxSpeedListTiles({
    required EthereumTxGasDetailsData data,
  }) =>
      EthereumTxSpeed.values
          .map(
            (speed) => _buildEthereumTxSpeedListTile(
              evmTransactionSpeed: speed,
              onChangedCallback: (EthereumTxSpeed speed) {
                final EthereumTxGasDetailsData newData = data
                  ..speed = speed
                  ..userFee = data.fees[speed.index];
                _gasFeeDetailsBloc.update(newData);
              },
              selectedSpeed: data.speed,
            ),
          )
          .toList();

  Widget _buildEthereumTxSpeedListTile({
    required EthereumTxSpeed evmTransactionSpeed,
    required void Function(EthereumTxSpeed) onChangedCallback,
    required EthereumTxSpeed? selectedSpeed,
  }) {
    return RadioListTile<EthereumTxSpeed>(
      title: Text(evmTransactionSpeed.name.capitalize()),
      value: evmTransactionSpeed,
      groupValue: selectedSpeed,
      onChanged: (EthereumTxSpeed? value) {
        if (value != null) {
          onChangedCallback(value);
        }
      },
    );
  }

  Future<void> _onConfirmPressed({
    required void Function(String) onSigned,
    required Transaction tx,
  }) async {
    Navigator.pop(context);
    final Uint8List signature = await eth.signTx(
      cred: await generateCredentials(
        address: tx.from!.hex,
      ),
      transaction: tx,
      chainId: kSelectedAppNetworkWithAssets!.network.chainId!,
    );

    final signedTx = bytesToHex(signature, include0x: true);

    onSigned(signedTx);
  }
}

String generateBookmarkHtml(List<Bookmark> bookmarks) {
  final StringBuffer html = StringBuffer();
  html.write('''
      <html>
        <head>
          <title>Bookmarks</title>
          <style>
            body {
              font-family: Arial, sans-serif;
              padding: 20px;
              background: #0f0f0f;
            }
            .bookmark {
              display: flex;
              align-items: center;
              margin-bottom: 20px;
              cursor: pointer;
            }
            .bookmark img {
              width: 128px;
              height: 128px;
              margin-right: 24px;
            }
            .bookmark-title {
              font-size: 38px;
              font-weight: bold;
              color: #ffffff;
            }
          </style>
          <script type="text/javascript">
            function openBookmark(url) {
              window.flutter_inappwebview.callHandler('openUrl', url);
            }
          </script>
        </head>
        <body>
    ''');

  for (final bookmark in bookmarks) {
    html.write('''
        <div class="bookmark" onclick="openBookmark('${bookmark.url}')">
          <img src="${bookmark.faviconUrl}" alt="icon">
          <div>
            <div class="bookmark-title">${bookmark.title}</div>
          </div>
        </div>
      ''');
  }

  html.write('''
        </body>
      </html>
    ''');

  return html.toString();
}
