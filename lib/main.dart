import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';
import 'package:secp256r1/secp256r1.dart';
import 'package:secure_content/secure_content.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/blocs/wallet_connect/i_chain.dart';
import 'package:syrius_mobile/blocs/wallet_connect/nom_service.dart';
import 'package:syrius_mobile/l10n/all_locales.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/services/syrius_navigator_observer.dart';
import 'package:syrius_mobile/utils/notifiers/backed_up_seed_notifier.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

GetIt sl = GetIt.instance;

late IWeb3WalletService web3WalletService;
late SecureStorageUtil secureStorageUtil;
late SharedPrefsService sharedPrefsService;
late Zenon zenon;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  Provider.debugCheckInvalidValueType = null;

  ensureDirectoriesExist();
  Hive.init((await getZnnDefaultCacheDirectory()).path);

  // Setup logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord record) {
    if (kDebugMode) {
      print(
          '${record.level.name} ${record.loggerName} ${record.message} ${record.time}: '
          '${record.error} ${record.stackTrace}\n');
    }
  });

  // Register Hive adapters
  Hive.registerAdapter(NotificationTypeAdapter());
  Hive.registerAdapter(WalletNotificationAdapter());

  // Setup WalletConnect
  web3WalletService = Web3WalletService();
  web3WalletService.create();
  await retry(
    () async => await web3WalletService.init(),
    retryIf: (e) => e is SocketException || e is TimeoutException,
  );

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
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => NotificationsProvider(),
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
  sl.registerSingleton<SyriusNavigatorObserver>(SyriusNavigatorObserver());
  sl.registerSingleton<Zenon>(Zenon());

  // The variable is used by other dependencies, so we need to set it up early
  zenon = sl<Zenon>();

  sl.registerLazySingletonAsync<SharedPrefsService>(
    () => SharedPrefsService.getInstance().then((value) => value!),
  );

  sl.registerSingleton<PowGeneratingStatusBloc>(PowGeneratingStatusBloc());
  sl.registerSingleton<AutoReceiveTxWorker>(AutoReceiveTxWorker());
  sl.registerSingleton<PlasmaStatsBloc>(PlasmaStatsBloc());
  sl.registerSingleton<BalanceBloc>(BalanceBloc());
  sl.registerSingleton<ZenonToolsPriceBloc>(ZenonToolsPriceBloc());
  sl.registerSingleton<HideBalanceBloc>(HideBalanceBloc());
  sl.registerSingleton<LatestTransactionsBloc>(
    LatestTransactionsBloc(),
  );
  sl.registerSingleton<NotificationsBloc>(NotificationsBloc());
  sl.registerSingleton<PlasmaListBloc>(PlasmaListBloc());

  // WalletConnect
  sl.registerSingleton<IWeb3WalletService>(web3WalletService);
  sl.registerSingleton<IChain>(
    NoMService(reference: NoMChainId.mainnet),
    instanceName: NoMChainId.mainnet.chain(),
  );
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
  sharedPrefsService = await sl.getAsync<SharedPrefsService>();

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
  late NotificationsBloc _notificationsBloc;

  @override
  void initState() {
    super.initState();
    _notificationsBloc = sl.get<NotificationsBloc>();
    _notificationsBloc.stream.listen(
      (WalletNotification? value) {
        if (mounted) {
          context.read<NotificationsProvider>().getNotificationsFromDb();
          showNotificationSnackBar(
            navState.currentState!.context,
            walletNotification: value,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    const Color backgroundColor = Color.fromARGB(255, 15, 15, 15);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      background: backgroundColor,
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
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          centerTitle: true,
        ),
        cardTheme: const CardTheme(
          margin: EdgeInsets.zero,
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
    _notificationsBloc.dispose();
    sl.unregister();
    super.dispose();
  }
}
