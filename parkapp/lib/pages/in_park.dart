//External imports.
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:intl/intl.dart';
import 'dart:async';

//Internal imports.
import '../components/app_bars.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';
import '../components/map.dart';
import '../components/dialogs.dart';
import '../utils/network.dart';
import '../main.dart';
import '../utils/socket.dart';

// This class shows all the info when the user is already inside the park.
class InPark extends StatefulWidget {
  InPark({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new InParkState();
}

class InParkState extends State<InPark> {
  // Initializations
  ViewMap _map;
  RestApi _api;
  Timer _timer;
  DateFormat _formatStart;
  DateFormat _formatUpdate;
  bool _loadingPay;
  bool _openingMap;
  String _amount;
  String _timePassed;
  DateTime _startDate;
  DateTime _updateDate;
  String _park;
  Map _destination;
  ScrollController _scrollController;
  //starting opacity position
  final double _defaultTopMargin = 116.0;
  //pixels from top where opacity should start
  final double _opacityStart = 106.0;
  //pixels from top where opacity should end
  final double _opacityEnd = 60.0;
  //starting title opacity
  double _opacity = 0.0;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _map = new ViewMap();
    _api = new RestApi();
    _formatStart = new DateFormat.Hm();
    _formatUpdate = new DateFormat("dd/MM/yyyy HH:mm:ss");
    _updateDate = new DateTime.now();
    _loadingPay = false;
    _openingMap = false;
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
    _amount = Base.of(context).amount;
    _startDate = DateTime.parse(Base.of(context).startDate).toLocal();
    initInfo();
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Sets up the update info call timer and calculates the.
  void initInfo() {
    setTimePassed();
    setTimer();
  }

  // Sets the update timer and reset if needed.
  void setTimer([bool reset = false]) {
    if(reset){
      _timer.cancel();
    }
    _timer = new Timer.periodic(const Duration(minutes: 1), (_timer) {
      getInfo();
    });
  }

  // Gets the reservation info.
  void getInfo() {
    _api.getReservationInfo().then((dynamic _info) {
      setTimePassed();
      setState(() {
        _amount = _info['amount'] ?? "- ";
        _updateDate = new DateTime.now();
      });
    })
    .catchError((e) {
      handleError(context, e);
    });
  }

  // Gets the time passed.
  void setTimePassed(){
    int _minutesPassed = DateTime.now().difference(_startDate).inMinutes;
    _timePassed =
    "${(_minutesPassed / 60).floor().toString().padLeft(2, '0')}:"
    "${(_minutesPassed % 60).toString().padLeft(2, '0')}";
  }

  // Sets the openingMap variable to control the button loading animation.
  void setOpenMap(bool value) {
    setState(() {
      _openingMap = value;
    });
  }

  // Sets the loadingPay variable to control the button loading animation.
  void setLoadingPay(bool value) {
    setState(() {
      _loadingPay = value;
    });
  }

  // Sets the payment values for showing in payment modal.
  void setPayment([VoidCallback finalAction]) {
    _api.setReservationPayment().then((dynamic _reservationAmount) {
      setTimePassed();
      setState(() {
        _amount = _reservationAmount ?? "- ";
        _updateDate = new DateTime.now();
      });
      if(finalAction != null) {
        finalAction();
      }
    })
    .catchError((e) {
      setLoadingPay(false);
      handleError(context, e);
    });
  }

  // Call payment request.
  void makePayment(String phoneNumber) {
    setState(() {
      _loadingPay = true;
    });
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if(Socket().isConnected) {
          return _api.makeReservationPayment(phoneNumber);
        }
        else {
          throw new Exception("There is a problem with the connection.");
        }
      },
    )
    .catchError((e) {
      setLoadingPay(false);
      getInfo();
      setTimer();
      handleError(context, e);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = new ListView(
      key: const PageStorageKey('in_park'),
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 0.0),
      children: <Widget>[
        new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  _formatUpdate.format(_updateDate),
                  style: Theme.of(context).textTheme.body1.copyWith(
                    color: themeLightGrey,
                  ),
                ),
                new ButtonTheme(
                  minWidth: 5.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: new FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: CircleBorder(),
                    child: new Icon(
                      Icons.refresh,
                      color: themeLightGrey,
                    ),
                    onPressed: () {
                      getInfo();
                      setTimer(true);
                    },
                  ),
                ),
              ],
            ),
            new Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                new Image(
                  height: MediaQuery.of(context).size.height >= 640 ?
                  178.0 + (MediaQuery.of(context).size.height-640)
                      : 228.0,
                  image: new AssetImage(
                    'lib/assets/loader.gif',
                  ),
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      _timePassed,
                      style: Theme.of(context).textTheme.display4.copyWith(
                        fontSize: 48.0,
                        color: themeDarkGrey,
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 5.0,
                      ),
                      child: new Text(
                        Translations.of(context).text('started_at'),
                        style: Theme.of(context).textTheme.body1.copyWith(
                          color: themeLightGrey,
                        ),
                      ),
                    ),
                    new Text(
                      _formatStart.format(_startDate),
                      style: Theme.of(context).textTheme.display3.copyWith(
                        color: themeGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 30.0,
              ),
              child: new Container(
                width: 109.0,
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
                  _amount + '€',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.display4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            new SizedBox(
              width: double.infinity,
              height: 50.0,
              child: new FlatButton(
                color: themeColor,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                splashColor: themeColor[400],
                onPressed: () {
                  if(!_loadingPay) {
                    setLoadingPay(true);
                    setPayment(() async {
                      _timer.cancel();
                      String _phoneNumber = await showRoundedModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) => new PaymentDialog(
                          duration: _timePassed,
                          amount: _amount,
                        ),
                      ) ?? '';
                      setLoadingPay(false);
                      if(_phoneNumber.isNotEmpty) {
                        makePayment(_phoneNumber);
                      }
                      else {
                        getInfo();
                        setTimer();
                      }
                    });
                  }
                },
                child: _loadingPay ?
                new CircularProgressIndicator(
                  strokeWidth: 3.0,
                ) :
                new Text(
                  Translations.of(context).text('pay_leave'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 15.0,
              ),
              child: new ButtonTheme(
                height: 35.0,
                child: new FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashColor: themeColor[200],
                  onPressed: () {
                    _map.showMap(
                      context: context,
                      mapMode: 'WALK',
                      park: _park,
                      destinationLocation: new Location(
                        _destination['lat'],
                        _destination['long'],
                      ),
                      setOpeningMap: setOpenMap,
                      isStepsScreen: false,
                    );
                  },
                  child: _openingMap ?
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
                    Translations.of(context).text('get_directions_park'),
                    style: Theme.of(context).textTheme.body1.copyWith(
                      decoration: TextDecoration.underline,
                      color: Color(0xFF3BB2B8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: MediaQuery.of(context).size.height >= 640 ?
      new TitleAppBar(title: 'Parque Trindade') : null,
      body: MediaQuery.of(context).size.height >= 640 ?
      body : new NestedScrollView(
        controller: _scrollController,
        key: const PageStorageKey('in_park_page'),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
          new SliverTitleAppBar(
            title: 'Parque Trindade',
            titleOpacity: _opacity,
          ),
        ],
        body: body,
      ),
    );
  }
}