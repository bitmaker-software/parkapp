// External imports.
import 'package:flutter/material.dart';

// Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';
import '../utils/styles.dart';

// This class builds the Close to Park Alert screen of the application.
class DirectionsAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new CustomFullGradient(
      color: GradientColor.Green,
      horizontalPadding: 30.0,
      children: <Widget>[
        new Text(
          Translations.of(context).text('near_park'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        new Padding(
          padding: const EdgeInsets.only(
            top: 30.0,
            bottom: 20.0,
            left: 10.0,
            right: 10.0,
          ),
          child: new SizedBox(
            width: double.infinity,
            height: 50.0,
            child: new FlatButton(
              color: Colors.white,
              splashColor: themeColor[200],
              shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () => print('Do stuff!'),
              child: new Text(
                Translations.of(context).text('directions_button'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subhead
                    .copyWith(
                  color: Color(0xFF41DF9A),
                ),
              ),
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(
            bottom: 10.0,
          ),
          child: new Text(
            Translations.of(context).text('find_entrance'),
          ),
        ),
        new FlatButton(
          splashColor: Colors.white10,
          onPressed: () => print('Do stuff!'),
          child: new Text(
            Translations.of(context).text('get_directions'),
            style: Theme.of(context).textTheme.body2
                .copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}