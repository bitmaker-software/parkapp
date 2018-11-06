// External imports
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Differentiate colors for the CustomFullGradient
enum GradientColor {
  Red,
  Green
}

// Widget used to create the gradients
class CustomBarGradient extends StatelessWidget {
  CustomBarGradient({
    Key key,
    @required this.child,
    this.backgroundImage,
  }) : super(key: key);

  final Widget child;
  final CachedNetworkImage backgroundImage;

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          colors: [const Color(0xFF43E695), const Color(0xFF3BB2B8)],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: new Stack(
        children: <Widget>[
          backgroundImage != null ?
          new Container(
            width: double.infinity,
            height: double.infinity,
            foregroundDecoration: const BoxDecoration(
              color: Colors.black38,
            ),
            child: backgroundImage,
          ) :
          null,
          child,
        ].where((widget) => widget != null).toList(),
      ),
    );
  }
}

class CustomFullGradient extends StatelessWidget {
  CustomFullGradient({
    Key key,
    this.children,
    this.horizontalPadding,
    this.child,
    @required this.color,
  }) : super(key: key);

  final List<Widget> children;
  final Widget child;
  final double horizontalPadding;
  final GradientColor color;

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: color == GradientColor.Green
            ? [const Color(0xFF43E695), const Color(0xFF3BB2B8)]
            : [const Color(0xFFFFCEAB), const Color(0xFFFF7A72)],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: new SafeArea(
        child: new Padding(
          padding: new EdgeInsets.symmetric(
            horizontal: horizontalPadding ?? 0.0,
          ),
          child: child ?? new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}