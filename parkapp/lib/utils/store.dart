// External imports.
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Access point to the Cache from anywhere in the app
class Store {
  // next three lines makes this class a Singleton
  static Store _instance = new Store._internal();
  Store._internal();
  factory Store() => _instance;

  SharedPreferences prefs;

  Future<void> init() {
    return SharedPreferences.getInstance().then((SharedPreferences _prefs) {
      prefs = _prefs;
    });
  }
}