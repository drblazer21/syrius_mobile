import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/buy/unwrap_signed_requests_bloc.dart';
import 'package:syrius_mobile/screens/buy_stepper_screen.dart';
import 'package:syrius_mobile/screens/unwrap_signed_requests_screen.dart';

class BuyScreen extends StatelessWidget {
  const BuyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.buy),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Buy',
              ),
              Tab(
                text: 'Pending',
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const BuyStepperScreen(),
            UnwrapSignedRequestsScreen(
              unwrapSignedRequestsBloc: UnwrapSignedRequestsBloc(),
            ),
          ],
        ),
      ),
    );
  }
}
