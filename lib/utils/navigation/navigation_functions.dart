import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/screens/accelerator_z/accelerator_project_details_screen.dart';
import 'package:syrius_mobile/screens/accelerator_z/accelerator_project_list_screen.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/screens/settings/delete_wallet_screen.dart';
import 'package:syrius_mobile/screens/settings/info_screen.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/accelerator/accelerator_donation_stepper.dart';
import 'package:syrius_mobile/widgets/accelerator/project_creation_stepper.dart';
import 'package:syrius_mobile/widgets/accelerator/update_phase_stepper.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();

Future<dynamic> showAcceleratorZScreen(BuildContext context) async {
  await _push(
    context,
    const AcceleratorZScreen(),
    AppRoute.acceleratorZ,
  );
}

Future<dynamic> showAcceleratorDonationStepper(BuildContext context) => _push(
      context,
      const AcceleratorDonationStepper(),
      AppRoute.acceleratorDonationStepper,
    );

Future<dynamic> showAcceleratorProjectDetailsScreen({
  required BuildContext context,
  required PillarInfo? pillarInfo,
  required AcceleratorProject project,
}) =>
    _push(
      context,
      AcceleratorProjectDetailsScreen(
        pillarInfo: pillarInfo,
        project: project,
      ),
      AppRoute.acceleratorProjectDetails,
    );

Future<dynamic> showAcceleratorProjectListScreen(BuildContext context) async {
  await _push(
    context,
    const AcceleratorProjectListScreen(),
    AppRoute.acceleratorProjectList,
  );
}

Future<dynamic> showAcceleratorStatsScreen(BuildContext context) => _push(
      context,
      const AcceleratorStats(),
      AppRoute.acceleratorStats,
    );

Future<dynamic> showAccessWalletScreen(
  BuildContext context, {
  bool isReplace = false,
}) =>
    _push(
      context,
      const AccessWalletScreen(),
      AppRoute.accessWallet,
      replaceRoute: isReplace,
    );

Future<dynamic> showActivateBiometryScreen({
  required BuildContext context,
  required String pin,
  bool onboardingFlow = true,
  RoutePredicate? predicate,
}) =>
    _push(
      context,
      ActivateBiometryScreen(
        onboardingFlow: onboardingFlow,
        pin: pin,
      ),
      AppRoute.activateBiometry,
      until: predicate,
    );

Future<dynamic> showAddNetworkScreen({
  required BuildContext context,
  required AddNetworkScreenMode mode,
  AppNetwork? appNetwork,
}) async {
  await _push(
    context,
    AddNetworkScreen(
      appNetwork: appNetwork,
      mode: mode,
    ),
    AppRoute.addNetwork,
    fullscreenDialog: true,
  );
}

Future<dynamic> showAddNewTokenScreen({
  required BuildContext context,
}) async {
  await _push(
    context,
    const AddNewTokenScreen(),
    AppRoute.addNewToken,
    fullscreenDialog: true,
  );
}

Future<dynamic> showAddStakingScreen(
  BuildContext context,
  StakingListBloc stakingListViewModel,
) =>
    _push(
      context,
      AddStakingScreen(stakingListViewModel),
      AppRoute.addStaking,
    );

Future<dynamic> showBackupWalletScreen(
  BuildContext context, {
  bool isOnboardingFlow = false,
  RoutePredicate? routePredicate,
}) async {
  await _push(
    context,
    BackupSeedScreen(
      isOnboardingFlow: isOnboardingFlow,
    ),
    AppRoute.backupSeed,
    until: routePredicate,
  );
}

Future<dynamic> showBuyScreen(
  BuildContext context, {
  RoutePredicate? routePredicate,
}) async {
  await _push(
    context,
    const BuyScreen(),
    AppRoute.buy,
    until: routePredicate,
  );
}

Future<dynamic> showBuyStepperScreen(
  BuildContext context, {
  RoutePredicate? routePredicate,
}) async {
  await _push(
    context,
    const BuyStepperScreen(),
    AppRoute.buyStepper,
    until: routePredicate,
  );
}

