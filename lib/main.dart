import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';
import 'package:secp256r1/secp256r1.dart';
import 'package:secure_content/secure_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/btc/bitcoin_service.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/eth_support/ethereum_service.dart';
import 'package:syrius_mobile/l10n/all_locales.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/services/syrius_navigator_observer.dart';
import 'package:syrius_mobile/utils/notifiers/backed_up_seed_notifier.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

GetIt sl = GetIt.instance;

late IWeb3WalletService web3WalletService;
late SecureStorageUtil secureStorageUtil;
late SharedPreferences sharedPrefs;
late Zenon zenon;
late EthereumService eth;
late BitcoinService btc;
late Database db;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  Provider.debugCheckInvalidValueType = null;

  ensureDirectoriesExist();

  // Setup logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord record) {
    if (kDebugMode) {
      print(
          '${record.level.name} ${record.loggerName} ${record.message} ${record.time}: '
          '${record.error} ${record.stackTrace}\n');
    }
  });

  // Setup services
  setup();
  await initGlobalServices();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<HistoryScreenControllerNotifier>(
          create: (_) => HistoryScreenControllerNotifier(),
        ),
        ChangeNotifierProvider<SelectedAddressNotifier>(
          create: (_) => SelectedAddressNotifier(),
        ),
        ChangeNotifierProvider<SelectedNetworkNotifier>(
          create: (_) => SelectedNetworkNotifier(),
        ),
        ChangeNotifierProvider<ScreenshotFeatureNotifier>(
          create: (_) => ScreenshotFeatureNotifier(),
        ),
        ChangeNotifierProvider<BackedUpSeedNotifier>(
          create: (_) => BackedUpSeedNotifier(),
        ),
      ],
      child: Portal(
        child: Consumer<ScreenshotFeatureNotifier>(
          builder: (_, notifier, __) {
            // If screenshot is enabled, then the content is not secure
            final bool isSecure = !notifier.isEnabled;

            return SecureWidget(
              isSecure: isSecure,
              builder: (_, __, ___) => const MyApp(),
            );
          },
        ),
      ),
    ),
  );
}

void setup() {
  // Notifications
  sl.registerSingleton<NotificationsService>(NotificationsService());

  // Ethereum
  sl.registerSingleton<EthereumService>(
    EthereumServiceImpl(),
  );

  // Bitcoin
  sl.registerSingleton<BitcoinService>(BitcoinService());

  sl.registerSingleton<SyriusNavigatorObserver>(SyriusNavigatorObserver());
  sl.registerSingleton<Zenon>(Zenon());

  // The variable is used by other dependencies, so we need to set it up early
  zenon = sl<Zenon>();

  eth = sl.get<EthereumService>();
  btc = sl.get<BitcoinService>();

  sl.registerSingleton<BtcActivityBloc>(BtcActivityBloc());
  sl.registerSingleton<GasPriceBloc>(GasPriceBloc());
  sl.registerSingleton<BtcEstimateFeeBloc>(BtcEstimateFeeBloc());
  sl.registerSingleton<PowGeneratingStatusBloc>(PowGeneratingStatusBloc());
  sl.registerSingleton<AutoReceiveTxWorker>(AutoReceiveTxWorker());
  sl.registerSingleton<PlasmaStatsBloc>(PlasmaStatsBloc());
  sl.registerSingleton<BalanceBloc>(BalanceBloc());
  sl.registerSingleton<EthAccountBalanceBloc>(EthAccountBalanceBloc());
  sl.registerSingleton<BtcAccountBalanceBloc>(BtcAccountBalanceBloc());
  sl.registerSingleton<PriceInfoBloc>(PriceInfoBloc());
  sl.registerSingleton<HideBalanceBloc>(HideBalanceBloc());
  sl.registerSingleton<LatestTransactionsBloc>(
    LatestTransactionsBloc(),
  );
  sl.registerSingleton<PlasmaListBloc>(PlasmaListBloc());

  // WalletConnect
  sl.registerSingleton<WalletConnectPairingBloc>(WalletConnectPairingBloc());
  sl.registerSingleton<WalletConnectPairingsBloc>(
    WalletConnectPairingsBloc(),
  );
  sl.registerSingleton<WalletConnectSessionsBloc>(
    WalletConnectSessionsBloc(),
  );

  // PIN
  sl.registerSingleton<PinExponentialBackoffService>(
    PinExponentialBackoffService(
      sequenceAttempts: 5,
      maxAttempts: 20,
    ),
  );

  // OTP
  sl.registerSingleton<OTPService>(
    OTPService(),
  );
}

