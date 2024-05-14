import 'package:flutter/material.dart';

// Main colors
const znnColor = Color.fromARGB(255, 120, 250, 90);
const qsrColor = Color.fromARGB(255, 40, 50, 250);

// App related
const String kBundleId = 'network.zenon.syrius.mobile';

// Wallet
const String kWalletVersion = '0.2.3';
const int kNumOfInitialAddresses = 1;

// WalletConnect
const String kWcProjectId = '6106aa8c2f308b338f31465bef999a1f';
const String kZenonNameSpace = 'zenon';

// API endpoints
const String kZenonToolsPriceEndpoint = 'https://api.zenon.tools/nom-data';
const String kZenonToolsPillarsEndpoint = 'https://api.zenon.tools/pillars';

// Links
const String kZenonHubExplorer = 'https://zenonhub.io';
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
const String kDefaultNode = 'wss://my.hc1node.com:35998';
const List<String> kCommunityNodes = [
  kDefaultNode,
];

// Widget related
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

// Boxes
const String kAddressesBox = 'addresses_box';
const String kAddressLabelsBox = 'address_labels_box';
const String kNotificationsBox = 'notifications_box';
const String kRecipientAddressBox = 'recipient_address_box';
const String kSharedPrefsBox = 'shared_prefs_box';
const String kNodesBox = 'nodes_box';

// Shared prefs keys
const String kPinCoolDownSecondsLeftKey = 'pinCoolDownSecondsLeft';
const String kLastTimeSeedWasShownKey = 'lastTimeSeedWasShown';
const String kPinLoggingFailedAttemptsKey = 'pinLoggingFailedAttempts';
const String kEntropyFilePathKey = 'entropyFilePathKey';
const String kSelectedNodeKey = 'selectedNodeKey';
const String kDefaultAddressKey = 'defaultAddress';
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

// Secure storage keys
const String kChainIdKey = 'chainId';
const String kKeyStoreKey = 'keyStore';

// Operation amounts
const int kPillarPlasmaAmountNeeded = 252000;
const int kSentinelPlasmaAmountNeeded = 252000;
const int kStakePlasmaAmountNeeded = 105000;
const int kDelegatePlasmaAmountNeeded = 84000;
const int kIssueTokenPlasmaAmountNeeded = 189000;

// Text field constants
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

// Display constants
const ThemeMode kDefaultThemeMode = ThemeMode.dark;

// Duration constants
const Duration kIntervalBeforeMomentumRefresh = Duration(
  seconds: 10,
);
const Duration kDelayAfterBlockCreationCall = Duration(
  seconds: 31,
);
const double kStandardChartNumDays = 7;
