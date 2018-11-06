// External imports.
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Overrides the normal circular progress indicator to be fully customizable.
const double _kMinCircularProgressIndicatorSize = 36.0;

class _CircularProgressIndicatorPainter extends CustomPainter {
  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;
  // Canvas.drawArc(r, 0, 2*PI) doesn't draw anything, so just get close.
  static const double _sweep = _twoPi - _epsilon;
  static const double _startAngle = -math.pi / 2.0;

  _CircularProgressIndicatorPainter({
    this.valueColor,
    this.value,
    this.headValue,
    this.tailValue,
    this.stepValue,
    this.rotationValue,
    this.strokeWidth,
  }) : arcStart = value != null
      ? _startAngle
      : _startAngle + tailValue * 3 / 2 * math.pi + rotationValue * math.pi * 1.7 - stepValue * 0.8 * math.pi,
        arcSweep = value != null
            ? value.clamp(0.0, 1.0) * _sweep
            : math.max(headValue * 3 / 2 * math.pi - tailValue * 3 / 2 * math.pi, _epsilon);

  final Color valueColor;
  final double value;
  final double headValue;
  final double tailValue;
  final int stepValue;
  final double rotationValue;
  final double strokeWidth;
  final double arcStart;
  final double arcSweep;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    //if (value == null) // Indeterminate
    //  paint.strokeCap = StrokeCap.square;

    canvas.drawArc(Offset.zero & size, arcStart, arcSweep, false, paint);
  }

  @override
  bool shouldRepaint(_CircularProgressIndicatorPainter oldPainter) {
    return oldPainter.valueColor != valueColor
        || oldPainter.value != value
        || oldPainter.headValue != headValue
        || oldPainter.tailValue != tailValue
        || oldPainter.stepValue != stepValue
        || oldPainter.rotationValue != rotationValue
        || oldPainter.strokeWidth != strokeWidth;
  }
}

/// A material design circular progress indicator, which spins to indicate that
/// the application is busy.
///
/// A widget that shows progress along a circle. There are two kinds of circular
/// progress indicators:
///
///  * _Determinate_. Determinate progress indicators have a specific value at
///    each point in time, and the value should increase monotonically from 0.0
///    to 1.0, at which time the indicator is complete. To create a determinate
///    progress indicator, use a non-null [value] between 0.0 and 1.0.
///  * _Indeterminate_. Indeterminate progress indicators do not have a specific
///    value at each point in time and instead indicate that progress is being
///    made without indicating how much progress remains. To create an
///    indeterminate progress indicator, use a null [value].
///
/// See also:
///
///  * [LinearProgressIndicator]
///  * <https://material.google.com/components/progress-activity.html#progress-activity-types-of-indicators>
class RoundedCircularProgressIndicator extends ProgressIndicator {
  /// Creates a circular progress indicator.
  ///
  /// The [value] argument can be either null (corresponding to an indeterminate
  /// progress indicator) or non-null (corresponding to a determinate progress
  /// indicator). See [value] for details.
  const RoundedCircularProgressIndicator({
    Key key,
    double value,
    Color backgroundColor,
    Animation<Color> valueColor,
    this.strokeWidth = 4.0
  }) : super(key: key, value: value, backgroundColor: backgroundColor, valueColor: valueColor);

  /// The width of the line used to draw the circle.
  final double strokeWidth;

  @override
  _RoundedCircularProgressIndicatorState createState() => _RoundedCircularProgressIndicatorState();
}

// Tweens used by circular progress indicator
final Animatable<double> _kStrokeHeadTween = CurveTween(
  curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
).chain(CurveTween(
  curve: const SawTooth(5),
));

final Animatable<double> _kStrokeTailTween = CurveTween(
  curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
).chain(CurveTween(
  curve: const SawTooth(5),
));

final Animatable<int> _kStepTween = StepTween(begin: 0, end: 5);

final Animatable<double> _kRotationTween = CurveTween(curve: const SawTooth(5));

class _RoundedCircularProgressIndicatorState extends State<RoundedCircularProgressIndicator> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    if (widget.value == null)
      _controller.repeat();
  }

  @override
  void didUpdateWidget(RoundedCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating)
      _controller.repeat();
    else if (widget.value != null && _controller.isAnimating)
      _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator(BuildContext context, double headValue, double tailValue, int stepValue, double rotationValue) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: _kMinCircularProgressIndicatorSize,
        minHeight: _kMinCircularProgressIndicatorSize,
      ),
      child: CustomPaint(
        painter: _CircularProgressIndicatorPainter(
          valueColor: widget.valueColor?.value ?? Theme.of(context).accentColor,
          value: widget.value, // may be null
          headValue: headValue, // remaining arguments are ignored if widget.value is not null
          tailValue: tailValue,
          stepValue: stepValue,
          rotationValue: rotationValue,
          strokeWidth: widget.strokeWidth
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return _buildIndicator(
          context,
          _kStrokeHeadTween.evaluate(_controller),
          _kStrokeTailTween.evaluate(_controller),
          _kStepTween.evaluate(_controller),
          _kRotationTween.evaluate(_controller),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null)
      return _buildIndicator(context, 0.0, 0.0, 0, 0.0);
    return _buildAnimation();
  }
}