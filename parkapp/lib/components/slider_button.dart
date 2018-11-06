// External imports
import 'package:flutter/material.dart';

//Internal imports.
import '../utils/styles.dart';

// Cupertino like slider button
class SliderButton extends StatelessWidget {
  SliderButton({
    Key key,
    @required this.leftLabel,
    @required this.rightLabel,
    @required this.state,
    @required this.onTap,
  }) : super(key: key);

  final String leftLabel;
  final String rightLabel;
  final bool state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return new OutlineButton(
      padding: const EdgeInsets.all(0.0),
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(20.0),
      ),
      borderSide: const BorderSide(
        color: themeColor,
        width: 2.0,
      ),
      highlightColor: Colors.transparent,
      onPressed: () {
        onTap();
      },
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.symmetric(
              vertical: 11.0,
              horizontal: 20.0,
            ),
            decoration: new BoxDecoration(
              color: state ? themeColor : Colors.white,
              borderRadius: new BorderRadius.circular(20.0),
            ),
            child: new Text(
              leftLabel,
              style: Theme.of(context).textTheme.display2.copyWith(
                color: state ? Colors.white : themeColor,
              ),
            ),
          ),
          new Container(
            padding: const EdgeInsets.symmetric(
              vertical: 11.0,
              horizontal: 20.0,
            ),
            decoration: new BoxDecoration(
              color: !state ? themeColor : Colors.white,
              borderRadius: new BorderRadius.circular(20.0),
            ),
            child: new Text(
              rightLabel,
              style: Theme.of(context).textTheme.display2.copyWith(
                color: !state ? Colors.white : themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}