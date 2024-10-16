import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:syrius_mobile/database/app_network_asset_entries.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/model/model.dart';

// Main colors
const znnColor = Color.fromARGB(255, 120, 250, 90);
const qsrColor = Color.fromARGB(255, 40, 50, 250);
const kNoMAnimateGradientPrimaryColors = [
  Color.fromARGB(255, 2, 46, 16),
  Color.fromARGB(255, 11, 206, 60),
  Color.fromARGB(255, 70, 235, 111),
];
const kNoMAnimateGradientSecondaryColors = [
  Color.fromARGB(255, 6, 21, 140),
  Color.fromARGB(255, 10, 90, 195),
  Color.fromARGB(255, 24, 231, 217),
];
const kBtcAnimateGradientPrimaryColors = [
  Color.fromARGB(255, 255, 153, 0),
  Color.fromARGB(255, 209, 139, 0),
];
const kBtcAnimateGradientSecondaryColors = [
  Color.fromARGB(255, 228, 149, 71),
  Color.fromARGB(255, 255, 217, 0),
];
const kEthAnimateGradientPrimaryColors = [
  Color.fromARGB(255, 72, 203, 217),
  Color.fromARGB(255, 20, 4, 77),
];
const kEthAnimateGradientSecondaryColors = [
  Color.fromARGB(255, 198, 197, 212),
  Color.fromARGB(255, 55, 54, 123),
];

// App related
const String kBundleId = 'network.zenon.syrius.mobile';

// Wallet
const String kWalletVersion = '0.5.2';
const int kNumOfInitialAddresses = 1;

// WalletConnect
const String kWcProjectId = '6106aa8c2f308b338f31465bef999a1f';
const String kZenonNameSpace = 'zenon';

// API endpoints
const String kPriceInfoApi = 'https://api.hc1.tools/price';
const String kZenonToolsPillarsEndpoint = 'https://api.zenon.tools/pillars';

// Links
const String kBtcMainnetExplorer = 'https://mempool.space/tx/';
const String kBtcSignetExplorer = 'https://mempool.space/signet/tx/';
const String kZenonMainnetExplorer =
    'https://zenonhub.io/explorer/transaction/';
const String kZenonTestnetExplorer =
    'https://explorer.zenon.network/transaction/';
const String kEthereumMainnetExplorer = 'https://etherscan.io/tx/';
const String kEthereumTestnetExplorer = 'https://sepolia.etherscan.io/tx/';
const String kSupernovaExplorer = 'https://novascan.io/transaction/';
const String kZenonTools = 'https://zenon.tools/overview';
const String kSyriusDesktopGithub =
    'https://github.com/zenon-network/syrius/releases/latest';
const String kSyriusMobileGithub =
    'https://github.com/drblazer21/syrius_mobile/releases/latest';
const String kJailbrokenWiki = 'https://wikipedia.org/wiki/IOS_jailbreaking';
const String kRootedWiki = 'https://wikipedia.org/wiki/Rooting_(Android)';
const String kReddit = 'https://www.reddit.com/r/Zenon_Network/';
const String kCoinGecko = 'https://www.coingecko.com/en/coins/zenon';
const String kTelegram = 'https://t.me/zenonnetwork';
const String kDiscord = 'https://discord.com/invite/zenonnetwork';
const String kGithub = 'https://github.com/zenon-network';
const String kTwitterX = 'https://twitter.com/Zenon_Network';
const String kOrgForum = 'https://forum.zenon.org/';
const String kHyperCoreForum = 'https://forum.hypercore.one/';
const String kMedium = 'https://medium.com/@zenon.network';

