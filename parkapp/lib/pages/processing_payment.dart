// External imports.
import 'package:flutter/material.dart';

// Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';

// This class builds the Processing Payment screen of the application.
class ProcessingPayment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new CustomFullGradient(
      color: GradientColor.Green,
      horizontalPadding: 30.0,
      children: <Widget>[
        const SizedBox(
          width: 125.0,
          height: 125.0,
          child: const CircularProgressIndicator(
            strokeWidth: 12.0,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(
            top: 35.0,
            bottom: 22.0,
            left: 20.0,
            right: 20.0,
          ),
          child: new Text(
            Translations.of(context).text('processing_payment'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 85.0,
          ),
          child: new Text(
            Translations.of(context).text('minutes_to_exit'),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}