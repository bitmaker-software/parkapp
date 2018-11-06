//External imports.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

// Internal imports
import '../main.dart';
import '../utils/store.dart';
import '../utils/translations.dart';

//All specific REST requests for the application
class RestApi {
  Store _store = new Store();
  NetworkUtil _netUtil = new NetworkUtil();
  // Pointing to aws server. To change to localhost, set HTTPS = false and
  // SERVER_URL = 10.0.2.2:4000
  static const HTTPS = true;
  static const SERVER_URL = "parkappdev.bitmaker-software.com";
  static const REGISTER_URL = "api/v1/account/register/";
  static const AUTHENTICATE_URL = "api/v1/account/authenticate_phase";
  static const VERIFY_URL = "api/v1/account/verify_token/";
  static const ROUTING_URL = "api/v1/routing/route/";
  static const RESERVE_URL = "api/v1/reservation/reserve/";
  static const BOOK_URL = "api/v1/reservation/book/";
  static const IN_PARK_INFO_URL = "api/v1/reservation/current/";
  static const PAYMENT1_URL = "api/v1/reservation/payment1/";
  static const PAYMENT_URL = "api/v1/reservation/pay/";
  static const CANCEL_URL = "api/v1/reservation/cancel/";

  String generateURL(bool https, String serverUrl, String requestUrl,
  [Map<String, String> queryParams]){
    if(https) {
      return new Uri.https(serverUrl, requestUrl, queryParams).toString();
    }
    else {
      return new Uri.http(serverUrl, requestUrl, queryParams).toString();
    }
  }

