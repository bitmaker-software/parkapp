// External imports.
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

//Internal imports.
import '../components/app_bars.dart';
import '../utils/translations.dart';
import '../utils/styles.dart';
import '../components/refreshable_list.dart';

// This class lets you renew a subscription associated to the account.
class SubscriptionRenew extends StatefulWidget {
  SubscriptionRenew({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new SubscriptionRenewState();
}

class SubscriptionRenewState extends State<SubscriptionRenew> {
  // Declarations.
  List<String> testItems;
  Random random;
  String park;
  String expiryDate;
  String lastPayment;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    random = Random();
    testItems = List<String>.generate(
      random.nextInt(10), (i) => "Visa ****${i}${i+1}${i+2}${i+3}"
    );
    park = 'Parque Trindade';
    expiryDate = '07/18';
    lastPayment = '06/18';
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    super.dispose();
  }

  // Called when lists are pulled down to refresh the lists.
  Future<Null> refreshList() async {
    // Here is just a temporary test fix to remove the indicator after 2 sec.
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      testItems = List<String>.generate(
        random.nextInt(10), (i) => "Visa ****${i}${i+1}${i+2}${i+3}"
      );
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: BigAppBar(
        title: Translations.of(context).text('renew_subscription'),
        bottomWidget: new Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 30.0,
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Text(
                park,
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
                              expiryDate,
                              style: Theme.of(context).textTheme.display4,
                            ),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(
                            left: 11.0,
                          ),
                          child: new Text(
                            Translations.of(context).text('renew_expiry_date'),
                          ),
                        ),
                      ],
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        new Text(
                          Translations.of(context).text('renew_last_payment'),
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                          ),
                          child: new Text(
                            lastPayment,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: new Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
        ),
        child:new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: new Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8.0,
                ),
                child: new Text(
                  Translations.of(context).text('renew_select_payment'),
                  style: Theme.of(context).textTheme.display2.copyWith(
                    color: themeGrey,
                  ),
                ),
              ),
            ),
            new RefreshableList(
              key: const Key('renew'),
              onRefresh: refreshList,
              list: testItems,
              withButton: true,
              buttonTitle: Translations.of(context).text('add_payment'),
              buttonCallback: () {
                print('Do Stuff');
              },
              onTap: (index) {
                print('Do Stuff');
              },
            ),
          ],
        ),
      ),
    );
  }
}