Future<dynamic> showConfirmBackupWalletScreen({
  required BuildContext context,
  required bool isOnboardingFlow,
}) =>
    _push(
      context,
      ConfirmBackupScreen(
        isOnboardingFlow: isOnboardingFlow,
      ),
      AppRoute.confirmBackup,
    );

Future<dynamic> showConfirmPincodeScreen({
  required BuildContext context,
  required String pin,
}) =>
    _push(
      context,
      ConfirmPincodeScreen(
        pin: pin,
      ),
      AppRoute.confirmPincode,
    );

Future<dynamic> showCreatePincodeScreen({
  required BuildContext context,
}) =>
    _push(
      context,
      CreatePincodeScreen(),
      AppRoute.createPincode,
    );

Future<dynamic> showDelegateScreen(BuildContext context) => _push(
      context,
      DelegateScreen(),
      AppRoute.delegate,
    );

Future<dynamic> showHomeScreen(BuildContext context) => _push(
      context,
      const HomeScreen(),
      AppRoute.home,
      until: (a) => false,
    );

Future<dynamic> showImportWalletScreen(BuildContext context) => _push(
      context,
      const ImportWalletScreen(),
      AppRoute.importWallet,
    );

Future<dynamic> showKeyStoreAuthentication({
  required BuildContext context,
  required void Function(String) onSuccess,
}) =>
    _push(
      context,
      KeyStoreAuthentication(onSuccess: onSuccess),
      AppRoute.keyStoreAuthentication,
    );

Future<dynamic> showManageAddressScreen(BuildContext context) => _push(
      context,
      const ManageAddressesScreen(),
      AppRoute.manageAddresses,
    );

Future<dynamic> showNotificationScreen(
  BuildContext context,
) =>
    _push(
      context,
      const NotificationScreen(),
      AppRoute.notification,
    );

Future<dynamic> showOtpCodeConfirmationScreen({
  required BuildContext context,
  void Function(String)? onCodeValid,
  String? secretKey,
}) =>
    _push(
      context,
      OtpCodeConfirmationScreen(
        onCodeValid: onCodeValid,
        secretKey: secretKey,
      ),
      AppRoute.otpCodeConfirmation,
    );

Future<dynamic> showOtpManagementScreen({
  required BuildContext context,
}) =>
    _push(
      context,
      const OtpManagementScreen(),
      AppRoute.otpManagement,
    );

Future<dynamic> showOtpScreen(
  BuildContext context, {
  bool replaceRoute = false,
}) =>
    _push(
      context,
      const OtpScreen(),
      AppRoute.otp,
      replaceRoute: replaceRoute,
    );

Future<dynamic> showPhaseCreationStepper({
  required BuildContext context,
  required Project project,
}) =>
    _push(
      context,
      PhaseCreationStepper(project),
      AppRoute.phaseCreationStepper,
    );

Future<dynamic> showPillarDetailScreen({
  required BuildContext context,
  required DelegationInfo? delegationInfo,
  required DelegationInfoBloc delegationInfoBloc,
  required PillarInfo pillarInfo,
  required PillarsListBloc pillarsListBloc,
}) =>
    _push(
      context,
      PillarDetailScreen(
        delegationInfo: delegationInfo,
        pillarInfo: pillarInfo,
        bloc: pillarsListBloc,
        delegationInfoBloc: delegationInfoBloc,
      ),
      AppRoute.pillarDetail,
    );

Future<dynamic> showPlasmaFusingScreen(
  BuildContext context,
) =>
    _push(
      context,
      const PlasmaFusingScreen(),
      AppRoute.plasmaFusing,
    );

Future<dynamic> showPlasmaListScreen(BuildContext context) => _push(
      context,
      const PlasmaListScreen(),
      AppRoute.plasmaList,
    );

Future<dynamic> showProjectCreationStepper(BuildContext context) => _push(
      context,
      const ProjectCreationStepper(),
      AppRoute.projectCreationStepper,
    );

Future<dynamic> showScreenshotScreen({
  required BuildContext context,
}) =>
    _push(
      context,
      const ScreenshotScreen(),
      AppRoute.screenshot,
    );

Future<dynamic> showDeleteWalletScreen({
  required BuildContext context,
}) =>
    _push(
      context,
      const DeleteWalletScreen(),
      AppRoute.deleteWallet,
    );