Future<void> initGlobalServices() async {
  // Setup SharedPrefs
  sharedPrefs = await SharedPreferences.getInstance();

  // Drift
  db = Database();

  final int numOfSavedAppNetworks = await db.managers.appNetworks.count();

  if (numOfSavedAppNetworks == 0) {
    for (final network in kDefaultAppNetworks) {
      final int id = await db.appNetworksDao.insert(network);
      if (network == kEthereumMainnetNetwork) {
        final List<NetworkAssetsCompanion> assetsWithForeignKey =
            kDefaultEthereumMainnetAssets
                .map(
                  (e) => e.copyWith(network: Value(id)),
                )
                .toList();

        await db.networkAssetsDao.insertMultiple(assetsWithForeignKey);
      }
      if (network == kSepoliaNetwork) {
        final NetworkAssetsCompanion assetWithForeignKey =
            kSepoliaCurrency.copyWith(
          network: Value(id),
        );

        await db.networkAssetsDao.insert(assetWithForeignKey);
      }
      if (network == kSupernovaNetwork) {
        final NetworkAssetsCompanion assetWithForeignKey =
            kSupernovaZvmCurrency.copyWith(
          network: Value(id),
        );

        await db.networkAssetsDao.insert(assetWithForeignKey);
      }
      if (network == kBitcoinSignet) {
        final NetworkAssetsCompanion assetWithForeignKey =
            kBitcoinSignetCurrency.copyWith(
          network: Value(id),
        );

        await db.networkAssetsDao.insert(assetWithForeignKey);
      }
      if (network == kBitcoinMainnet) {
        final NetworkAssetsCompanion assetWithForeignKey =
            kBitcoinMainnetCurrency.copyWith(
          network: Value(id),
        );

        await db.networkAssetsDao.insert(assetWithForeignKey);
      }
    }
    await db.bookmarksDao.insertMultiple(kDefaultBookmarks);

    final AppNetwork defaultAppNetwork =
        await db.managers.appNetworks.filter((f) => f.id(1)).getSingle();

    sharedPrefs.setInt(kSelectedAppNetworkIdKey, defaultAppNetwork.id);
  }

  final int? selectedAppNetworkId =
      sharedPrefs.getInt(kSelectedAppNetworkIdKey);

  final AppNetwork selectedAppNetwork = await db.managers.appNetworks
      .filter((f) => f.id(selectedAppNetworkId!))
      .getSingle();

  final List<NetworkAsset> selectAppNetworkAssets =
      await db.networkAssetsDao.getAllByNetworkId(selectedAppNetwork.id);

  kSelectedAppNetworkWithAssets = (
    assets: selectAppNetworkAssets,
    network: selectedAppNetwork,
  );

  // Setup WalletConnect
  web3WalletService = Web3WalletService();
  web3WalletService.create();
  await retry(
    () async => await web3WalletService.init(),
    retryIf: (e) => e is SocketException || e is TimeoutException,
  );
  sl.registerSingleton<IWeb3WalletService>(web3WalletService);

  // Setup SecureStorage
  secureStorageUtil = SecureStorageUtil();
  await secureStorageUtil.initSecureStorage();
  final String pinLoggingFailedAttempts = await secureStorageUtil.read(
    kPinLoggingFailedAttemptsKey,
    defaultValue: '0',
  );

  sl.get<PinExponentialBackoffService>().attemptsCounter =
      int.parse(pinLoggingFailedAttempts);

  if (Platform.isAndroid) {
    kIsStrongboxSupported = await SecureP256.isStrongboxSupported();
  }

  final List<BiometricType> availableBiometryList =
      await AuthenticationService().getAvailableBiometry();
  if (availableBiometryList.contains(BiometricType.face)) {
    kBiometricTypeSupport = BiometricType.face;
  } else {
    kBiometricTypeSupport = BiometricType.fingerprint;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> with LifecycleMixin {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    const Color surfaceColor = Color.fromARGB(255, 15, 15, 15);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      surface: surfaceColor,
      brightness: Brightness.dark,
      seedColor: znnColor,
    );

    return MaterialApp(
      title: 'Syrius Mobile',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      navigatorKey: navState,
      navigatorObservers: [
        sl.get<SyriusNavigatorObserver>(),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: surfaceColor,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceColor,
          centerTitle: true,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
        ),
        cardTheme: const CardTheme(
          margin: EdgeInsets.zero,
        ),
        chipTheme: ChipThemeData(
          labelStyle: const TextStyle(color: Colors.white),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
        colorScheme: colorScheme,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
        fontFamily: 'Inter',
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
        ),
        iconTheme: IconThemeData(
          color: colorScheme.primary,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            borderSide: BorderSide(
              width: 0.5,
            ),
          ),
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          dense: false,
          iconColor: colorScheme.primary,
          leadingAndTrailingTextStyle: context.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          titleTextStyle: context.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(
              color: colorScheme.primary,
            ),
          ),
        ),
        tabBarTheme: const TabBarTheme(
          dividerHeight: 0.0,
        ),
        textTheme: context.textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: kAllLocales,
      locale: kDefaultLocale,
      home: const SplashScreen(),
    );
  }

  @override
  void onAppShow() {
    Logger('MyAppState').log(Level.INFO, 'onAppShow');
  }

  @override
  void onAppHide() {
    Logger('MyAppState').log(Level.INFO, 'onAppHide');
  }

  @override
  void onAppResume() {
    Logger('MyAppState').log(Level.INFO, 'onAppResume');
  }

  @override
  void onAppPause() {
    Logger('MyAppState').log(Level.INFO, 'onAppPause');
  }

  @override
  void onAppInactive() {
    Logger('MyAppState').log(Level.INFO, 'onAppInactive');
  }

  @override
  void onAppRestart() {
    Logger('MyAppState').log(Level.INFO, 'onAppRestart');
  }

  @override
  Future<void> onAppDetach() async {
    Logger('MyAppState').log(Level.INFO, 'onAppDetach');
    // Clear keyStore from secureStorageUtil
    await secureStorageUtil.delete(
      key: kKeyStoreKey,
    );
  }

  @override
  Future<AppExitResponse> onExitAppRequest() async {
    Logger('MyAppState').log(Level.INFO, 'onExitAppRequest');
    // Clear keyStore from secureStorageUtil
    await secureStorageUtil.delete(
      key: kKeyStoreKey,
    );
    return super.onExitAppRequest();
  }

  @override
  void dispose() {
    sl.unregister();
    super.dispose();
  }
}
