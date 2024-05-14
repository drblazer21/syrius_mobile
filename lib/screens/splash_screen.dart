import 'package:flutter/material.dart';
import 'package:syrius_mobile/screens/key_store_authentication.dart';
import 'package:syrius_mobile/utils/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return KeyStoreAuthentication(
      initializeApp: true,
      onSuccess: (_) => _onSuccess(),
    );
  }

  void _onSuccess() {
    showHomeScreen(context);
  }
}