// Node related
final AppNetworksCompanion kZnnMainnetNetwork = AppNetworksCompanion.insert(
  assets: AppNetworkAssetEntries(items: []),
  blockChain: BlockChain.nom,
  blockExplorerUrl: kZenonMainnetExplorer,
  chainId: const Value(1),
  currencySymbol: 'ZNN',
  name: 'Zenon',
  url: 'wss://my.hc1node.com:35998',
  type: NetworkType.mainnet,
);
final AppNetworksCompanion kZnnTestnetNetwork = AppNetworksCompanion.insert(
  assets: AppNetworkAssetEntries(items: []),
  blockChain: BlockChain.nom,
  blockExplorerUrl: kZenonTestnetExplorer,
  chainId: const Value(3),
  currencySymbol: 'ZNN',
  name: 'Zenon Testnet',
  url: 'wss://syrius-testnet.zenon.community:443',
  type: NetworkType.testnet,
);
final AppNetworksCompanion kEthereumMainnetNetwork =
    AppNetworksCompanion.insert(
  assets: AppNetworkAssetEntries(items: []),
  blockChain: BlockChain.evm,
  blockExplorerUrl: kEthereumMainnetExplorer,
  chainId: const Value(1),
  currencySymbol: 'ETH',
  name: 'Ethereum',
  url: 'https://ethereum-rpc.publicnode.com',
  type: NetworkType.mainnet,
);
final AppNetworksCompanion kSepoliaNetwork = AppNetworksCompanion.insert(
  assets: AppNetworkAssetEntries(items: []),
  blockChain: BlockChain.evm,
  blockExplorerUrl: kEthereumTestnetExplorer,
  chainId: const Value(11155111),
  currencySymbol: 'sETH',
  name: 'Sepolia',
  url: 'https://rpc.sepolia.org',
  type: NetworkType.testnet,
);
final AppNetworksCompanion kSupernovaNetwork = AppNetworksCompanion.insert(
  assets: AppNetworkAssetEntries(items: []),
  blockChain: BlockChain.evm,
  blockExplorerUrl: kSupernovaExplorer,
  chainId: const Value(73405),
  currencySymbol: 'xZNN',
  name: 'Supernova ZVM',
  url: 'https://rpc.novascan.io',
  type: NetworkType.mainnet,
);
final AppNetworksCompanion kBitcoinSignet = AppNetworksCompanion.insert(
  assets: AppNetworkAssetEntries(items: []),
  blockChain: BlockChain.btc,
  blockExplorerUrl: kBtcSignetExplorer,
  currencySymbol: 'sBTC',
  name: 'Bitcoin Signet',
  url: 'https://mempool.space:60602',
  type: NetworkType.testnet,
);
final AppNetworksCompanion kBitcoinMainnet = AppNetworksCompanion.insert(
  assets: AppNetworkAssetEntries(items: []),
  blockChain: BlockChain.btc,
  blockExplorerUrl: kBtcMainnetExplorer,
  currencySymbol: 'BTC',
  name: 'Bitcoin Mainnet',
  url: 'https://electrum.blockstream.info:50002',
  type: NetworkType.mainnet,
);
final List<AppNetworksCompanion> kDefaultAppNetworks = [
  kZnnMainnetNetwork,
  kZnnTestnetNetwork,
  kEthereumMainnetNetwork,
  kSepoliaNetwork,
  kSupernovaNetwork,
  kBitcoinSignet,
  kBitcoinMainnet,
];

// Widget related
const Size kAcceleratorProgressBarSize = Size(250.0, 10.0);
const double kDefaultBorderOutlineWidth = 1.0;
const double kHorizontalPagePaddingDimension = 20.0;
const double kDefaultPageCardLateralPadding = 16.0;
const SizedBox kVerticalSpacer = SizedBox(
  height: 15.0,
);
const SizedBox kHorizontalSpacer = SizedBox(
  width: 15.0,
);
const SizedBox kTwentyVerticalSpacer = SizedBox(
  height: 20.0,
);
const SizedBox kIconAndTextHorizontalSpacer = SizedBox(
  width: 8.0,
);

// Shared prefs keys
const String kPriceInfoApiResponseKey = 'priceInfoApiResponse';
// In milliseconds
const String kPriceInfoApiResponseTimestampKey =
    'priceInfoApiResponseTimestampKey';
const String kPinCoolDownSecondsLeftKey = 'pinCoolDownSecondsLeft';
const String kLastTimeSeedWasShownKey = 'lastTimeSeedWasShown';
const String kPinLoggingFailedAttemptsKey = 'pinLoggingFailedAttempts';
const String kEntropyFilePathKey = 'entropyFilePathKey';
const String kDefaultAppAddressIdKey = 'defaultAddress';
const String kEthDefaultAppAddressIdKey = 'eth_$kDefaultAppAddressIdKey';
const String kBtcTestDefaultAppAddressIdKey =
    'btc_test_$kDefaultAppAddressIdKey';
const String kBtcTaprootDefaultAppAddressIdKey =
    'btc_taproot_$kDefaultAppAddressIdKey';
const String kIsBackedUpKey = 'isBackup';
const String kIsHideBalanceKey = 'isHideBalance';
const String kEncryptWalletWithBiometryKey = 'encryptWalletWithBiometry';
const String kIsScreenshotFeatureEnabledKey = 'isScreenshotFeatureEnabled';
const String kWasOtpSecretKeyStoredKey = 'wasOtpSecretKeyStored';
const String kOtpSecretKey = 'otpSecretKey';
const String kUseOtpForTxConfirmationKey = 'useOtpForTxConfirmation';
const String kUseOtpForRevealingSeedKey = 'useOtpForRevealingSeed';
const String kUseOtpForModifyingBiometryUseKey =
    'useOtpForModifyingBiometryUse';
