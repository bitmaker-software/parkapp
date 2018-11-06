//External imports.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:map_view/map_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

//Internal imports.
import '../pages/booking_start.dart';
import '../components/app_bars.dart';
import '../components/map.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';
import '../utils/network.dart';
import '../main.dart';

// This class shows the details of the parking place selected.
class ParkDetails extends StatefulWidget {
  ParkDetails({
    Key key,
    @required this.features,
    @required this.park,
    @required this.available,
    @required this.value,
    @required this.destination,
  }) : super(key: key);

  final String park;
  final String available;
  final String value;
  final Map destination;
  final List<Map> features;

  @override
  State<StatefulWidget> createState() => new ParkDetailsState();
}

class ParkDetailsState extends State<ParkDetails> {
  // Initializations.
  ViewMap _map;
  Geolocator _geolocator;
  StreamSubscription<Position> _positionStream;
  Stream<Position> _locationStream;
  RestApi _api;
  bool _openingMap;
  bool _loading;
  bool _nearPark;
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
    _map = new ViewMap();
    _geolocator = new Geolocator();
    _api = new RestApi();
    _openingMap = false;
    _loading = true;
    _nearPark = false;
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
    initLocation();
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    _scrollController.dispose();
    if (_positionStream != null) {
      _positionStream.cancel();
      _positionStream = null;
    }
    super.dispose();
  }

  // Sets the openingMap variable to control the button loading animation.
  void setOpenMap(bool value) {
    setState(() {
      _openingMap = value;
    });
  }

  // Sets the _loading and _nearPark variables to control the button loading
  // animation and state.
  void setLoadingNear([bool loading, bool near]) {
    setState(() {
      _loading = loading ?? _loading;
      _nearPark = near ?? _nearPark;
    });
  }

  // Initialize location stream to setup the get me in/book button.
  initLocation() {
    _locationStream = _geolocator.getPositionStream(
      LocationOptions(distanceFilter: 50),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: (e) {
        if(_loading) {
          e.addError(new Exception("Couldn't find the current location."));
        }
      },
    );
    _positionStream = _locationStream.listen((Position position) {
      _geolocator.distanceBetween(position.latitude, position.longitude,
        widget.destination['lat'],
        widget.destination['long'],
      ).then((double distance) {
        if (distance <= 50) {
          setLoadingNear(false, true);
        }
        else if (distance > 50) {
          setLoadingNear(false, false);
        }
      }).catchError((e) {
        setLoadingNear(false, false);
        handleError(context, e);
      });
    },
    onError: (e) {
      setLoadingNear(false, false);
      handleError(context, e);
    },
    cancelOnError: true);
  }

  // Gets the code to enter the requested park.
  void getParkCode(){
    setLoadingNear(true);
    _api.makeSingleUseReservation().then((dynamic _response) {
      Base.of(context).barcode = _response['barcode'];
      Base.of(context).type = _response['type'];
      Base.of(context).setAppState(1);
      Base.of(context).onPageChanged(2);
    })
    .catchError((e) {
      setLoadingNear(false);
      handleError(context, e);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = new ListView(
      key: const PageStorageKey('park_details'),
      padding: const EdgeInsets.fromLTRB(30.0, 24.0, 30.0, 0.0),
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: new Column(
            children: <Widget>[
              new ButtonTheme(
                minWidth: 112.0,
                child: new FlatButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                    side: const BorderSide(
                      color: themeColor,
                      width: 2.0,
                    ),
                  ),
                  splashColor: themeColor[200],
                  child: !_openingMap ?
                  new Text(
                    Translations.of(context).text('map_view'),
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: themeColor,
                    ),
                  ) :
                  new Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.5,
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
                  ),
                  onPressed: () {
                    if(!_openingMap) {
                      _map.showMap(
                        context: context,
                        mapMode: 'CAR',
                        park: widget.park,
                        destinationLocation: new Location(
                          widget.destination['lat'],
                          widget.destination['long'],
                        ),
                        available: widget.available,
                        value: widget.value,
                        setOpeningMap: setOpenMap,
                        isStepsScreen: false,
                      );
                    }
                  },
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 10.0
                ),
                child: new SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: new FlatButton(
                    color: themeColor,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    splashColor: themeColor[400],
                    onPressed: () {
                      if(!_loading) {
                        if(_nearPark) {
                          getParkCode();
                        }
                        else {
                          Navigator.of(context).push(
                            new MaterialPageRoute(
                              builder: (context) => new BookingStart(
                                park: widget.park,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: _loading ?
                    new CircularProgressIndicator(
                      strokeWidth: 3.0,
                    )
                    : _nearPark ?
                    new Text(
                      Translations.of(context).text('directions_button'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Colors.white,
                      ),
                    )
                    : new Text(
                      Translations.of(context).text('book_spot'),
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
                  onPressed: () async {
                    await launch(
                      "https://www.google.com/maps/dir/?api=1"
                          "&destination=${widget.destination['lat']}"
                          ",${widget.destination['long']}"
                          "&travelmode=driving",
                          //${widget.mapMode == 'CAR' ?"driving" :"walking"}
			  forceSafariVC: false,
		          forceWebView: false,
                    );
                  },
                  child: new Text(
                    Translations.of(context).text('get_directions_details'),
                    style: Theme.of(context).textTheme.body1.copyWith(
                      decoration: TextDecoration.underline,
                      color: Color(0xFF3BB2B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
          ),
          child: new Text(
            Translations.of(context).text('features'),
            style: Theme.of(context).textTheme.display4.copyWith(
              color: Colors.black,
            ),
          ),
        ),
        new ListView.builder(
          shrinkWrap: true,
          key: const PageStorageKey('features'),
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
          ),
          itemCount: widget.features.length,
          itemBuilder: (context, index) {
            return new DecoratedBox(
              decoration: new BoxDecoration(
                border: new Border(
                  top: new BorderSide(
                    color: themeLightGrey,
                    width: 1.0,
                  ),
                  bottom: new BorderSide(
                    color: themeLightGrey,
                    width: index == widget.features.length - 1  ? 1.0 : 0.0,
                  ),
                ),
              ),
              child: new Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0,),
                child: new Row(
                  children: <Widget>[
                    new ImageIcon(
                      new AssetImage('lib/assets/${widget.features[index]['icon']}.png'),
                      color: themeGrey,
                      size: 20.0,
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                      ),
                      child: new Text(
                        widget.features[index]['title'],
                        style: Theme.of(context).textTheme.body1.copyWith(
                          color: themeGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );

    if(widget.features.length > 3) {
      return new Scaffold(
        body: new NestedScrollView(
          controller: _scrollController,
          key: const PageStorageKey('park_details_page'),
          headerSliverBuilder: (BuildContext context,
          bool innerBoxIsScrolled) => <Widget>[
            new SliverBigAppBar(
              title: widget.park,
              titleOpacity: _opacity,
              backgroundImage: new CachedNetworkImage(
                imageUrl: 'https://imagens.publicocdn.com/imagens.aspx'
                  '/872242?tp=UH&db=IMAGENS&type=JPG',
                fit: BoxFit.cover,
                fadeOutDuration: Duration(seconds: 0),
                placeholder: new Center(
                  child: new SizedBox(
                    height: 80.0,
                    width: 80.0,
                    child: new CircularProgressIndicator(),
                  ),
                ),
                errorWidget: new Align(
                  alignment: Alignment.bottomRight,
                  child: new Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10.0,
                      right: 10.0,
                    ),
                    child: new Text(
                      Translations.of(context).text('image_error'),
                    ),
                  ),
                ),
              ),
              bottomWidget: new Padding(
                padding: const EdgeInsets.only(
                  top: 13.0,
                  bottom: 30.0,
                ),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new DecoratedBox(
                          decoration: new BoxDecoration(
                            color: themeColor.withOpacity(0.5),
                            borderRadius: new BorderRadius.circular(5.0),
                          ),
                          child: new Padding(
                            padding: const EdgeInsets.fromLTRB(
                                13.0, 15.0, 13.0, 11.0
                            ),
                            child: new Text(
                              widget.available,
                              style: Theme.of(context).textTheme.display4,
                            ),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(
                            left: 11.0,
                          ),
                          child: new Text(
                            Translations.of(context).text('available_spaces'),
                          ),
                        ),
                      ],
                    ),
                    new Text(
                      '${widget.value}€ / 15 min',
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: _body,
        ),
      );
    }
    else {
      return new Scaffold(
        appBar: new BigAppBar(
          title: widget.park,
          backgroundImage: new CachedNetworkImage(
            imageUrl: 'https://imagens.publicocdn.com/imagens.aspx'
              '/872242?tp=UH&db=IMAGENS&type=JPG',
            fit: BoxFit.cover,
            fadeOutDuration: Duration(seconds: 0),
            placeholder: new Center(
              child: new SizedBox(
                height: 80.0,
                width: 80.0,
                child: new CircularProgressIndicator(),
              ),
            ),
            errorWidget: new Align(
              alignment: Alignment.bottomRight,
              child: new Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                  right: 10.0,
                ),
                child: new Text(
                  Translations.of(context).text('image_error'),
                ),
              ),
            ),
          ),
          bottomWidget: new Padding(
            padding: const EdgeInsets.only(
              top: 13.0,
              bottom: 30.0,
            ),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new DecoratedBox(
                      decoration: new BoxDecoration(
                        color: themeColor.withOpacity(0.5),
                        borderRadius: new BorderRadius.circular(5.0),
                      ),
                      child: new Padding(
                        padding: const EdgeInsets.fromLTRB(
                            13.0, 15.0, 13.0, 11.0
                        ),
                        child: new Text(
                          widget.available,
                          style: Theme.of(context).textTheme.display4,
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                        left: 11.0,
                      ),
                      child: new Text(
                        Translations.of(context).text('available_spaces'),
                      ),
                    ),
                  ],
                ),
                new Text(
                  '${widget.value}€ / 15 min',
                ),
              ],
            ),
          ),
        ),
        body: _body,
      );
    }
  }
}