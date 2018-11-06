// External imports.
import 'package:flutter/material.dart';

//Internal imports.
import '../components/app_bars.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';
import '../utils/network.dart';
import '../main.dart';

// This class lets you renew a subscription associated to the account.
class BookingStart extends StatefulWidget {
  BookingStart({
    Key key,
    @required this.park,
  }) : super(key: key);

  final String park;

  @override
  State<StatefulWidget> createState() => new BookingStartState();
}

class BookingStartState extends State<BookingStart> {
  // Initializations.
  RestApi _api;
  bool _loadingCode;
  ScrollController _scrollController;
  //starting opacity position
  final double _defaultTopMargin = 211.0;
  //pixels from top where opacity should start
  final double _opacityStart = 100.0;
  //pixels from top where opacity should end
  final double _opacityEnd = 60.0;
  //starting title opacity
  double _opacity = 0.0;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _api = new RestApi();
    _loadingCode = false;
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
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Sets the _loadingCode to control the button loading animation.
  void setLoadingCode(bool value) {
    setState(() {
      _loadingCode = value;
    });
  }

  // Gets the code to enter the requested park.
  void getParkCode(){
    setLoadingCode(true);
    _api.makeBookedReservation().then((dynamic _response) {
      Base.of(context).barcode = _response['barcode'];
      Base.of(context).type = _response['type'];
      Base.of(context).bookingStartDate = _response['reservation_start_time'];
      Base.of(context).setAppState(1);
      Base.of(context).onPageChanged(2);
    })
    .catchError((e) {
      setLoadingCode(false);
      handleError(context, e);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bottomWidget = new Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 88.0,
      ),
      child: new Align(
        alignment: AlignmentDirectional.centerStart,
        child: new Text(
          widget.park,
          style: Theme.of(context).textTheme.display3.copyWith(
            color: Colors.white70,
          ),
        ),
      ),
    );

    return new Scaffold(
      appBar: MediaQuery.of(context).size.height >= 640 ? BigAppBar(
        title: Translations.of(context).text('booking_details'),
        bottomWidget: bottomWidget,
      ) : null,
      body: MediaQuery.of(context).size.height >= 640 ?
      new Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          themeColor,
                        ),
                        strokeWidth: 20.0,
                      ),
                    ),
                  ),
                  new Text(
                    '00:30',
                    style: Theme.of(context).textTheme.display4.copyWith(
                      fontSize: 48.0,
                      color: themeDarkGrey,
                    ),
                  ),
                ],
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(
                  top: 30.0,
                  bottom: 20.0
              ),
              child: new Text(
                Translations.of(context).text('warning_unable_book'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.body2.copyWith(
                  color: themeGrey,
                ),
              ),
            ),
            new SizedBox(
              height: 50.0,
              child: new FlatButton(
                color: themeColor,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                splashColor: themeColor[400],
                onPressed: () {
                  if(!_loadingCode) {
                    getParkCode();
                  }
                },
                child: _loadingCode ?
                new CircularProgressIndicator(
                  strokeWidth: 3.0,
                ) :
                new Text(
                  Translations.of(context).text('continue'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ) : new NestedScrollView(
        controller: _scrollController,
        key: const PageStorageKey('booking_start_page'),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
          new SliverBigAppBar(
            title: Translations.of(context).text('booking_details'),
            titleOpacity: _opacity,
            bottomWidget: bottomWidget,
          ),
        ],
        body: new ListView(
          key: const PageStorageKey('booking_start'),
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 20.0),
          children: <Widget>[
            new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          themeColor,
                        ),
                        strokeWidth: 20.0,
                      ),
                    ),
                    new Text(
                      '00:30',
                      style: Theme.of(context).textTheme.display4.copyWith(
                        fontSize: 48.0,
                        color: themeDarkGrey,
                      ),
                    ),
                  ],
                ),
                new Padding(
                  padding: const EdgeInsets.only(
                    top: 30.0,
                    bottom: 20.0
                  ),
                  child: new Text(
                    Translations.of(context).text('warning_unable_book'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.body2.copyWith(
                      color: themeGrey,
                    ),
                  ),
                ),
                new SizedBox(
                  height: 50.0,
                  child: new FlatButton(
                    color: themeColor,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    splashColor: themeColor[400],
                    onPressed: () {
                      if(!_loadingCode) {
                        getParkCode();
                      }
                    },
                    child: _loadingCode ?
                    new CircularProgressIndicator(
                      strokeWidth: 3.0,
                    ) :
                    new Text(
                      Translations.of(context).text('continue'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