const String kUseOtpForDeletingWalletKey = 'useOtpFoDeletingWallet';
const String kSelectedAppNetworkIdKey = 'selectedAppNetworkId';

// Secure storage keys
const String kChainIdKey = 'chainId';
const String kEthChainIdKey = 'eth$kChainIdKey';
const String kBtcChainIdKey = 'btc$kChainIdKey';
const String kKeyStoreKey = 'keyStore';

// Operation amounts
const int kPillarPlasmaAmountNeeded = 252000;
const int kSentinelPlasmaAmountNeeded = 252000;
const int kStakePlasmaAmountNeeded = 105000;
const int kDelegatePlasmaAmountNeeded = 84000;
const int kIssueTokenPlasmaAmountNeeded = 189000;
final BigInt kMinimumWeiNeededForSwapping = BigInt.from(100000000000000);

// Text field constants
final BigInt kGasLimitMinUnits = BigInt.from(21000);
const int kNetworkAssetSymbolMaxLength = 11;
const int kNetworkAssetSymbolMinLength = 3;
const int kNetworkAssetNameMaxLength = 35;
const int kNetworkAssetNameMinLength = 3;
const int kAmountInputMaxCharacterLength = 21;
const int kAddressLabelMaxLength = 80;

const List<int> kUserPlasmaRequirements = [
  kStakePlasmaAmountNeeded,
  kDelegatePlasmaAmountNeeded,
  kIssueTokenPlasmaAmountNeeded,
];
const List<int> kPowerUserPlasmaRequirements = [
  kPillarPlasmaAmountNeeded,
  kSentinelPlasmaAmountNeeded,
  kIssueTokenPlasmaAmountNeeded,
];

// Notifications constants
const int kNotificationsResultLimit = 100;
const int kWalletNotificationHiveTypeId = 100;
const int kNotificationTypeEnumHiveTypeId = 101;
const int kEthTransactionHiveTypeId = 102;

// Display constants
const ThemeMode kDefaultThemeMode = ThemeMode.dark;

// Duration constants
const kFeeRefreshInterval = Duration(seconds: 30);
const kPriceInfoResponseCacheDuration = Duration(minutes: 15);
const Duration kProjectVotingPeriod = Duration(days: 14);
const Duration kIntervalBeforeMomentumRefresh = Duration(
  seconds: 10,
);
const Duration kDelayAfterBlockCreationCall = Duration(
  seconds: 31,
);
const Duration kEthereumBlockProductionInterval = Duration(
  seconds: 14,
);
const double kStandardChartNumDays = 7;

// Bitcoin
const kBtcDecimals = 8;

// Ethereum
const kEvmCurrencyDecimals = 18;
const kGweiDecimals = 9;

// Swap ETH to ZNN
const String kWznnAddress = '0x5eC73005957670ae7fAF3F7b086A38d5fcf3C55B';
const String kWethAddress = '0x30847457Bf6dff337061CfDB2BB187C022fD035f';
const String kProxyAddress = '0xDd83e8Fc329B3e88494396DFd0E72960181992a0';
const String kBridgeAddress = '0x45ae269bdead62cd69e8acdb5d5dfd3dba4f541c';

// Default bookmarks
final List<BookmarksCompanion> kDefaultBookmarks = [
  BookmarksCompanion.insert(
    faviconUrl: const Value('https://app.uniswap.org/favicon.png'),
    title: 'Uniswap',
    url:
        'https://app.uniswap.org/swap?outputCurrency=0xb2e96a63479c2edd2fd62b382c89d5ca79f572d3',
  ),
  BookmarksCompanion.insert(
    faviconUrl: const Value('https://cdn.1inch.io/logo.png'),
    title: '1inch',
    url:
        'https://app.1inch.io/#/1/simple/swap/ETH/0xb2e96a63479c2edd2fd62b382c89d5ca79f572d3',
  ),
  BookmarksCompanion.insert(
    faviconUrl: const Value('https://kyberswap.com/logo-dark.svg'),
    title: 'Kyber',
    url: 'https://kyberswap.com/swap/ethereum/eth-to-wznn',
  ),
];

// Drift Database
// Might need to be increased for other blockchain types
const int kAddressHexMaxLength = 42;
const String kDatabaseName = 'syrius_db';
