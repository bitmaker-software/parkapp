//External imports.
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:url_launcher/url_launcher.dart';

//Internal imports.
import '../components/app_bars.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';
import '../components/map.dart';

// This class shows the steps to be made to arrive at the selected park.
class Steps extends StatefulWidget {
  Steps({
    Key key,
    @required this.steps,
    @required this.mapMode,
    @required this.park,
    @required this.destination,
    @required this.distance,
    @required this.stepsLength,
    @required this.available,
    @required this.value,
  }) : super(key: key);

  final String mapMode;
  final String park;
  final Location destination;
  final int distance;
  final List<String> steps;
  final int stepsLength;
  final String available;
  final String value;

  @override
  State<StatefulWidget> createState() => new StepsState();
}

class StepsState extends State<Steps> {
  // Initializations
  ViewMap map;
  bool _openingMap;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    map = new ViewMap();
    _openingMap = false;
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    super.dispose();
  }

  // Sets the openingMap variable to control the button loading animation.
  void setOpenMap(bool value) {
    setState(() {
      _openingMap = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new SimpleAppBar(
        title: Translations.of(context).text('steps'),
        actionButton: new FlatButton(
          splashColor: themeColor[400],
          child: !_openingMap ?
          new Text(
            Translations.of(context).text('map_view'),
          ) :
          new Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.5,
            ),
            child: new SizedBox(
              height: 25.0,
              width: 25.0,
              child: new CircularProgressIndicator(
                strokeWidth: 2.0,
              ),
            ),
          ),
          textColor: Colors.white,
          onPressed: () {
            if(!_openingMap) {
              map.showMap(
                context: context,
                mapMode: widget.mapMode,
                park: widget.park,
                destinationLocation: widget.destination,
                available: widget.available,
                value: widget.value,
                setOpeningMap: setOpenMap,
                isStepsScreen: true,
              );
            }
          },
        ),
      ),
      body: new ListView(
        key: const PageStorageKey('steps'),
        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
        children: <Widget>[
          new DecoratedBox(
            decoration: new BoxDecoration(
              border: new Border(
                bottom: new BorderSide(
                  color: themeLightGrey,
                  width: 1.0,
                ),
              ),
            ),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    widget.mapMode == 'CAR' ?
                    new ImageIcon(
                      new AssetImage('lib/assets/car.png'),
                      color: themeGrey,
                      size: 20.0,
                    ) :
                    new ImageIcon(
                      new AssetImage('lib/assets/foot.png'),
                      color: themeGrey,
                      size: 20.0,
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                      ),
                      child: new Text(
                        '${widget.distance >= 1000 ?
                          (widget.distance/1000).toStringAsFixed(1) + ' km'
                          : '${widget.distance} m'}',
                        style: Theme.of(context).textTheme.display3.copyWith(
                          color: themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                  ),
                  child: new Text(
                    Translations.of(context).text('route_to') +
                    ' ${widget.park}',
                    style: Theme.of(context).textTheme.body2.copyWith(
                      color: themeGrey,
                    ),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15.0,
                  ),
                  child: new ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width <= 350
                      ? 0.0 : 145.0,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new FlatButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            side: const BorderSide(
                              color: themeColor,
                              width: 2.0,
                            ),
                          ),
                          splashColor: themeColor[200],
                          child: new Text(
                            Translations.of(context).text('park_details'),
                            style: Theme.of(context).textTheme.body1.copyWith(
                              color: themeColor,
                            ),
                          ),
                          onPressed: () {
                            Navigator.maybePop(context);
                          },
                        ),
                        new FlatButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            side: const BorderSide(
                              color: themeColor,
                              width: 2.0,
                            ),
                          ),
                          splashColor: themeColor[200],
                          child: new Text(
                            Translations.of(context).text('start_navigation'),
                            style: Theme.of(context).textTheme.body1.copyWith(
                              color: themeColor,
                            ),
                          ),
                          onPressed: () async {
                            await launch(
                              "https://www.google.com/maps/dir/?api=1"
                              "&destination=${widget.destination.latitude}"
                              ",${widget.destination.longitude}"
                              "&travelmode=${widget.mapMode == 'CAR' ?
                              "driving" :
                              "walking"}",
			      forceSafariVC: false,
		              forceWebView: false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          new ListView.builder(
            shrinkWrap: true,
            key: const PageStorageKey('step_list'),
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 35.0,
            ),
            itemCount: widget.stepsLength,
            itemBuilder: (context, index) {
              return new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: index == 0 ?
                    new Icon(
                      Icons.my_location,
                      color: themeGrey,
                      size: 20.0,
                    ) :
                    widget.steps[index-1].contains('slight')
                    && widget.steps[index-1].contains('left') ?
                    new ImageIcon(
                      new AssetImage('lib/assets/slight-left.png'),
                      color: themeGrey,
                      size: 20.0,
                    ) :
                    widget.steps[index-1].contains('slight')
                    && widget.steps[index-1].contains('right') ?
                    new ImageIcon(
                      new AssetImage('lib/assets/slight-right.png'),
                      color: themeGrey,
                      size: 20.0,
                    ) :
                    widget.steps[index-1].contains('left') ?
                    new ImageIcon(
                      new AssetImage('lib/assets/turn-left.png'),
                      color: themeGrey,
                      size: 20.0,
                    ) :
                    widget.steps[index-1].contains('right') ?
                    new ImageIcon(
                      new AssetImage('lib/assets/turn-right.png'),
                      color: themeGrey,
                      size: 20.0,
                    ) :
                    new ImageIcon(
                      new AssetImage('lib/assets/top.png'),
                      color: themeGrey,
                      size: 20.0,
                    ),
                  ),
                  new Expanded(
                    child: new DecoratedBox(
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: new BorderSide(
                            color: themeLightGrey,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: new Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ),
                        child: index == 0 ?
                        new Text(
                          Translations.of(context).text('your_location'),
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: themeDarkGrey,
                          ),
                        ) :
                        new Text(
                          widget.steps[index-1],
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: themeDarkGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          new Card(
            margin: const EdgeInsets.only(
              bottom: 15.0,
            ),
            color: themeColor,
            child: new Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Image(
                    image: new AssetImage('lib/assets/park_steps.png'),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                    ),
                    child: new Text(
                     Translations.of(context).text('arrive_at') +
                     ' ' + widget.park,
                      style: Theme.of(context).textTheme.display3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}