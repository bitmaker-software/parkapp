// External imports.
import 'package:flutter/material.dart';

// Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';
import '../components/rounded_circular_indicator.dart';

// This class builds the Ending Reservation Time screen of the application.
class EndingBooking extends StatefulWidget {
  EndingBooking({
    Key key,
    @required this.park,
    @required this.minutesLeft,
    @required this.timeLeft
  }) : super(key: key);

  final String park;
  final int minutesLeft;
  final String timeLeft;

  @override
  State<StatefulWidget> createState() => new EndingBookingState();
}

class EndingBookingState extends State<EndingBooking> {
  // Declarations.
  String timeLeft;
  int minutesLeft;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    timeLeft = widget.timeLeft;
    minutesLeft = widget.minutesLeft;
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new CustomFullGradient(
        color: GradientColor.Red,
        child: MediaQuery.of(context).size.height >= 640 ?
        new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 22.0,
          ),
          child: new Column(
            children: <Widget>[
              new Align(
                alignment: AlignmentDirectional.topStart,
                child: new IconButton(
                  icon: new Icon(
                    Icons.close,
                    size: 30.0,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: new Column(
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 42.0, 0.0, 33.8),
                        child: new Text(
                          Translations.of(context).text('booking_ending')
                          + widget.park + '!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.display1,
                        ),
                      ),
                      new Expanded(
                        child: new Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            new AspectRatio(
                              aspectRatio: 1.0,
                              child: new SizedBox(
                                height: double.infinity,
                                child: new CircularProgressIndicator(
                                  value: 1.0,
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 20.0,
                                ),
                              ),
                            ),
                            new AspectRatio(
                              aspectRatio: 1.0,
                              child: new SizedBox(
                                height: double.infinity,
                                child: new RoundedCircularProgressIndicator(
                                  value: minutesLeft / 30,
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                    Color(0xFFF3534A),
                                  ),
                                  strokeWidth: 20.0,
                                ),
                              ),
                            ),
                            new Text(
                              timeLeft,
                              style: Theme.of(context).textTheme.display4.copyWith(
                                fontSize: 48.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(
                          top: 33.8,
                          bottom: 131.0,
                        ),
                        child: new Text(
                          Translations.of(context).text('warning_unable_book'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subhead,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ) : new ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 22.0,
          ),
          physics: const ClampingScrollPhysics(),
          children: <Widget>[
            new Align(
              alignment: AlignmentDirectional.topStart,
              child: new IconButton(
                icon: new Icon(
                  Icons.close,
                  size: 30.0,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 42.0, 0.0, 33.8),
                    child: new Text(
                      Translations.of(context).text('booking_ending') + widget.park + '!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.display1,
                    ),
                  ),
                  new Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      new SizedBox(
                        height: 210.0,
                        width: 210.0,
                        child: new CircularProgressIndicator(
                          value: 1.0,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 20.0,
                        ),
                      ),
                      new SizedBox(
                        height: 210.0,
                        width: 210.0,
                        child: new RoundedCircularProgressIndicator(
                          value: minutesLeft / 30,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            Color(0xFFF3534A),
                          ),
                          strokeWidth: 20.0,
                        ),
                      ),
                      new Text(
                        timeLeft,
                        style: Theme.of(context).textTheme.display4.copyWith(
                          fontSize: 48.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(
                      top: 33.8,
                      bottom: 42.0,
                    ),
                    child: new Text(
                      Translations.of(context).text('warning_unable_book'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subhead,
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