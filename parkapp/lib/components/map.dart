// External imports.
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:map_view/polyline.dart';
import 'package:map_view/figure_joint_type.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

// Internal imports.
import '../utils/styles.dart';
import '../utils/translations.dart';
import '../utils/map_events_subscriptions.dart';
import '../utils/network.dart';
import'../pages/steps.dart';

class ViewMap {
  // next three lines makes this class a Singleton
  static ViewMap _instance = new ViewMap._internal();
  ViewMap._internal();
  factory ViewMap() => _instance;

  // Initializations
  MapView _mapView = new MapView();
  CompositeSubscription _compositeSubscription = new CompositeSubscription();
  RestApi _api = new RestApi();
  Geolocator _geolocator = new Geolocator();

  // Google Maps API keys with restrictions.
  static const String API_KEY_ANDROID = 'AIzaSyD0myxHfnpGa05sqK53yWRux0SWelXLTDM';
  static const String API_KEY_IOS = 'AIzaSyANMm7CgL9kLNnXnH0acbqtm3LzImKB5FU';

  // Generate a polyline from location points.
  List<Location> _generatePolyline(List<dynamic> points) {
    List<Location> poly = new List<Location>();

    for(var i = 0; i < points.length; i++) {
      poly.add(
        new Location(
          points[i]['lat'],
          points[i]['long'],
        ),
      );
    }
    return poly;
  }

  //Generates the path to show on the map from the current location
  // to the destination.
  Future<Map> _generatePath(
      BuildContext context, Location currentLocation, String mapMode,
      Location destination, int test
  ) {
    List<Polyline> _path = [];
    List<String> _steps = [];
    int _stepsLength = 0;
    int _distance = 0;
    Map<String,dynamic> _pathInfo;

    return _api.getPath(currentLocation, destination, mapMode,)
        .then((dynamic _result) {
      for (var i = 0; i < _result.length; i++) {
        _path.add(
          new Polyline(
            "$i",
            _generatePolyline(_result[i]['route']),
            color: _result[i]['mode'] == 'CAR' ? Colors.blue : Colors.orange,
            width: Theme.of(context).platform == TargetPlatform.iOS ? 7.0 : 15.0,
            jointType: FigureJointType.round,
          ),
        );
        _steps.addAll(new List<String>.from(_result[i]['instructions']));
        _stepsLength = _stepsLength + _result[i]['instructions'].length;
        _distance = _distance + _result[i]['distance'].round();
      }
      _pathInfo = {
        "route": _path,
        "steps": _steps,
        "length": _stepsLength,
        "distance": _distance
      };
      return _pathInfo;
    });
  }

  // Starts the map and shows it with the path and destination location.
  void showMap({BuildContext context, String mapMode, String park,
  Location destinationLocation, String available, String value,
  ValueChanged<bool> setOpeningMap, bool isStepsScreen}) {
    Location _currentLocation;
    Marker _destination;
    Map<String, dynamic> _pathInfo;
    Stream<Position> currentPositionStream;

    setOpeningMap(true);

    // Sets the API key for Google Maps Plugin based on OS.
    Theme
        .of(context)
        .platform == TargetPlatform.iOS
        ? MapView.setApiKey(API_KEY_IOS)
        : MapView.setApiKey(API_KEY_ANDROID);

    _destination = new Marker(
      "1",
      park + (available != null && value != null ? '  |  ' + available + ' ' +
          Translations.of(context).text('available_spaces') + '  |  ' +
          value + '€ / 15 min' : ''),
      destinationLocation.latitude,
      destinationLocation.longitude,
      color: themeColor,
    );

    currentPositionStream = _geolocator.getCurrentPosition().asStream()
    .timeout(const Duration(seconds: 10), onTimeout: (e) {
      e.addError(new Exception("Couldn't find the current location."));
    });
    currentPositionStream.listen((Position _location) {
      _currentLocation = new Location(
        _location.latitude,
        _location.longitude,
      );
      return _generatePath(context, _currentLocation, mapMode,
          destinationLocation, 1).then((Map _path) {
        _pathInfo = _path;

        StreamSubscription sub = _mapView.onMapReady.listen((_) async {
          _mapView.setMarkers([_destination]);
          _mapView.setPolylines(_pathInfo['route']);
          await new Future.delayed(const Duration(milliseconds: 100));
          _mapView.zoomToFit();
          new Future.delayed(const Duration(seconds: 1),
            () => setOpeningMap(false),
          );
        });
        _compositeSubscription.add(sub);

        sub = _mapView.onLocationUpdated.listen((location) {
          _currentLocation = new Location(
            location.latitude,
            location.longitude,
          );
          _generatePath(context, _currentLocation, mapMode,
              destinationLocation, 2).then((Map _path) {
            _pathInfo = _path;
            _mapView.setPolylines(_pathInfo['route']);
          });
        });
        _compositeSubscription.add(sub);

        sub = _mapView.onToolbarAction.listen((id) {
          if (id == 1) {
            _handleSteps(
                context,
                setOpeningMap,
                _pathInfo['steps'],
                mapMode,
                park,
                destinationLocation,
                _pathInfo['distance'],
                _pathInfo['length'],
                available,
                value);
          }
          if (id == 2) {
            _handleDismiss();
          }
        });
        _compositeSubscription.add(sub);

        _mapView.show(
          new MapOptions(
            showCompassButton: true,
            showMyLocationButton: true,
            showUserLocation: true,
            title: Translations.of(context).text('map_view_title'),
            initialCameraPosition: new CameraPosition(
              _currentLocation,
              15.0,
            ),
          ),
          toolbarActions:
          isStepsScreen ?
          [new ToolbarAction(
              Translations.of(context).text('close'),
              2
          )
          ] :
          Theme
              .of(context)
              .platform == TargetPlatform.iOS ?
          [new ToolbarAction(
              Translations.of(context).text('close'),
              2
          ),
          new ToolbarAction(
              Translations.of(context).text('steps'),
              1
          )
          ] :
          [new ToolbarAction(
              Translations.of(context).text('steps'),
              1
          ),
          new ToolbarAction(
              Translations.of(context).text('close'),
              2
          )
          ],
        );
      });
    },
    onError: (e) {
      setOpeningMap(false);
      handleError(context, e);
    },
    cancelOnError: true);
  }

  void _handleSteps(BuildContext context, ValueChanged<bool> setOpeningMap,
  List<String> steps, String mapMode, String park, Location destination,
  int distance, int stepsLength, String available, String value) {
    _handleDismiss();
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) =>
        new Steps(
          steps: steps,
          mapMode: mapMode,
          park: park,
          destination: destination,
          distance: distance,
          stepsLength: stepsLength,
          available: available,
          value: value,
        ),
      ),
    );
  }

  void _handleDismiss () {
    _mapView.dismiss();
    _compositeSubscription.cancel();
  }
}