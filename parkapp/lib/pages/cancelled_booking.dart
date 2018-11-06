// External imports.
import 'package:flutter/material.dart';

// Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';

// This class builds the Cancelled Reservation screen of the application.
class CancelledReservation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new CustomFullGradient(
        color: GradientColor.Red,
        horizontalPadding: 30.0,
        child: new Stack(
          children: <Widget>[
            new Align(
              alignment: AlignmentDirectional.topStart,
              child: new IconButton(
                icon: new Icon(
                  Icons.close,
                  size: 30.0,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    Translations.of(context).text('booking_canceled'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.display1,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 13.5,
                    ),
                    child: new Text(
                      Translations.of(context).text('cancel_unable_book'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ),
                  new FlatButton(
                    splashColor: Colors.white10,
                    onPressed: () => Navigator.of(context).pop(),
                    child: new Text(
                      Translations.of(context).text('go_garage_list'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.body2.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