Future<dynamic> showEditBtcTxFeePerByt({
  required BigInt balance,
  required BuildContext context,
  required double feePerByte,
  required BigInt txValue,
  required int txSize,
}) async =>
    _push(
      context,
      EditBtcTxFeePerByteScreen(
        balance: balance,
        feePerByte: feePerByte,
        txValue: txValue,
        txSize: txSize,
      ),
      AppRoute.editGasFee,
      fullscreenDialog: true,
    );

Future<void> showEditGasFeeScreen({
  required BuildContext context,
  required EthereumTxGasDetailsData data,
  required GasFeeDetailsBloc gasFeeDetailsBloc,
}) async {
  await _push(
    context,
    EditGasFeeScreen(
      data: data,
      gasFeeDetailsBloc: gasFeeDetailsBloc,
    ),
    AppRoute.editGasFee,
    fullscreenDialog: true,
  );
}

Future<dynamic> showInfoScreen({
  required BuildContext context,
}) =>
    _push(
      context,
      const InformationScreen(),
      AppRoute.infoScreen,
    );

Future<dynamic> showSendScreen({
  required BuildContext context,
}) =>
    _push(
      context,
      const SendScreen(),
      AppRoute.send,
    );

Future<dynamic> showSendBtcScreen({
  required BuildContext context,
}) =>
    _push(
      context,
      const SendBtcScreen(),
      AppRoute.sendBtc,
    );

Future<dynamic> showSendEthScreen({
  required BuildContext context,
}) =>
    _push(
      context,
      const SendEthScreen(),
      AppRoute.sendEth,
    );

Future<dynamic> showStakingScreen(BuildContext context) => _push(
      context,
      const StakingScreen(),
      AppRoute.staking,
    );

Future<dynamic> showSyriusAddressScanner({
  required BuildContext context,
  required void Function(String) onScan,
}) =>
    _push(
      context,
      SyriusAddressScanner(
        context: context,
        onScan: onScan,
      ),
      AppRoute.syriusAddressScanner,
    );

Future<dynamic> showUpdatePhaseStepper({
  required BuildContext context,
  required Phase phase,
  required Project project,
}) =>
    _push(
      context,
      UpdatePhaseStepper(phase, project),
      AppRoute.updatePhaseStepper,
    );

Future<dynamic> showWalletConnectCodeScanner({
  required BuildContext context,
  required void Function(String) onScan,
}) =>
    _push(
      context,
      WalletConnectCodeScanner(
        onScan: onScan,
      ),
      AppRoute.walletConnectCodeScanner,
    );

Future<dynamic> showWalletConnectScreen(BuildContext context) => _push(
      context,
      const WalletConnectScreen(),
      AppRoute.walletConnect,
    );

PageTransition _getPageTransition({
  required RouteSettings routeSettings,
  required Widget child,
  required bool fullscreenDialog,
}) {
  return PageTransition(
    alignment: Alignment.center,
    fullscreenDialog: fullscreenDialog,
    settings: routeSettings,
    type: PageTransitionType.theme,
    child: child,
  );
}

bool _isCurrentRoute({required RouteSettings routeSettings}) {
  const String impossibleRandomRouteName = 'znn';

  final String currentRouteName =
      currentRoute?.settings.name ?? impossibleRandomRouteName;

  return currentRouteName == routeSettings.name;
}

Future<dynamic> _push(
  BuildContext ctx,
  Widget screen,
  AppRoute appRoute, {
  bool replaceRoute = false,
  RoutePredicate? until,
  bool fullscreenDialog = false,
}) async {
  final settings = RouteSettings(name: '/${appRoute.name}');

  final bool isCurrentRoute = _isCurrentRoute(routeSettings: settings);

  if (!isCurrentRoute) {
    final destinationRoute = _getPageTransition(
      child: screen,
      routeSettings: settings,
      fullscreenDialog: fullscreenDialog,
    );

    if (until != null) {
      return Navigator.of(ctx).pushAndRemoveUntil(
        destinationRoute,
        until,
      );
    } else if (replaceRoute) {
      return Navigator.of(ctx).pushReplacement(destinationRoute);
    } else {
      return Navigator.of(ctx).push(destinationRoute);
    }
  }
}
