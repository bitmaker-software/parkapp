// External imports.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

//Internal imports.
import '../components/app_bars.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';
import '../pages/park_details.dart';
import '../utils/socket.dart';

// This class shows the list of parking places.
class Home extends StatefulWidget {
  Home({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  // Declarations.
  List<Map> _parks;
  Socket _socket;
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
    // Disconnects socket when state goes to 0.
    _socket = new Socket();
    if (_socket.isInit == true) {
      _socket.dispose();
    }
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
    _parks = [
      {
        "name": "Parque Trindade",
        "available": "42",
        "value": "0,25",
        "location": {"lat": 41.150680, "long": -8.609585},
        "features": [
          {
            'icon': 'clock',
            'title': 'Open 24 Hours'
          },
          {
            'icon': 'disabled',
            'title': 'Disabled Spots'
          },
          {
            'icon': 'height',
            'title': 'Height Restrictions: 2.10m'
          },
          {
            'icon': 'motorcycle',
            'title': 'Motorcycle Spots'
          },
          {
            'icon': 'cctv',
            'title': 'CCTV'
          },
          {
            'icon': 'family',
            'title': 'Parent & Child Spaces'
          },
          {
            'icon': 'bike',
            'title': 'Bike Racks'
          }
        ],
      },
    ];
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Called when grid is pulled down to refresh.
  Future<void> refreshGrid() async {
    // Here is just a temporary test fix to remove the indicator after 2 sec.
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _parks = _parks;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _body = new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(
            top: 7.0,
            bottom: 3.0,
          ),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ButtonTheme(
                height: 35.0,
                child: new FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () async {
                    await launch(
                      'mailto:Info@bitmaker-software.com?'
                      'subject=FeedBack%20on%20ParkApp',
                    );
                  },
                  child: new Text(
                    Translations.of(context).text('feedback'),
                    style: Theme.of(context).textTheme.body2.copyWith(
                      decoration: TextDecoration.underline,
                      color: Color(0xFF3BB2B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        new Expanded(
          child: new RefreshIndicator(
            color: themeColor,
            onRefresh: refreshGrid,
            child: new GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 8.0,
              ),
              padding: new EdgeInsets.fromLTRB(
                35.0, 0.0, 35.0, _parks.length < 4 ? 0.0 : 10.0
              ),
              itemCount: _parks.length < 4 ?
              4 :
              (_parks.length % 2 == 0 ?
              _parks.length :
              _parks.length + 1
              ),
              itemBuilder: (BuildContext context, int index) {
                return new Card(
                  clipBehavior: Clip.antiAlias,
                  child: index < _parks.length ? new FlatButton(
                    padding: const EdgeInsets.all(10.0),
                    highlightColor: Colors.transparent,
                    splashColor: themeColor[100],
                    onPressed: () {
                      Navigator.of(context).push(
                        new MaterialPageRoute(
                          builder: (context) =>
                          new ParkDetails(
                            park: _parks[index]['name'],
                            available: _parks[index]['available'],
                            value: _parks[index]['value'],
                            destination: _parks[index]['location'],
                            features: _parks[index]['features'],
                          ),
                        ),
                      );
                    },
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Flexible(
                          child: new Image(
                            image: new AssetImage('lib/assets/park.png'),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(
                            top: 15.0,
                            bottom: 5.0,
                          ),
                          child: new Text(
                            _parks[index]['name'],
                            textAlign:TextAlign.center,
                            style: Theme
                                .of(context)
                                .textTheme
                                .body1
                                .copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        new Text(
                          _parks[index]['available'] + ' ' +
                              Translations.of(context).text(
                                  'available_spaces'),
                          textAlign: TextAlign.center,
                          style: Theme
                              .of(context)
                              .textTheme
                              .caption
                              .copyWith(
                            color: themeLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ) :
                  new Image(
                    fit: BoxFit.fill,
                    image: new AssetImage('lib/assets/placeholder.png'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
    if(_parks.length > 4 || MediaQuery.of(context).size.height - 334.0
    <= MediaQuery.of(context).size.width - 68.0) {
      return new Scaffold(
        body: new NestedScrollView(
          controller: _scrollController,
          key: const PageStorageKey('park_list'),
          headerSliverBuilder: (BuildContext context,
          bool innerBoxIsScrolled) => <Widget>[
            new SliverBigAppBar(
              title: Translations.of(context).text('select_park'),
              titleOpacity: _opacity,
              bottomWidget: new Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 35.0,
                ),
                child: new Text(
                  Translations.of(context).text('temporary_home'),
                  textAlign: TextAlign.center,
                  style: Theme
                      .of(context)
                      .textTheme
                      .body2,
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
          title: Translations.of(context).text('select_park'),
          bottomWidget: new Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 35.0,
            ),
            child: new Text(
              Translations.of(context).text('temporary_home'),
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .body2,
            ),
          ),
        ),
        body: _body,
      );
    }
  }
}
