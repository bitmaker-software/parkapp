// External imports.
import 'package:flutter/material.dart';

// Internal imports.
import '../utils/translations.dart';
import '../components/gradients.dart';
import '../utils/socket.dart';
import '../main.dart';

// This class builds the Processing Payment screen of the application.
class WaitingEnter extends StatefulWidget {
  WaitingEnter({
    Key key,
  }) : super(key: key);

  @override
  WaitingEnterState createState() => new WaitingEnterState();
}
class WaitingEnterState extends State<WaitingEnter> {
  // Declarations.
  Socket _socket;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _socket = new Socket();
    _socket.init(Base.of(context));
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    super.dispose();
  }

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
            Translations.of(context).text('waiting_enter'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 85.0,
          ),
          child: new Text(
            Translations.of(context).text('minutes_to_enter'),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}