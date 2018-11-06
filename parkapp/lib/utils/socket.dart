// External imports.
import 'package:flutter/material.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

// Internal imports.
import '../utils/store.dart';
import '../utils/state_mapping.dart';
import '../main.dart';

class Socket {
  // next three lines makes this class a Singleton
  static Socket _instance = new Socket._internal();
  Socket._internal();
  factory Socket() => _instance;

  // Initializations
  // Pointing to aws server. To change to localhost, set
  // _SOCKET_URL = ws://10.0.2.2:4000/..
  static const _SOCKET_URL = "wss://parkappdev.bitmaker-software.com/socket/websocket";
  Store _store;
  PhoenixSocket _socket;
  PhoenixChannel _channel;
  Map<String, String> _token;

  bool get isConnected => _socket.isConnected && _channel.isJoined;

  bool get isInit => _socket != null;

  void init(BaseState baseState) {
    _store = new Store();
    _token = {"token": _store.prefs.getString('token')};
    _socket = new PhoenixSocket(_SOCKET_URL);
    _socket.connect().then((_) {
      _channel = _socket.channel("reservation:*", _token);
      _channel.on(PhoenixChannelEvents.reply,
      (Map payload, String _ref, String _joinRef) {
        if (payload['status'] == 'error') {
          if (payload['response']['error'] == 'unauthorized') {
            _resetApp();
          }
          else {
            // Retries to join the channel and pushes the event
            _channel.triggerError();
          }
        }
        else if (payload['status'] == 'ok' &&
        payload['response']['message'] == 'joined') {
          _channel.push(event: 'START', payload: _token);
        }
      });
      _channel.on("set_state", (Map payload, String _ref, String _joinRef) {
        baseState.bookingCancelled = payload['reservation']['cancelled'];
        baseState.bookingStartDate = payload['reservation']['reservation_start_time'];
        baseState.startDate = payload['reservation']['parking_start_time'];
        baseState.amount = payload['reservation']['amount'];
        baseState.onPageChanged(payload['reservation']['status'] == 5 ? 2 : 1);
        baseState.setAppState(stateMapping(payload['reservation']['status']));
      });
      _channel.join();
    });
  }

  // For resetting the app.
  void _resetApp() async {
    await _store.prefs.remove('token');
    // Reset App
    runApp(
      new ParkApp(
        key: new UniqueKey(),
      ),
    );
  }

  void dispose() {
    _channel.leave();
    _socket.remove(_channel);
    _socket.disconnect();
  }
}