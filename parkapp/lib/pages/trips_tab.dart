// External imports.
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

//Internal imports.
import '../utils/translations.dart';
import '../components/slider_button.dart';
import '../components/refreshable_list.dart';

// This class builds the Your Trips screen of the application.
class Trips extends StatefulWidget {
  Trips({
    Key key,
    @required this.pastTrips,
    @required this.onTripsChanged,
  }) : super(key: key);

  final bool pastTrips;
  final VoidCallback onTripsChanged;

  @override
  State<StatefulWidget> createState() => new TripsState();
}

class TripsState extends State<Trips> {
  // Declarations.
  List<String> testItems;
  List<String> testUpcoming;
  List<String> testValues;
  Random random;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    random = Random();
    testItems = List<String>.generate(random.nextInt(8), (i) => "Items $i");
    testUpcoming = List<String>.generate(random.nextInt(8), (i) => "Items ${i*2}");
    testValues = List<String>.generate(20,(i) => "€${i/2}");
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    super.dispose();
  }

  // Called when lists are pulled down to refresh the lists.
  Future<Null> refreshList() async {
    if(widget.pastTrips) {
      // Here is just a temporary test fix to remove the indicator after 2 sec.
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        testItems = List<String>.generate(random.nextInt(8), (i) => "Items $i");
      });
    }
    else {
      // Here is just a temporary test fix to remove the indicator after 2 sec.
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        testUpcoming = List<String>.generate(random.nextInt(8), (i) => "Items ${i*2}");
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(
            top: 24.0,
            bottom: 20.0
          ),
          child: new SliderButton(
            leftLabel: Translations.of(context).text('past_trips'),
            rightLabel: Translations.of(context).text('upcoming_trips'),
            state: widget.pastTrips,
            onTap: widget.onTripsChanged,
          ),
        ),
        new RefreshableList(
          key: widget.pastTrips
            ? const Key('past')
            : const Key('upcoming'),
          onRefresh: refreshList,
          list: widget.pastTrips
            ? testValues
            : testUpcoming,
          listValues: testValues,
          onTap: (index) {
            print('Do Stuff');
          },
        ),
      ],
    );
  }
}