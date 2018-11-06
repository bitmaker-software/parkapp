// External imports.
import 'package:flutter/material.dart';

//Internal imports.
import '../utils/translations.dart';
import '../utils/styles.dart';
import '../components/app_bars.dart';

class TripsDetails extends StatelessWidget {
  TripsDetails({
    Key key,
    @required this.date,
    @required this.value,
    this.description
  }) : super(key: key);

  final String date;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new TitleAppBar(
        title: Translations.of(context).text('trip_details'),
      ),
      body: new Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 13.0, 40.0, 13.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                    date,
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      color: themeGrey,
                    ),
                  ),
                  new Text(
                    value,
                    style: Theme.of(context).textTheme.display3
                    .copyWith(
                      color: themeDarkGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 0.0,
              color: themeLightGrey,
            ),
            new Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 13.0, 20.0, 23.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                    child: new Text(
                      description ?? '',
                      style: Theme.of(context).textTheme.body1.copyWith(
                        color: themeGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new DecoratedBox(
              decoration: new BoxDecoration(
                border: new Border(
                  top: new BorderSide(
                    color: themeLightGrey,
                    width: 1.0,
                  ),
                  bottom: new BorderSide(
                    color: themeLightGrey,
                    width: 1.0,
                  ),
                ),
              ),
              child: new SizedBox(
                height: 50.0,
                child: new FlatButton(
                  onPressed: () {
                    print('Do stuff!');
                  },
                  child: new Text(
                    Translations.of(context).text('get_receipt'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      color: themeColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}