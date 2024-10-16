import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/screens/web_view_screen.dart';
import 'package:syrius_mobile/services/i_web3wallet_service.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialUriIsHandled = false;
  final AppLinks _appLinks = AppLinks();
  final List<Widget> _initialPages = [
    const WalletScreen(),
    const ActivityScreen(),
    const SettingScreen(),
  ];

  int _currentPageIndex = 0;
  StreamSubscription? _incomingLinkSubscription;
  SendPaymentBloc sendPaymentBloc = SendPaymentBloc();
  StakingOptionsBloc stakingOptionsBloc = StakingOptionsBloc();
  DelegateButtonBloc delegateButtonBloc = DelegateButtonBloc();
  PlasmaOptionsBloc plasmaOptionsBloc = PlasmaOptionsBloc();

  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    sl.get<PlasmaStatsBloc>().get();
    _handleIncomingLinks();
    _handleInitialUri();
    final HistoryScreenControllerNotifier historyScreenControllerNotifier =
        context.read<HistoryScreenControllerNotifier>();
    historyScreenControllerNotifier.addListener(
      _animateToHistoryScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedNetworkNotifier>(
      builder: (_, __, ___) {
        const Widget rewardsPage = RewardsScreen();
        const Widget webViewPage = WebViewScreen();
        const Widget acceleratorPage = AcceleratorZScreen();

        final List<Widget> copyOfInitialPages = [];

        copyOfInitialPages.addAll(_initialPages);

        final List<Widget> pagesToBeInserted = [];

        switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
          case BlockChain.btc:
            break;
          case BlockChain.evm:
            pagesToBeInserted.add(webViewPage);
          case BlockChain.nom:
            pagesToBeInserted.addAll([rewardsPage, acceleratorPage]);
        }

        copyOfInitialPages.insertAll(2, pagesToBeInserted);

        _pageController?.dispose();

        _pageController = PageController();

        return PopScope<Object?>(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? _) {
            if (didPop) {
              return;
            }
            if (_currentPageIndex > 0) {
              _redirectToDashboardScreen(pageController: _pageController!);
            } else {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            bottomNavigationBar: _getBottomNavigationBar(
              pageController: _pageController!,
            ),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: copyOfInitialPages,
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    sendPaymentBloc.dispose();
    stakingOptionsBloc.dispose();
    delegateButtonBloc.dispose();
    plasmaOptionsBloc.dispose();
    _incomingLinkSubscription?.cancel();
    super.dispose();
  }

  Widget _getBottomNavigationBar({
    required PageController pageController,
  }) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      currentIndex: _currentPageIndex,
      iconSize: 35.0,
      items: _getBarItems(),
      selectedFontSize: 10.0,
      selectedItemColor: znnColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      unselectedFontSize: 10.0,
      useLegacyColorScheme: false,
      onTap: (index) => _navigateToPage(
        index: index,
        pageController: pageController,
      ),
    );
  }

  void _navigateToPage({
    required int index,
    required PageController pageController,
  }) {
    setState(() {
      _currentPageIndex = index;
      pageController.jumpToPage(index);
    });
  }

  List<BottomNavigationBarItem> _getBarItems() {
    final BottomNavigationBarItem acceleratorItem = BottomNavigationBarItem(
      icon: const Icon(
        MdiIcons.rocket,
      ),
      label: AppLocalizations.of(context)!.az,
    );

    final BottomNavigationBarItem rewardsItem = BottomNavigationBarItem(
      icon: const Icon(
        MdiIcons.trophyAward,
      ),
      label: AppLocalizations.of(context)!.rewards,
    );

    const BottomNavigationBarItem dAppItem = BottomNavigationBarItem(
      icon: Icon(
        MdiIcons.web,
      ),
      label: 'Web3',
    );

    final List<BottomNavigationBarItem> initialItems = [
      BottomNavigationBarItem(
        icon: const Icon(
          MdiIcons.walletBifold,
        ),
        label: AppLocalizations.of(context)!.wallet,
      ),
      BottomNavigationBarItem(
        icon: const Icon(
          MdiIcons.formatListBulleted,
        ),
        label: AppLocalizations.of(context)!.activity,
      ),
      BottomNavigationBarItem(
        icon: const Icon(
          Icons.settings,
        ),
        label: AppLocalizations.of(context)!.settings,
      ),
    ];

    final List<BottomNavigationBarItem> itemsToBoInserted = [];

    switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
      case BlockChain.btc:
        break;
      case BlockChain.evm:
        itemsToBoInserted.add(dAppItem);
      case BlockChain.nom:
        itemsToBoInserted.addAll([rewardsItem, acceleratorItem]);
    }

    initialItems.insertAll(2, itemsToBoInserted);

    return initialItems;
  }

  void _redirectToDashboardScreen({required PageController pageController}) {
    _navigateToPage(index: 0, pageController: pageController);
  }

  Future<void> _handleIncomingLinks() async {
    if (!kIsWeb) {
      _incomingLinkSubscription = _appLinks.uriLinkStream.listen(
        (Uri? uri) async {
          if (uri != null) {
            final String uriRaw = uri.toString();

            Logger('MainAppContainer')
                .log(Level.INFO, '_handleIncomingLinks $uriRaw');

            if (context.mounted) {
              if (uriRaw.contains('wc')) {
                final String wcUri =
                    Uri.decodeFull(uriRaw.split('wc?uri=').last);
                if (Uri.tryParse(wcUri) != null && wcUri.contains('symKey')) {
                  sl<IWeb3WalletService>().pair(Uri.parse(wcUri));
                }
                return;
              }

              // Deep link query parameters
              String queryAddress = '';
              String queryAmount = ''; // with decimals
              int queryDuration = 0; // in months
              String queryZTS = '';
              String queryPillarName = '';
              Token? token;

              if (uri.hasQuery) {
                uri.queryParametersAll.forEach((key, value) async {
                  if (key == 'amount') {
                    queryAmount = value.first;
                  } else if (key == 'zts') {
                    queryZTS = value.first;
                  } else if (key == 'address') {
                    queryAddress = value.first;
                  } else if (key == 'duration') {
                    queryDuration = int.parse(value.first);
                  } else if (key == 'pillar') {
                    queryPillarName = value.first;
                  }
                });
              }

              if (queryZTS.isNotEmpty) {
                if (queryZTS == 'znn' || queryZTS == 'ZNN') {
                  token = kZnnCoin;
                } else if (queryZTS == 'qsr' || queryZTS == 'QSR') {
                  token = kQsrCoin;
                } else {
                  token = await zenon.embedded.token
                      .getByZts(TokenStandard.parse(queryZTS));
                }
              }

              if (context.mounted) {
                switch (uri.host) {
                  case 'transfer':
                    sl.get<NotificationsService>().addNotification(
                          WalletNotificationsCompanion.insert(
                            title: 'Transfer action detected',
                            details: 'Deep link: $uriRaw',
                            type: NotificationType.paymentReceived,
                          ),
                        );

                    if (_isWalletUnlocked()) {
                      if (!mounted) return;
                      showSendScreen(context: context);

                      if (token != null) {
                        showDialogWithNoAndYesOptions(
                          context: context,
                          title: 'Transfer action',
                          isBarrierDismissible: true,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Are you sure you want transfer $queryAmount ${token.symbol} from $kSelectedAddress to $queryAddress?',
                              ),
                            ],
                          ),
                          onYesButtonPressed: () {
                            sendPaymentBloc.sendTransfer(
                              context: context,
                              fromAddress: kSelectedAddress!.hex,
                              toAddress: queryAddress,
                              amount:
                                  queryAmount.extractDecimals(token!.decimals),
                              token: token,
                            );
                          },
                          onNoButtonPressed: () {},
                        );
                      }
                    }

                  case 'stake':
                    sl.get<NotificationsService>().addNotification(
                          WalletNotificationsCompanion.insert(
                            title: 'Stake action detected',
                            details: 'Deep link: $uriRaw',
                            type: NotificationType.paymentReceived,
                          ),
                        );

                    if (_isWalletUnlocked()) {
                      if (!mounted) return;
                      showStakingScreen(context);

                      showDialogWithNoAndYesOptions(
                        context: context,
                        title: 'Stake ${kZnnCoin.symbol} action',
                        isBarrierDismissible: true,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Are you sure you want stake $queryAmount ${kZnnCoin.symbol} for $queryDuration month(s)?',
                            ),
                          ],
                        ),
                        onYesButtonPressed: () {
                          stakingOptionsBloc.stakeForQsr(
                            Duration(seconds: queryDuration * stakeTimeUnitSec),
                            queryAmount.extractDecimals(kZnnCoin.decimals),
                          );
                        },
                        onNoButtonPressed: () {},
                      );
                    }

                  case 'delegate':
                    sl.get<NotificationsService>().addNotification(
                          WalletNotificationsCompanion.insert(
                            title: 'Delegate action detected',
                            details: 'Deep link: $uriRaw',
                            type: NotificationType.paymentReceived,
                          ),
                        );

                    if (_isWalletUnlocked()) {
                      if (!mounted) return;
                      showDelegateScreen(context);

                      showDialogWithNoAndYesOptions(
                        context: context,
                        title: 'Delegate ${kZnnCoin.symbol} action',
                        isBarrierDismissible: true,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Are you sure you want delegate the ${kZnnCoin.symbol} from $kSelectedAddress to Pillar $queryPillarName?',
                            ),
                          ],
                        ),
                        onYesButtonPressed: () {
                          delegateButtonBloc.votePillar(queryPillarName);
                        },
                        onNoButtonPressed: () {},
                      );
                    }

                  case 'fuse':
                    sl.get<NotificationsService>().addNotification(
                          WalletNotificationsCompanion.insert(
                            title: 'Fuse ${kQsrCoin.symbol} action detected',
                            details: 'Deep link: $uriRaw',
                            type: NotificationType.paymentReceived,
                          ),
                        );

                    if (_isWalletUnlocked()) {
                      if (!mounted) return;
                      showPlasmaFusingScreen(context);
                      showDialogWithNoAndYesOptions(
                        context: context,
                        title: 'Fuse ${kQsrCoin.symbol} action',
                        isBarrierDismissible: true,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Are you sure you want fuse $queryAmount ${kQsrCoin.symbol} for address $queryAddress?',
                            ),
                          ],
                        ),
                        onYesButtonPressed: () {
                          plasmaOptionsBloc.generatePlasma(
                            queryAddress,
                            queryAmount.extractDecimals(kQsrCoin.decimals),
                          );
                        },
                        onNoButtonPressed: () {},
                      );
                    }

                  case 'sentinel':
                    sl.get<NotificationsService>().addNotification(
                          WalletNotificationsCompanion.insert(
                            title: 'Deploy Sentinel action detected',
                            details: 'Deep link: $uriRaw',
                            type: NotificationType.paymentReceived,
                          ),
                        );

                    if (_isWalletUnlocked()) {
                      //TODO: navigate to Sentinel
                    }

                  case 'pillar':
                    sl.get<NotificationsService>().addNotification(
                          WalletNotificationsCompanion.insert(
                            title: 'Deploy Pillar action detected',
                            details: 'Deep link: $uriRaw',
                            type: NotificationType.paymentReceived,
                          ),
                        );

                    if (_isWalletUnlocked()) {
                      //TODO: navigate to Pillar
                    }

                  default:
                    sl.get<NotificationsService>().addNotification(
                          WalletNotificationsCompanion.insert(
                            title: 'Incoming link detected',
                            details: 'Deep link: $uriRaw',
                            type: NotificationType.paymentReceived,
                          ),
                        );
                    break;
                }
              }
              return;
            }
          }
        },
        onDone: () {
          Logger('MainAppContainer')
              .log(Level.INFO, '_handleIncomingLinks', 'done');
        },
        onError: (Object err) {
          sendNotificationError(
            'Handle incoming link failed',
            err,
          );
          Logger('MainAppContainer')
              .log(Level.WARNING, '_handleIncomingLinks', err);
          if (!mounted) return;
        },
      );
    }
  }

  bool _isWalletUnlocked() => true;

  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await _appLinks.getInitialLink();
        if (uri != null) {
          Logger('MainAppContainer').log(Level.INFO, '_handleInitialUri $uri');
        }
        if (!mounted) return;
      } on PlatformException catch (e, stackTrace) {
        Logger('MainAppContainer').log(
          Level.WARNING,
          '_handleInitialUri',
          e,
          stackTrace,
        );
      } on FormatException catch (e, stackTrace) {
        Logger('MainAppContainer').log(
          Level.WARNING,
          '_handleInitialUri',
          e,
          stackTrace,
        );
        if (!mounted) return;
      }
    }
  }

  void _animateToHistoryScreen() {
    _navigateToPage(index: 1, pageController: _pageController!);
  }
}
