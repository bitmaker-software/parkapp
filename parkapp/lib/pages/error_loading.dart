// External imports.
import 'package:flutter/material.dart';

// Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';
import '../main.dart';

// This class builds the Loading Error screen of the application.
class ErrorLoading extends StatelessWidget {
  ErrorLoading({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new CustomFullGradient(
      color: GradientColor.Red,
      horizontalPadding: 30.0,
      children: <Widget>[
        new Text(
          ParkApp.of(context).translationsLoaded ?
          Translations.of(context).text('loading_error') :
          "An error has occurred! Please try again later.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        ParkApp.of(context).errorButtonLoading ?
        new Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 6.0,
          ),
          child: new CircularProgressIndicator(),
        ) :
        new Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: new FlatButton(
            splashColor: Colors.white10,
            onPressed: () {
              ParkApp.of(context).setErrorButtonLoading(true);
              ParkApp.of(context).appInit();
            },
            child: new Text(
              ParkApp.of(context).translationsLoaded ?
              Translations.of(context).text('try_again') :
              "Try again",
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