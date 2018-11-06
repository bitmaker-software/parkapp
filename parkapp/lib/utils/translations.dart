// External imports.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Definition of the Translations class which enables the application to get
// the labels for the specified language given by the TranslationsDelegate
// class.
// For more info:
// https://www.didierboelens.com/2018/04/internationalization---make-an-flutter-application-multi-lingual/
class Translations {
  Translations(this.locale);

  final Locale locale;
  static Map<dynamic, dynamic> _localizedValues;

  static Translations of(BuildContext context){
    return Localizations.of<Translations>(context, Translations);
  }

  String text(String key) {
    return _localizedValues[key][locale.languageCode] ??
        _localizedValues[key]['en'] ??
        '** $key not found';
  }

  static Future<void> load() {
    return rootBundle.loadString("lib/assets/i18n.json").then((String jsonContent){
      _localizedValues = json.decode(jsonContent);
    });
  }

  get currentLanguage => locale.languageCode;
}

// Definition of the personal localization delegate. Used to instantiate our
// personal Translations class (function load) and validate the supported
// languages.
class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en','pt'].contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) {
    return SynchronousFuture<Translations>(Translations(locale));
  }

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}