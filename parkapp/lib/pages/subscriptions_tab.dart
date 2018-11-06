// External imports.
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

//Internal imports.
import '../components/refreshable_list.dart';

// This class builds the Subscriptions screen of the application.
class Subscriptions extends StatefulWidget {
  Subscriptions({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new SubscriptionsState();
}

class SubscriptionsState extends State<Subscriptions> {
  // Declarations.
  List<String> testItems;
  Random random;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    random = Random();
    testItems = List<String>.generate(random.nextInt(10),
    (i) => "Parque $i"
    );
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
      testItems = List<String>.generate(random.nextInt(10),
      (i) => "Parque $i"
      );
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child:new Column(
        children: <Widget>[
          new RefreshableList(
            key: const Key('subscriptions'),
            onRefresh: refreshList,
            list: testItems,
            withLabel: true,
            onTap: (index) {
              print('Do Stuff');
            },
          ),
        ],
      ),
    );
  }
}