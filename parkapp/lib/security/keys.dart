// External imports.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart';

/// The AppPublicKey and AppPrivateKey are responsible for the encoding/decoding of keys, and
/// the saving/loading of the keys to/from the device's filesystem.
class AppPublicKey {

  static const String PUBLIC_KEY_FILE_NAME = "public_key.key";
  static const String SERVER_PUBLIC_KEY_FILE_NAME = "server_public_key.key";

  static String encode(RSAPublicKey key) {
    if(key == null) {
      throw new Exception("PublicKey Encoding needs a Key.");
    }
    ASN1Sequence asn1Key = new ASN1Sequence();
    asn1Key.add(new ASN1Integer(key.modulus));
    asn1Key.add(new ASN1Integer(key.exponent));
    Uint8List keyBytes = asn1Key.encodedBytes;
    return new Base64Encoder().convert(keyBytes);
  }

  static RSAPublicKey decode(String encodedKey) {
    if(encodedKey == null) {
      throw new Exception("PublicKey Decoding needs an Encoded Key.");
    }
    Uint8List keyBytes = new Base64Decoder().convert(encodedKey);
    ASN1Sequence asn1Key = new ASN1Sequence.fromBytes(keyBytes);
    ASN1Integer modulus = asn1Key.elements[0];
    ASN1Integer publicExponent = asn1Key.elements[1];
    RSAPublicKey key = new RSAPublicKey(modulus.valueAsBigInteger, publicExponent.valueAsBigInteger);
    return key;
  }

  static void save(RSAPublicKey key, File file) {
    if(file == null || key == null) {
      throw new Exception("File and Key are needed to save the public key.");
    }
    String encodedKey = AppPublicKey.encode(key);
    file.writeAsStringSync(encodedKey);
  }

  static RSAPublicKey load(File file) {
    if(file == null) {
      throw new Exception("A file is needed to load the public key.");
    }
    String encodedKey = file.readAsStringSync();
    return AppPublicKey.decode(encodedKey);
  }
}

class AppPrivateKey {
  static const String PRIVATE_KEY_FILE_NAME = "private_key.key";
  static const int PRIVATE_KEY_VERSION_TWO_PRIMES = 0;
  static const int PRIVATE_KEY_VERSION_MULTI = 1;

  static String encode(RSAPrivateKey key, BigInt publicExponent) {
    if(key == null || publicExponent == null) {
      throw new Exception("PrivateKey Encoding needs a Key and a PublicExponent.");
    }
    ASN1Sequence asn1Key = new ASN1Sequence();
    asn1Key.add(new ASN1Integer(new BigInt.from(PRIVATE_KEY_VERSION_TWO_PRIMES)));
    asn1Key.add(new ASN1Integer(key.modulus));
    asn1Key.add(new ASN1Integer(publicExponent));
    asn1Key.add(new ASN1Integer(key.d));
    asn1Key.add(new ASN1Integer(key.p));
    asn1Key.add(new ASN1Integer(key.q));
    asn1Key.add(new ASN1Integer(_calculateExponent(key.d, key.p)));
    asn1Key.add(new ASN1Integer(_calculateExponent(key.d, key.q)));
    asn1Key.add(new ASN1Integer(_calculateCRT(key.q, key.p)));
    Uint8List keyBytes = asn1Key.encodedBytes;
    return new Base64Encoder().convert(keyBytes);
  }

  static RSAPrivateKey decode(String encodedKey) {
    if(encodedKey == null) {
      throw new Exception("PrivateKey Decoding needs an Encoded Key.");
    }
    Uint8List keyBytes = new Base64Decoder().convert(encodedKey);
    ASN1Sequence asn1Key = new ASN1Sequence.fromBytes(keyBytes);
    ASN1Integer privateKeyVersion = asn1Key.elements[0];
    ASN1Integer modulus = asn1Key.elements[1];
    ASN1Integer publicExponent = asn1Key.elements[2];
    ASN1Integer privateExponent = asn1Key.elements[3];
    ASN1Integer p = asn1Key.elements[4];
    ASN1Integer q = asn1Key.elements[5];
    ASN1Integer exp1 = asn1Key.elements[6];
    ASN1Integer exp2 = asn1Key.elements[7];
    ASN1Integer crt = asn1Key.elements[8];

    RSAPrivateKey key = new RSAPrivateKey(modulus.valueAsBigInteger,
        privateExponent.valueAsBigInteger,
        p.valueAsBigInteger,
        q.valueAsBigInteger);
    return key;
  }

  static void save(RSAPrivateKey key, BigInt publicExponent, File file) {
    if(file == null || key == null || publicExponent == null) {
      throw new Exception(
        "File, PublicExponent and Key are needed to save the private key."
      );
    }
    String encodedKey = AppPrivateKey.encode(key, publicExponent);
    file.writeAsStringSync(encodedKey);
  }

  static RSAPrivateKey load(File file) {
    if(file == null) {
      throw new Exception("File isneeded to load the private key.");
    }
    String encodedKey = file.readAsStringSync();
    return AppPrivateKey.decode(encodedKey);
  }

  static BigInt _calculateExponent(BigInt d, BigInt prime) {
    return d.modPow(BigInt.one, prime - BigInt.one);
  }

  static BigInt _calculateCRT(BigInt q, BigInt p) {
    return q.modInverse(p);
  }
}

