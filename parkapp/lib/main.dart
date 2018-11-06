// External imports.
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//Internal imports.
import 'security/device_authenticator.dart';
import 'pages/home.dart';
import 'pages/in_park.dart';
import 'pages/account.dart';
import 'pages/code.dart';
import 'pages/error_loading.dart';
import 'pages/loading_splash.dart';
import 'pages/processing_payment.dart';
import 'pages/exit_successful.dart';
import 'pages/waiting_enter.dart';
import 'pages/booking_details.dart';
import 'pages/cancelled_booking.dart';
import 'utils/state_mapping.dart';
import 'utils/styles.dart';
import 'utils/translations.dart';
import 'utils/store.dart';
import 'utils/network.dart';
import 'utils/socket.dart';


// This widget is the root of your application.
class ParkApp extends StatefulWidget {
  ParkApp({
    Key key,
  }) : super(key: key);

  // This allows access to the top level state from anywhere in the application.
  static ParkAppState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<ParkAppState>());

  @override
  State<StatefulWidget> createState() => new ParkAppState();
}

class ParkAppState extends State<ParkApp> with TickerProviderStateMixin {
  // Declarations.
  DeviceAuthenticator _deviceAuthenticator;
  Store _store;
  RestApi _api;
  Map appStartingInfo;
  bool translationsLoaded;
  bool _loading;
  bool _errorLoading;
  bool doneLoading;
  bool errorButtonLoading;
  AnimationController _animationController;
  Animation<double> _animation;
  AnimationController _animationErrorController;
  Animation<double> _animationError;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    _deviceAuthenticator = new DeviceAuthenticator();
    _store = new Store();
    _api = new RestApi();
    translationsLoaded = false;
    _loading = true;
    _errorLoading = false;
    doneLoading = false;
    errorButtonLoading = false;
    // Sets the animation in between the loading and base screen.
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _loading = false;
          _errorLoading = false;
        });
      }
    });
    // Sets the animation in between the loading and error screen.
    _animationErrorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationError = Tween(begin: 0.0, end: 1.0).animate(_animationErrorController);
    appInit();
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    _animationController.dispose();
    _animationErrorController.dispose();
    super.dispose();
  }

  // Changes the loading of the try again button in the Error Screen.
  void setErrorButtonLoading(bool value){
    setState(() {
      errorButtonLoading = value;
    });
  }

  // Initializes the application during the loading splash screen.
  void appInit() {
    Translations.load().then((_){
      translationsLoaded = true;
      return _store.init().then((_){
        return _deviceAuthenticator.init().then((_){
          return _api.getReservationInfo().then((dynamic _info){
            appStartingInfo = _info;
            _animationController.forward();
            setState(() {
              doneLoading = true;
            });
          });
        });
      });
    }).catchError((e) {
      if(e is RequestException && e.statusCode == 401){
        appInit();
      }
      else {
        _animationErrorController.forward();
        setState(() {
          _errorLoading = true;
          errorButtonLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      // This key allows the app reset.
      key: widget.key,
      // This is the title of the application.
      title: 'ParkApp',
      // This is the theme of the application.
      theme: theme(context),
      // This sets up the internationalization feature.
      localizationsDelegates: translationsLoaded ? [
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ] : null,
      // These are the supported languages.
      supportedLocales: [
        const Locale('en', ''),
        //TODO uncomment to add PT language
        //const Locale('pt', ''),
      ],
      // The homepage of the application or, in our case, its foundations.
      home: new Stack(
        children: <Widget>[
          _loading ? new LoadingSplash() : null,
          _errorLoading ?
          new FadeTransition(
            opacity: _animationError,
            child: new ErrorLoading(),
          ) : null,
          doneLoading ?
          new FadeTransition(
            opacity: _animation,
            child: new Base(),
          ) : null,
        ].where((widget) => widget != null).toList(),
      )
    );
  }
}

// This widget has its own State object and it is used for handling the
// navigation across the application.
class Base extends StatefulWidget {
  Base({
    Key key,
  }) : super(key: key);

  // This allows access to the top level state from anywhere in the application.
  static BaseState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<BaseState>());

  @override
  State<StatefulWidget> createState() => new BaseState();
}

class BaseState extends State<Base> with SingleTickerProviderStateMixin {
  // Declarations.
  // This controls the page selected.
  int _page;
  // This controller can be used to programmatically
  // set the current displayed tab.
  TabController tabController;
  // This stores the state of the slider button in the Trips screen.
  bool pastTrips;
  // This controls the current state of the app.
  int state;
  // This is the type of the user reservation.
  int type;
  // This is the barcode to generate the QR Code.
  String barcode;
  // This is the amount to pay if the user is in park.
  String amount;
  // This is the date when the user entered the park if he is in park.
  String startDate;
  // This is the date when the user booked the park.
  String bookingStartDate;
  // This is for showing the cancelled booking screen when the user cancels a booking.
  bool bookingCancelled;
  // This is the socket for when there is a reservation for the user.
  Socket _socket;

  // State Initialization (re-renders widgets).
  @override
  void initState() {
    super.initState();
    // Sets the main page.
    _page = 1;
    // Sets the initial tab of the application and how many tabs there are.
    tabController = new TabController(
      vsync: this,
      initialIndex: 0,
      length: 3,
    );
    // Sets the slider button state to past trips.
    pastTrips = true;
    // Sets the current state.
    state = stateMapping(ParkApp.of(context).appStartingInfo['status']);
    // Sets the current reservation type.
    type = ParkApp.of(context).appStartingInfo['type'];
    // Sets the current barcode.
    barcode = ParkApp.of(context).appStartingInfo['barcode'];
    // Sets the current amount to pay.
    amount = ParkApp.of(context).appStartingInfo['amount'];
    // Sets the date when and if the user entered the park.
    startDate = ParkApp.of(context).appStartingInfo['parking_start_time'];
    // Sets the date when and if the user made a booking for the park.
    bookingStartDate = ParkApp.of(context).appStartingInfo['reservation_start_time'];
    // Sets the show cancelled booking screen.
    bookingCancelled = ParkApp.of(context).appStartingInfo['cancelled'];
    // Sets up the socket and respective channel if the user is in park.
    _socket = new Socket();
    if(state > 1) {
      _socket.init(this);
    }
  }

  // State Dispose (good practice).
  @override
  void dispose() {
    if(_socket.isInit == true) {
      _socket.dispose();
    }
    tabController.dispose();
    super.dispose();
  }

  // Called when the page in the center of the viewport as changed.
  void onPageChanged(int page) {
    // Dismiss keyboard and un-focus fields.
    FocusScope.of(context).requestFocus(new FocusNode());
    if (state != 0 && page != 0){
      setState(() {
        _page = page;
      });
    }
  }

  // Called when the slider button in the Trips screen is pressed.
  void onTripsChanged() {
    setState(() {
      pastTrips = !pastTrips;
    });
  }

  // Called when the state needs to be changed.
  void setAppState(int value) {
    if(bookingCancelled){
      Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
          builder: (context) =>
          new CancelledReservation(),
        ),
      );
      bookingCancelled = false;
    }
    setState(() {
      state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // This body enables multiple navigation stacks when the Cupertino
      // Tab View is used. The child condition allows the rebuild of the right
      // and left screens when these are selected and keeps the state of the
      // middle one. Needs the keys to change between the Cupertino pages.
      body: new Stack(
        children: new List<Widget>.generate(3, (int index) {
          return new IgnorePointer(
            ignoring: index != _page,
            child: new Opacity(
              opacity: _page == index ? 1.0 : 0.0,
              child: _page != index && index != 1 ? null :
              [
                new Account(),
                state == 1 ?
                  type == 1 ? new WaitingEnter() : new BookingDetails() :
                state == 2 ?
                new CupertinoTabView(
                  key: new Key('InPark'),
                  builder: (BuildContext context) =>
                  new InPark(),
                ) :
                state == 3 ? new ProcessingPayment() :
                state == 4 ? new ExitSuccessful() :
                new CupertinoTabView(
                  key: new Key('Home'),
                  builder: (BuildContext context) =>
                  new Home(),
                ),
                new Code(),
              ][index],
            ),
          );
        }),
      ),
      bottomNavigationBar: state != 3 ?
      new BottomNavigationBar(
        items: [
          new BottomNavigationBarItem(
            icon: new ImageIcon(
              new AssetImage('lib/assets/user.png'),
              color: themeLightGrey,
            ),
            title: new Text(
              Translations.of(context).text('account'),
              style: Theme.of(context).textTheme.body1.copyWith(
                color: themeLightGrey,
              ),
            ),
          ),
          new BottomNavigationBarItem(
            icon: new ImageIcon(new AssetImage('lib/assets/home.png')),
            title: new Text(Translations.of(context).text('home')),
          ),
          state != 0 ?
          new BottomNavigationBarItem(
            icon: new ImageIcon(new AssetImage('lib/assets/code.png')),
            title: new Text(Translations.of(context).text('code')),
          )
          : new BottomNavigationBarItem(
            icon: new ImageIcon(
              new AssetImage('lib/assets/code.png'),
              color: themeLightGrey,
            ),
            title: new Text(
              Translations.of(context).text('code'),
              style: Theme.of(context).textTheme.body1.copyWith(
                color: themeLightGrey,
              ),
            ),
          ),
        ],
        currentIndex: _page,
        onTap: onPageChanged,
      ) :
      null,
    );
  }
}

void main() {
  // Starts the application (call with key to app reset).
  runApp(
    new ParkApp(),
  );
}
