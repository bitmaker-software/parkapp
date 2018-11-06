// External imports.
import 'package:flutter/material.dart';

//Internal imports.
import '../components/app_bars.dart';
import '../utils/translations.dart';
import '../pages/trips_tab.dart';
import '../pages/payment_tab.dart';
import '../pages/subscriptions_tab.dart';
import '../main.dart';

// This widget shows the login screen or, if you are already logged in,
// your account details.
class Account extends StatelessWidget {
  Account({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set Account page tab names.
    final List<String> tabs = [
      Translations.of(context).text('trips'),
      Translations.of(context).text('payment'),
      Translations.of(context).text('subscriptions'),
    ];

    return new Scaffold(
      appBar: new TabsAppBar(
        tabController: Base.of(context).tabController,
        action: Translations.of(context).text('account_action'),
        tabs: tabs,
      ),
      body: new TabBarView(
        controller: Base.of(context).tabController,
        children: <Widget>[
          new Trips(
            pastTrips: Base.of(context).pastTrips,
            onTripsChanged: Base.of(context).onTripsChanged,
          ),
          new Payment(),
          new Subscriptions(),
        ],
      )
    );
  }
}