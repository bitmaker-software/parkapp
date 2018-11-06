// External imports.
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/export.dart';

/// The CryptoEngine class is responsible for taking care of the
/// encryption/decryption of data, as well as the generation of a key pair.
class CryptoEngine {
  static const int _ENCRYPTION_DATA_SIZE = 256;
  static const String _PUBLIC_EXPONENT = "65537";
  static const int _KEY_BIT_SIZE = 2048;
  static const int _CERTAINTY_VALUE = 12;

  RSAKeyGenerator _keyGenerator;
  RSAEngine _engine;

  void init() {
    RSAKeyGeneratorParameters keyParams = new RSAKeyGeneratorParameters(
      BigInt.parse(_PUBLIC_EXPONENT),
      _KEY_BIT_SIZE,
      _CERTAINTY_VALUE,
    );
    FortunaRandom secureRandom = new FortunaRandom();
    Random random = new Random.secure();
    List<int> seeds = new List<int>();
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(new KeyParameter(new Uint8List.fromList(seeds)));

    ParametersWithRandom rngParams = new ParametersWithRandom(
      keyParams,
      secureRandom,
    );
    _keyGenerator = new RSAKeyGenerator();
    _keyGenerator.init(rngParams);

    _engine = new RSAEngine();
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair() {
    return _keyGenerator.generateKeyPair();
  }

  Uint8List encrypt(String data, AsymmetricKey key) {
    _initRSAEngine(true, key);
    Uint8List dataBytes = _formatDataForEncryption(data);
    return _engine.process(dataBytes);
  }

  String decrypt(Uint8List encryptedData, AsymmetricKey key) {
    _initRSAEngine(false, key);
    String result = String.fromCharCodes(_engine.process(encryptedData));
    return result;
  }

  String encryptString(String data, AsymmetricKey key) {
    Uint8List encryptedData = encrypt(data, key);
    return base64.encode(encryptedData);
  }

  String decryptString(String encryptedStringBase64, AsymmetricKey key) {
    Uint8List encryptedInts = base64.decode(encryptedStringBase64);
    return decrypt(encryptedInts, key);
  }

  void _initRSAEngine(bool isEncryption, AsymmetricKey key) {
    if(key is RSAPublicKey) {
      _initRSAEnginePublic(isEncryption, key);
    } else if(key is RSAPrivateKey) {
     _initRSAEnginePrivate(isEncryption, key);
    } else if(key == null) {
      throw new ArgumentError("Null key");
    } else {
      throw new ArgumentError("Invalid Key Type");
    }
  }

  void _initRSAEnginePublic(bool isEncryption, RSAPublicKey key) {
    AsymmetricKeyParameter<RSAPublicKey> keyParameter = new PublicKeyParameter(key);
    this._engine.init(isEncryption, keyParameter);
  }

  void _initRSAEnginePrivate(bool isEncryption, RSAPrivateKey key) {
    AsymmetricKeyParameter<RSAPrivateKey> keyParameter = new PrivateKeyParameter(key);
    this._engine.init(isEncryption, keyParameter);
  }

  Uint8List _formatDataForEncryption(String data) {
    Uint8List dataBytes = new Uint8List.fromList(data.codeUnits);
    Uint8List padding = _createPadding(dataBytes);
    return _createDataWithPadding(dataBytes, padding);
  }

  Uint8List _createPadding(Uint8List dataBytes) {
    int paddingSize = _ENCRYPTION_DATA_SIZE - dataBytes.length;
    Uint8List padding = new Uint8List(paddingSize);
    return padding;
  }

  Uint8List _createDataWithPadding(Uint8List dataBytes, Uint8List padding) {
    List<int> formattedData = new List<int>();
    formattedData.addAll(dataBytes);
    formattedData.addAll(padding);
    return new Uint8List.fromList(formattedData);
  }
}