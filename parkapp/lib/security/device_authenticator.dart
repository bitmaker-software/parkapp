// External imports.
import 'dart:async';
import 'dart:io';
import 'package:pointycastle/export.dart';

// Internal imports.
import '../security/crypto_engine.dart';
import '../security/uuid.dart';
import '../utils/files.dart';
import '../utils/network.dart';
import '../security/keys.dart';
import '../utils/store.dart';

/// The DeviceAuthenticator class is responsible for the handshake process
/// between the mobile-client and the server.
/// This process is done in 2 consecutive steps: registration and authentication.
/// The registration process envolves the mobile-client sending his device id
/// and his public key to the server, which will be stored in the database.
/// The authentication process is a challenge-response process, and has 2 phases.
/// In the first phase, the mobile-client tells the server he wants to
/// authenticate, and the server answers with a secret (a random string)
/// encrypted with the client’s public key. The client decrypts the secret.
/// In the second phase, the client encrypts the secret again, but with the
/// server's public key, and sends it to the server. The server then decrypts
/// this secret, and if it matches the secret generated in the first phase,
/// the server sends a token to the client, which he will use in all other
/// requests to prove that he can access the server’s endpoints.
///
/// WARNING!!!!!!!!!!!!
/// Do not forget to follow the instructions on the README file, in the "Cheats"
/// section.
/// These are necessary until the PointyCastle devs send a new version with the
/// necessary fixes.
class DeviceAuthenticator {
  static DeviceAuthenticator _instance = new DeviceAuthenticator._internal();
  DeviceAuthenticator._internal();
  factory DeviceAuthenticator() => _instance;

  static const int _AUTH_PHASE_1 = 1;
  static const int _AUTH_PHASE_2 = 2;
  static const String _SERVER_PUBLIC_KEY = "MIIBCgKCAQEAp9BCdNzjjBn5j9h8xIZXW1MW"
      "jfA2WL0mA0x9pR0qOm5ESGq4nF2LSPbKw4TetnmDHQVq5rIKTkBa8prjKR4MSCn1/S//coB62J"
      "sDuxw1VjgW52RmoSm+19bS1JoNsD+Js0rrZpMuy0TiV9ssI3OqBjx0WuHOHhXMz+Mu4DOqZPjU"
      "wHkMf5sC7bGn2R7oQnhbz9lJ96hDFZuN7IEKGaE4sgCqR+5FdRL4LXME7pw76xi+qv+GqUE/gx"
      "eqdOCjI4ALOk2fk3DWtBQv4rLEbyDwqpGwknG2E+udOrQgyd39Mitbhn3eGrto/wWN+/2jkWq6"
      "CC10h7z1bObRVK3EjlL7sQIDAQAB";

  Store _store = new Store();
  RestApi _api = new RestApi();
  CryptoEngine _cryptoEngine = new CryptoEngine();
  Uuid _deviceId = new Uuid();
  String _secret;
  RSAPublicKey _serverPublicKey;
  RSAPublicKey _publicKey;
  RSAPrivateKey _privateKey;
  File _publicKeyFile;
  File _privateKeyFile;

  Future<void> init() {
    if(_store.prefs.getString('token') == null) {
      this._cryptoEngine.init();
      this._secret = null;

      return Future.wait([
        Files.getFile(AppPublicKey.PUBLIC_KEY_FILE_NAME),
        Files.getFile(AppPrivateKey.PRIVATE_KEY_FILE_NAME),
      ]).then((List files) {
        this._publicKeyFile = files[0];
        this._privateKeyFile = files[1];

        AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = _getDeviceKeys();
        this._publicKey = keyPair.publicKey;
        this._privateKey = keyPair.privateKey;

        this._serverPublicKey = AppPublicKey.decode(_SERVER_PUBLIC_KEY);

        return _deviceId.exists().then((bool exists) {
          if(!exists) {
            _deviceId.generate();
            return register().then((_){
              return authenticate();
            });
          }
          else {
            return _deviceId.load().then((_) {
              return authenticate();
            });
          }
        });
      });
    }
    else {
      return _deviceId.load().then((_) {
        return verifyToken();
      });
    }
  }

  Future<void> register() {
    String encodedPublicKey = AppPublicKey.encode(this._publicKey);
    return _api.registerDevice(this._deviceId.id, encodedPublicKey).then((_) {
      return _deviceId.save();
    });
  }

  Future<void> authenticate() {
    return _authenticatePhase1().then((_) {
      return _authenticatePhase2();
    });
  }

  Future<void> _authenticatePhase1() {
    return _api.authenticateDevice(_AUTH_PHASE_1, this._deviceId.id)
        .then((dynamic response) {
      String encryptedSecret = response["secret"];
      this._secret = this._cryptoEngine.decryptString(
        encryptedSecret,
        this._privateKey,
      );
    });
  }

  Future<void> _authenticatePhase2() {
    String encryptedSecret = this._cryptoEngine.encryptString(
      this._secret,
      this._serverPublicKey,
    );
    return _api.authenticateDevice(_AUTH_PHASE_2, this._deviceId.id,
        encryptedSecret).then((dynamic response) {
      return this._store.prefs.setString(
        'token', response["token"],
      );
    });
  }

  Future<void> verifyToken() {
    return _api.verifyToken(_deviceId.id);
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> _getDeviceKeys() {
    bool publicKeyExists = this._publicKeyFile.existsSync();
    bool privateKeyExists = this._privateKeyFile.existsSync();

    if (publicKeyExists && privateKeyExists) {
      return _loadDeviceKeys();
    } else {
      return _generateAndSaveDeviceKeys();
    }
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> _loadDeviceKeys() {
    RSAPublicKey publicKey = AppPublicKey.load(this._publicKeyFile);
    RSAPrivateKey privateKey = AppPrivateKey.load(this._privateKeyFile);
    return new AsymmetricKeyPair<PublicKey, PrivateKey>(publicKey, privateKey);
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> _generateAndSaveDeviceKeys() {
    AsymmetricKeyPair<PublicKey, PrivateKey> generatedKeys =
    this._cryptoEngine.generateKeyPair();
    RSAPublicKey publicKey = generatedKeys.publicKey;
    RSAPrivateKey privateKey = generatedKeys.privateKey;
    AppPublicKey.save(publicKey, this._publicKeyFile);
    AppPrivateKey.save(privateKey, publicKey.exponent, this._privateKeyFile);
    return generatedKeys;
  }
}