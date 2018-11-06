// External imports.
import 'package:flutter/material.dart';

//Internal imports.
import '../components/app_bars.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';

// This class lets you see the subscription details associated to the account.
class SubscriptionDetails extends StatefulWidget {
  SubscriptionDetails({
    Key key,
  }) : super(key: key);

  @override
  SubscriptionDetailsState createState() {
    return SubscriptionDetailsState();
  }
}

class SubscriptionDetailsState extends State<SubscriptionDetails> {
  // Declarations.
  String name;
  String email;
  String park;
  String startDate;
  String endDate;
  String model;
  String value;
  String brandModel;
  String licensePlate;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    name = 'Joana Silva';
    email = 'Joana Silva';
    park = 'Parque Trindade';
    startDate = '06-23-2018';
    endDate = '07-23-2018';
    model = 'Regular';
    value = '80€';
    brandModel = 'Fiat 500';
    licensePlate = 'CD-55-VG';
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new TitleAppBar(
        title: Translations.of(context).text('subscription_details'),
      ),
      body: new ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
            ),
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
                  horizontal: 15.0,
                  vertical: 8.0,
                ),
                child: new Text(
                  Translations.of(context).text('owner'),
                  style: Theme.of(context).textTheme.display2.copyWith(
                    color: themeGrey,
                  ),
                ),
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: new Theme(
              data: Theme.of(context).copyWith(
                disabledColor: themeLightGrey,
              ),
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    enabled: false,
                    initialValue: name,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeLightGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                        .text('subscription_name'),
                      labelStyle: Theme.of(context).textTheme.headline
                        .copyWith(
                          color: themeColor,
                        ),
                      contentPadding: const EdgeInsets.only(
                        bottom: 5.0,
                        top: 15.0,
                      ),
                    ),
                  ),
                  new TextFormField(
                    enabled: false,
                    initialValue: email,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeLightGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                          .text('subscription_email'),
                      labelStyle: Theme.of(context).textTheme.headline
                          .copyWith(
                        color: themeColor,
                      ),
                      contentPadding: const EdgeInsets.only(
                        bottom: 5.0,
                        top: 15.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
            ),
            child: new DecoratedBox(
              decoration: new BoxDecoration(
                border: new Border(
                  bottom: new BorderSide(
                    color: themeLightGrey,
                    width: 0.5,
                  ),
                ),
              ),
              child: new Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8.0,
                ),
                child: new Text(
                  Translations.of(context).text('subscription'),
                  style: Theme.of(context).textTheme.display2.copyWith(
                    color: themeGrey,
                  ),
                ),
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: new Theme(
              data: Theme.of(context).copyWith(
                disabledColor: themeLightGrey,
              ),
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    enabled: false,
                    initialValue: park,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeLightGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                          .text('subscription_park'),
                      labelStyle: Theme.of(context).textTheme.headline
                          .copyWith(
                        color: themeColor,
                      ),
                      contentPadding: const EdgeInsets.only(
                        bottom: 5.0,
                        top: 15.0,
                      ),
                    ),
                  ),
                  new TextFormField(
                    enabled: false,
                    initialValue: startDate,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeLightGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                          .text('subscription_start'),
                      labelStyle: Theme.of(context).textTheme.headline
                          .copyWith(
                        color: themeColor,
                      ),
                      contentPadding: const EdgeInsets.only(
                        bottom: 5.0,
                        top: 15.0,
                      ),
                    ),
                  ),
                  new TextFormField(
                    enabled: false,
                    initialValue: endDate,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeLightGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                          .text('subscription_end'),
                      labelStyle: Theme.of(context).textTheme.headline
                          .copyWith(
                        color: themeColor,
                      ),
                      contentPadding: const EdgeInsets.only(
                        bottom: 5.0,
                        top: 15.0,
                      ),
                    ),
                  ),
                  new TextFormField(
                    enabled: false,
                    initialValue: model,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeLightGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                          .text('subscription_model'),
                      labelStyle: Theme.of(context).textTheme.headline
                          .copyWith(
                        color: themeColor,
                      ),
                      contentPadding: const EdgeInsets.only(
                        bottom: 5.0,
                        top: 15.0,
                      ),
                    ),
                  ),
                  new TextFormField(
                    enabled: false,
                    initialValue: value,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeLightGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                          .text('subscription_value'),
                      labelStyle: Theme.of(context).textTheme.headline
                          .copyWith(
                        color: themeColor,
                      ),
                      contentPadding: const EdgeInsets.only(
                        bottom: 5.0,
                        top: 15.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
            ),
            child: new DecoratedBox(
              decoration: new BoxDecoration(
                border: new Border(
                  bottom: new BorderSide(
                    color: themeLightGrey,
                    width: 0.5,
                  ),
                ),
              ),
              child: new Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8.0,
                ),
                child: new Text(
                  Translations.of(context).text('vehicle_details'),
                  style: Theme.of(context).textTheme.display2.copyWith(
                    color: themeGrey,
                  ),
                ),
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: new Theme(
              data: Theme.of(context).copyWith(
                disabledColor: themeLightGrey,
              ),
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    enabled: false,
                    initialValue: brandModel,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeLightGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                          .text('subscription_vehicle_brand'),
                      labelStyle: Theme.of(context).textTheme.headline
                          .copyWith(
                        color: themeColor,
                      ),
                      contentPadding: const EdgeInsets.only(
                        bottom: 5.0,
                        top: 15.0,
                      ),
                    ),
                  ),
                  new TextFormField(
                    enabled: false,
                    initialValue: licensePlate,
                    style: Theme.of(context).textTheme.body2
                        .copyWith(
                      color: themeLightGrey,
                    ),
                    decoration: new InputDecoration(
                      labelText: Translations.of(context)
                          .text('subscription_license_plate'),
                      labelStyle: Theme.of(context).textTheme.headline
                          .copyWith(
                        color: themeColor,
                      ),
                      contentPadding: const EdgeInsets.only(
                        bottom: 5.0,
                        top: 15.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 30.0),
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
                  print('Do Stuff!');
                },
                child: new Text(
                  Translations.of(context).text('renew_subscription'),
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
                bottom: new BorderSide(
                  color: themeLightGrey,
                  width: 1.0,
                ),
              ),
            ),
            child: new SizedBox(
              width: double.infinity,
              height: 50.0,
              child: new FlatButton(
                splashColor: Colors.red[200],
                onPressed: () {
                  print('Do stuff!');
                },
                child: new Text(
                  Translations.of(context).text('cancel_subscription'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}