// External imports.
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:map_view/map_view.dart';
import 'dart:async';

//Internal imports.
import '../components/map.dart';
import '../components/app_bars.dart';
import '../components/rounded_circular_indicator.dart';
import '../pages/ending_booking.dart';
import '../pages/cancelled_booking.dart';
import '../main.dart';
import '../utils/network.dart';
import '../utils/socket.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';

// This class lets you check the current state of the booking associated.
class BookingDetails extends StatefulWidget {
  BookingDetails({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new BookingDetailsState();
}

class BookingDetailsState extends State<BookingDetails> {
  // Declarations.
  ViewMap _map;
  Socket _socket;
  RestApi _api;
  DateTime _expiryTime;
  DateTime _startedAt;
  DateFormat _formatStart;
  Timer _timer;
  String _timePassed;
  String _park;
  bool _openingMap;
  Map _destination;
  int _minutesLeft;
  bool _openedEndingBooking;
  bool _loadingCancel;
  ScrollController _scrollController;
  //starting opacity position
  final double _defaultTopMargin = 211.0;
  //pixels from top where opacity should start
  final double _opacityStart = 100.0;
  //pixels from top where opacity should end
  final double _opacityEnd = 60.0;
  //starting title opacity
  double _opacity = 0.0;
  // This is needed to control the state of the modal because it only builds
  // once when the payment button is pressed as we cant pass dynamic parameters.
  GlobalKey<EndingBookingState> _endingBookingState;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _map = new ViewMap();
    _socket = new Socket();
    _api = new RestApi();
    _socket.init(Base.of(context));
    _endingBookingState = new GlobalKey<EndingBookingState>();
    _openingMap = false;
    _loadingCancel = false;
    _openedEndingBooking = false;
    _scrollController = new ScrollController();
    // Used to update screen every time the scroll moves.
    _scrollController.addListener(() => setState(() {
      if (_scrollController.hasClients) {
        double offset = _scrollController.offset;
        if (offset < _defaultTopMargin - _opacityStart) {
          //offset small => don't opacity up
          _opacity = 0.0;
        } else if (offset < _defaultTopMargin - _opacityEnd) {
          //offset between opacityStart and opacityEnd => opacity up
          _opacity =
          (offset - (_defaultTopMargin - _opacityStart)) /
          (_opacityStart - _opacityEnd);
        } else {
          //offset passed opacityEnd => show title
          _opacity = 1.0;
        }
      }
    }));
    _park = "Parque Trindade";
    _destination = {"lat": 41.150680, "long": -8.609585};
    _formatStart = new DateFormat.Hm();
    _startedAt = DateTime.parse(Base.of(context).bookingStartDate).toLocal();
    _expiryTime = _startedAt.add(const Duration(minutes: 29, seconds: 58));
    setTimePassed();
    _timer = new Timer.periodic(const Duration(minutes: 1), (_timer) {
      setTimePassed();
    });
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Gets the time passed.
  void setTimePassed(){
    // Needs the "+ 1" .difference only counts full minutes and that means it
    // never starts at 30 and when it reaches 0 it still has the seconds of that
    // minute to enter.
    if(_expiryTime.difference(DateTime.now()).isNegative) {
      _minutesLeft = 0;
    }
    else {
      _minutesLeft = _expiryTime.difference(DateTime.now()).inMinutes + 1;
    }
    setState(()  {
      _timePassed =
      "${(_minutesLeft / 60).floor().toString().padLeft(2, '0')}:"
      "${(_minutesLeft % 60).toString().padLeft(2, '0')}";
    });
    if(_minutesLeft <= 5){
      if(_endingBookingState.currentState == null && !_openedEndingBooking) {
        _openedEndingBooking = true;
        // The next line is needed because the application can be opened when
        // the user is in the last 5 minutes limit and the popup needs to be
        // called instantly. This waits for the parent to build before pushing.
        WidgetsBinding.instance.addPostFrameCallback((_) =>
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) =>
              new EndingBooking(
                key: _endingBookingState,
                park: _park,
                minutesLeft: _minutesLeft,
                timeLeft: _timePassed,
              ),
            ),
          ),
        );
      }
      else if(_endingBookingState.currentState != null){
        _endingBookingState.currentState.setState(() {
          _endingBookingState.currentState.minutesLeft = _minutesLeft;
          _endingBookingState.currentState.timeLeft = _timePassed;
        });
      }
    }
  }

  // Sets the openingMap variable to control the button loading animation.
  void setOpenMap(bool value) {
    setState(() {
      _openingMap = value;
    });
  }

  // Sets the loadingCancel variable to control the button loading animation.
  void setLoadingCancel(bool value) {
    setState(() {
      _loadingCancel = value;
    });
  }

  // Cancels the booking.
  void cancelBooking() {
    setLoadingCancel(true);
    _api.cancelReservation().then((_) {
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) =>
          new CancelledReservation(),
        ),
      );
      Base.of(context).onPageChanged(1);
      Base.of(context).setAppState(0);
    })
    .catchError((e) {
      setLoadingCancel(false);
      handleError(context, e);
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Widget commonChildren = new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(
            top: 40.0,
            bottom: 15.0,
          ),
          child: new SizedBox(
            height: 50.0,
            width: double.infinity,
            child: new FlatButton(
              color: themeColor,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
              ),
              splashColor: themeColor[400],
              onPressed: () {
                if(!_openingMap) {
                  _map.showMap(
                    context: context,
                    mapMode: 'CAR',
                    park: _park,
                    destinationLocation: new Location(
                      _destination['lat'],
                      _destination['long'],
                    ),
                    setOpeningMap: setOpenMap,
                    isStepsScreen: false,
                  );
                }
              },
              child: _openingMap ?
              new CircularProgressIndicator(
                strokeWidth: 3.0,
              ) :
              new Text(
                Translations.of(context).text('get_directions_park'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subhead.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        new ButtonTheme(
          height: 35.0,
          child: new FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            splashColor: themeColor[200],
            onPressed: () {
              if(!_loadingCancel) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                  new CupertinoAlertDialog(
                    title: new Text(
                      Translations.of(context).text('cancel_booking'),
                      style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    content: new Padding(
                      padding: const EdgeInsets.only(
                        top: 25.0,
                      ),
                      child: new Text(
                        Translations.of(context).text(
                            'cancel_are_you_sure'),
                        style: Theme.of(context).textTheme.display2.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      new ButtonTheme(
                        height: 44.0,
                        child: new FlatButton(
                          materialTapTargetSize: MaterialTapTargetSize
                              .shrinkWrap,
                          splashColor: Colors.red[200],
                          child: new Text(
                            Translations.of(context).text('cancel_go_back'),
                            style: Theme.of(context).textTheme.subhead
                                .copyWith(
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      new ButtonTheme(
                        height: 44.0,
                        padding: const EdgeInsets.all(0.0),
                        child: new FlatButton(
                          materialTapTargetSize: MaterialTapTargetSize
                              .shrinkWrap,
                          splashColor: themeColor[200],
                          child: new Text(
                            Translations.of(context).text('cancel_want'),
                            style: Theme.of(context).textTheme.subhead
                                .copyWith(
                              color: Color(0xFFF3534A),
                            ),
                          ),
                          onPressed: () => cancelBooking(),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            child: _loadingCancel ?
            new Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
              ),
              child: new SizedBox(
                height: 25.0,
                width: 25.0,
                child: new CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    themeColor,
                  ),
                  strokeWidth: 2.0,
                ),
              ),
            ) :
            new Text(
              Translations.of(context).text('cancel_booking'),
              style: Theme.of(context).textTheme.body1.copyWith(
                decoration: TextDecoration.underline,
                color: Color(0xFF3BB2B8),
              ),
            ),
          ),
        ),
      ],
    );

    Widget bottomWidget = new Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 30.0,
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Text(
            _park,
            style: Theme.of(context).textTheme.display3.copyWith(
              color: Colors.white70,
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
            ),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new DecoratedBox(
                      decoration: new BoxDecoration(
                        color: Colors.white30,
                        borderRadius: new BorderRadius.circular(5.0),
                      ),
                      child: new Padding(
                        padding: const EdgeInsets.fromLTRB(
                            13.0, 15.0, 13.0, 11.0
                        ),
                        child: new Text(
                          _formatStart.format(
                              _expiryTime.add(const Duration(seconds: 2))
                          ),
                          style: Theme.of(context).textTheme.display4,
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                        left: 11.0,
                      ),
                      child: new Text(
                        Translations.of(context).text('booking_expiry_time'),
                      ),
                    ),
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text(
                      Translations.of(context).text('started_at'),
                      style: Theme.of(context).textTheme.body1.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                      ),
                      child: new Text(
                        _formatStart.format(_startedAt),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return new Scaffold(
      appBar: MediaQuery.of(context).size.height >= 640 ? BigAppBar(
        title: Translations.of(context).text('booking_details'),
        bottomWidget: bottomWidget,
      ) : null,
      body: MediaQuery.of(context).size.height >= 640 ?
      new Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 15.0),
        child: new Column(
          children: <Widget>[
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
                          themeLightGrey,
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
                        value: _minutesLeft / 30,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          themeColor,
                        ),
                        strokeWidth: 20.0,
                      ),
                    ),
                  ),
                  new Text(
                    _timePassed,
                    style: Theme.of(context).textTheme.display4.copyWith(
                      fontSize: 48.0,
                      color: themeDarkGrey,
                    ),
                  ),
                ],
              ),
            ),
            commonChildren,
          ],
        ),
      ) : new NestedScrollView(
        controller: _scrollController,
        key: const PageStorageKey('booking_details_page'),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
          new SliverBigAppBar(
            title: Translations.of(context).text('booking_details'),
            titleOpacity: _opacity,
            bottomWidget: bottomWidget,
          ),
        ],
        body: new ListView(
          key: const PageStorageKey('booking_details'),
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 15.0),
          children: <Widget>[
            new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    new SizedBox(
                      height: 210.0,
                      width: 210.0,
                      child: new CircularProgressIndicator(
                        value: 1.0,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          themeLightGrey,
                        ),
                        strokeWidth: 20.0,
                      ),
                    ),
                    new SizedBox(
                      width: 210.0,
                      height: 210.0,
                      child: new RoundedCircularProgressIndicator(
                        value: _minutesLeft / 30,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          themeColor,
                        ),
                        strokeWidth: 20.0,
                      ),
                    ),
                    new Text(
                      _timePassed,
                      style: Theme.of(context).textTheme.display4.copyWith(
                        fontSize: 48.0,
                        color: themeDarkGrey,
                      ),
                    ),
                  ],
                ),
                commonChildren,
              ],
            ),
          ],
        ),
      ),
    );
  }
}