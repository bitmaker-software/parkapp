// External imports
import 'package:flutter/material.dart';
import 'dart:async';

// Internal imports
import '../utils/translations.dart';
import '../utils/styles.dart';

// For showing the payment dialog when needed.
class PaymentDialog extends StatefulWidget {
  PaymentDialog({
    Key key,
    @required this.duration,
    @required this.amount,
  }) : super(key: key);

  final String duration;
  final String amount;

  @override
  State<StatefulWidget> createState() => new PaymentDialogState();
}

class PaymentDialogState extends State<PaymentDialog> {
  // Initializations
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form.
  // Note: This is a `GlobalKey<FormState>`, not a GlobalKey<MyCustomFormState>!
  GlobalKey<FormState> _paymentModalFormKey;
  bool _autoValidate;
  String _phoneNumber;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _paymentModalFormKey = new GlobalKey<FormState>();
    _autoValidate = false;
    _phoneNumber = "";
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(
              24.0, 24.0, 17.0, 0.0
          ),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new ImageIcon(
                    new AssetImage('lib/assets/clock.png'),
                    color: themeColor,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(
                      left: 5.0,
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          widget.duration,
                          style: Theme.of(context).textTheme.body2.copyWith(
                            color: themeDarkGrey,
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(
                            top: 5.0,
                          ),
                          child: new Text(
                            Translations.of(context).text('duration'),
                            style: Theme.of(context).textTheme.caption.copyWith(
                              color: themeLightGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              new Container(
                width: 100.0,
                height: 50.0,
                alignment: AlignmentDirectional.center,
                decoration: new BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [const Color(0xFFFFCEAB), const Color(0xFFFF7A72)],
                    begin: const FractionalOffset(1.0, 0.0),
                    end: const FractionalOffset(0.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                  borderRadius: new BorderRadius.circular(8.0),
                ),
                child: new Text(
                  widget.amount + '€',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.display4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              new Image(
                image: new AssetImage(
                  'lib/assets/mbway.png',
                ),
              ),
            ],
          ),
        ),
        new Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 24.0),
          child: new Form(
            key: _paymentModalFormKey,
            autovalidate: _autoValidate,
            child: new Theme(
              data: Theme.of(context).copyWith(
                hintColor: themeLightGrey,
              ),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new TextFormField(
                    keyboardType: TextInputType.phone,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                          .text('phone_number'),
                      labelStyle: Theme.of(context).textTheme.body2
                          .copyWith(
                        color: themeColor,
                      ),
                      hintText: '(+351) 9x xxx xxxx',
                      hintStyle: Theme.of(context).textTheme.body2
                          .copyWith(
                        color: themeLightGrey,
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return Translations.of(context)
                            .text('error_phone_number');
                      }
                      final RegExp nameExp = new RegExp(
                          r'^(\+351|00351)?[\s|\-|\.]?[2|9][\s|\-|\.]'
                          r'?([0-9][\s|\-|\.]?){8}$'
                      );
                      if (!nameExp.hasMatch(value)) {
                        // The phone number is invalid.
                        return Translations.of(context)
                            .text('error_valid_phone_number');
                      }
                    },
                    onSaved: (String value) {
                      _phoneNumber = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          child: new SizedBox(
            height: 50.0,
            child: new FlatButton(
              color: themeColor,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
              ),
              splashColor: themeColor[400],
              onPressed: () async{
                final _form = _paymentModalFormKey.currentState;
                if(_form.validate()){
                  _form.save();
                  Navigator.of(context).pop(_phoneNumber);
                }
                else {
                  setState(() {
                    _autoValidate = true;
                  });
                }
              },
              child: new Text(
                Translations.of(context).text('confirm_payment'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subhead.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        new DecoratedBox(
          decoration: new BoxDecoration(
            border: new Border(
              top: new BorderSide(
                color: themeLightGrey,
                width: 1.0,
              ),
            ),
          ),
          child: new SizedBox(
            height: 50.0,
            child: new FlatButton(
              splashColor: Colors.red[200],
              onPressed: () => Navigator.of(context).pop(),
              child: new Text(
                Translations.of(context).text('cancel_payment'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subhead.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Below is the usage for this function, you'll only have to import this file
/// [radius] takes a double and will be the radius to the rounded corners of this modal
/// [color] will color the modal itself, the default being `Colors.white`
/// [builder] takes the content of the modal, if you're using [Column]
/// or a similar widget, remember to set `mainAxisSize: MainAxisSize.min`
/// so it will only take the needed space.
///
/// ```dart
/// showRoundedModalBottomSheet(
///    context: context,
///    radius: 10.0,  // This is the default
///    color: Colors.white,  // Also default
///    builder: (context) => ???,
/// );
/// ```
Future<T> showRoundedModalBottomSheet<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  Color color = Colors.white,
  double radius = 10.0,
}) {
  assert(context != null);
  assert(builder != null);
  assert(radius != null && radius > 0.0);
  assert(color != null && color != Colors.transparent);
  return Navigator.push<T>(
      context,
      _RoundedCornerModalRoute<T>(
        builder: builder,
        color: color,
        radius: radius,
        barrierLabel:
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ));
}

class _RoundedModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _RoundedModalBottomSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return new BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return new Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_RoundedModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _RoundedCornerModalRoute<T> extends PopupRoute<T> {
  _RoundedCornerModalRoute({
    this.builder,
    this.barrierLabel,
    this.color,
    this.radius,
    RouteSettings settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final double radius;
  final Color color;

  @override
  Color get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String barrierLabel;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) => CustomSingleChildLayout(
            delegate: _RoundedModalBottomSheetLayout(animation.value),
            child: BottomSheet(
              animationController: _animationController,
              onClosing: () => Navigator.pop(context),
              builder: (context) => new GestureDetector(
                // Dismiss keyboard and un-focus fields.
                onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
                  decoration: BoxDecoration(
                    color: this.color,
                    borderRadius: BorderRadius.all(
                      Radius.circular(this.radius),
                    ),
                  ),
                  child: SafeArea(child: Builder(builder: this.builder)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);
}