  Future<dynamic> cancelReservation() {
    final _uri = generateURL(HTTPS, SERVER_URL, CANCEL_URL);
    return _netUtil.put(_uri, headers: {
      "Authorization": "Bearer ${_store.prefs.getString('token')}",
    }).then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> setReservationPayment() {
    final _uri = generateURL(HTTPS, SERVER_URL, PAYMENT1_URL);
    return _netUtil.put(_uri, headers: {
      "Authorization": "Bearer ${_store.prefs.getString('token')}",
    }).then((dynamic res) {
      return res['amount'];
    });
  }

  Future<dynamic> makeReservationPayment(String phoneNumber) {
    final _uri = generateURL(HTTPS, SERVER_URL, PAYMENT_URL);
    final body = {
      "phone_number": phoneNumber,
    };
    return _netUtil.put(_uri, body: body, headers: {
      "Authorization": "Bearer ${_store.prefs.getString('token')}",
    }).then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> getReservationInfo() {
    final _uri = generateURL(HTTPS, SERVER_URL, IN_PARK_INFO_URL);
    return _netUtil.get(_uri, headers: {
      "Authorization": "Bearer ${_store.prefs.getString('token')}",
    }).then((dynamic res) {
      return res['reservation'];
    });
  }

  Future<dynamic> makeBookedReservation() {
    final _uri = generateURL(HTTPS, SERVER_URL, BOOK_URL);
    return _netUtil.post(_uri, headers: {
      "Authorization": "Bearer ${_store.prefs.getString('token')}",
    }).then((dynamic res) {
      return res['reservation'];
    });
  }

  Future<dynamic> makeSingleUseReservation() {
    final _uri = generateURL(HTTPS, SERVER_URL, RESERVE_URL);
    return _netUtil.post(_uri, headers: {
      "Authorization": "Bearer ${_store.prefs.getString('token')}",
    }).then((dynamic res) {
      return res['reservation'];
    });
  }

  Future<dynamic> getPath(Location from, Location to, String mode) {
    final _uri = generateURL(HTTPS, SERVER_URL, ROUTING_URL, {
      "from": "${from.latitude},${from.longitude}",
      "to": "${to.latitude},${to.longitude}",
      "mode": mode,
    });
    return _netUtil.get(_uri, headers: {
      "Authorization": "Bearer ${_store.prefs.getString('token')}",
    }).then((dynamic res) {
        return res['itinerary'];
      });
  }

  Future<dynamic> registerDevice(String deviceId, String publicKey) {
    final _uri = generateURL(HTTPS, SERVER_URL, REGISTER_URL);
    final body = {
      "device_id": deviceId,
      "public_key": publicKey,
    };
    return _netUtil.post(_uri, body: body).then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> authenticateDevice(int phase, String deviceId,
      [String encryptedSecret]) {
    final _uri = generateURL(HTTPS, SERVER_URL, "$AUTHENTICATE_URL$phase/");
    final body = phase == 1 ? { "device_id": deviceId } : {
      "device_id": deviceId,
      "encrypted_secret": encryptedSecret,
    };
    return _netUtil.post(_uri, body: body).then((dynamic res) {
      return res;
    });
  }

  Future<dynamic> verifyToken(String deviceId) {
    final _uri = generateURL(HTTPS, SERVER_URL, VERIFY_URL, {
      "device_id": deviceId,
    });
    return _netUtil.get(_uri, headers: {
      "Authorization": "Bearer ${_store.prefs.getString('token')}",
    }, softReset: true).then((dynamic res) {
      return res;
    });
  }
}

/////////////////////////////BASE REST REQUESTS////////////////////////////////

//Error SnackBar to handle errors.
SnackBar errorSnackBar(String value) {
  return new SnackBar(
    content: new Text(value),
    backgroundColor: Colors.red,
    duration: new Duration(seconds: 3),
  );
}

// Generic handle error method.
void handleError(BuildContext context, dynamic e) {
  if (e is PlatformException){
    Scaffold.of(context).removeCurrentSnackBar();
    if (e.code == 'PERMISSION_DENIED') {
      Scaffold.of(context).showSnackBar(
          errorSnackBar(Translations.of(context).text('permission_denied'))
      );
    } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
      Scaffold.of(context).showSnackBar(
          errorSnackBar(Translations.of(context).text('permission_denied_never'))
      );
    }
    else {
      Scaffold.of(context).showSnackBar(errorSnackBar('Failed to get location.'));
    }
    // Just to have information about potential errors
    throw e;
  }
  else if (e is SocketException) {
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(errorSnackBar(e.osError.message + '.'));
    // Just to have information about potential errors
    throw e;
  }
  else {
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(errorSnackBar(e.message));
    // Just to have information about potential errors
    throw e;
  }
}

// Use the compute function to decode json in a separate isolate
// Must be a top-level function due to isolate restrictions
dynamic _decoder(dynamic response) {
  final JsonDecoder _jsonDecoder = new JsonDecoder();
  return _jsonDecoder.convert(utf8.decode(response));
}

//Basic REST requests structure and error handling
class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil._internal();
  NetworkUtil._internal();
  factory NetworkUtil() => _instance;

  Store _store = new Store();

  // Error Handler
  Future<void> errorHandler (
    int statusCode, dynamic response, [bool softReset = false]
  ) async {
    if(statusCode == 401) {
      await _store.prefs.remove('token');
      // Soft reset for the verify token.
      if(!softReset) {
        // Reset App
        runApp(
          new ParkApp(
            key: new UniqueKey(),
          ),
        );
      }
    }
    if(response is Map && response.containsKey('error')) {
      throw new RequestException(statusCode, response['error']);
    }
    if(statusCode < 200 || statusCode > 400 || response == null){
      throw new RequestException(statusCode, response.toString());
    }
  }

  Future<dynamic> get(
    String url, {Map<String, String> headers, bool softReset: false}
  ) {
    return http
        .get(url, headers: headers)
        .then((http.Response response) async {
      final dynamic res = _decoder(response.bodyBytes);
      final int statusCode = response.statusCode;
      await errorHandler(statusCode, res, softReset);
      return res;
    });
  }

  Future<dynamic> post(String url, {Map<String, String> headers, body, encoding}) {
    return http
        .post(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) async {
      final dynamic res = _decoder(response.bodyBytes);
      final int statusCode = response.statusCode;
      await errorHandler(statusCode, res);
      return res;
    });
  }

  Future<dynamic> put(String url, {Map<String, String> headers, body, encoding}) {
    return http
        .put(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) async {
      final dynamic res = _decoder(response.bodyBytes);
      final int statusCode = response.statusCode;
      await errorHandler(statusCode, res);
      return res;
    });
  }
}

class RequestException implements Exception {
  final String message;
  final int statusCode;
  const RequestException(this.statusCode, [this.message = ""]);
  String toString() => "RequestException(Code $statusCode): $message";
}
