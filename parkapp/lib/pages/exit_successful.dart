// External imports.
import 'package:flutter/material.dart';

// Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';

// This class builds the Successful Exit screen of the application.
class ExitSuccessful extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new CustomFullGradient(
      color: GradientColor.Green,
      horizontalPadding: 30.0,
      children: <Widget>[
        new Text(
          Translations.of(context).text('thank_you'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
      ],
    );
  }
}