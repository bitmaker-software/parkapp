// External imports.
import 'package:flutter/material.dart';

// Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';

// This class builds the Cancelled Subscription screen of the application.
class SubscriptionCancelled extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new CustomFullGradient(
      color: GradientColor.Red,
      horizontalPadding: 40.0,
      children: <Widget>[
        new Text(
          Translations.of(context).text('subscription_cancelled'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        new Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: new FlatButton(
            splashColor: Colors.white10,
            onPressed: () => print('Do stuff!'),
            child: new Text(
              Translations.of(context).text('back_to_subscriptions'),
              style: Theme.of(context).textTheme.body2
                  .copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}