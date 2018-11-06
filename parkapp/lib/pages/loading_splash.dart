// External imports.
import 'package:flutter/material.dart';

//Internal imports.
import '../utils/styles.dart';

// This widget shows the application loading screen.
class LoadingSplash extends StatefulWidget {
  LoadingSplash({
    Key key,
  }) : super(key: key);

  @override
  LoadingSplashState createState() => LoadingSplashState();
}

class LoadingSplashState extends State<LoadingSplash> with SingleTickerProviderStateMixin {
  // Initializations
  AnimationController _animationController;
  Animation<double> _animation;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(seconds: 1), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: themeColor,
      child: new Center(
        child: new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Image(
              image: new AssetImage('lib/assets/app_icon.png'),
            ),
            new Padding(
              padding: const EdgeInsets.only(
                top: 219.0,
              ),
              child: new FadeTransition(
                opacity: _animation,
                child: new SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: new CircularProgressIndicator(
                    strokeWidth: 6.0,
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
