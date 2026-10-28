import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

abstract final class UrlCipher {
  static const _seedParts = ['r4kk', 'u_', 'v4ult', '#7'];
  static const _shift = 7;
  static const _ivLength = 16;

  static String seal(String plainUrl) {
    final iv = IV.fromSecureRandom(_ivLength);
    final shifted = utf8.encode(plainUrl).map((byte) => (byte + _shift) & 0xFF).toList();
    final encrypted = _encrypter().encryptBytes(shifted, iv: iv);
    return base64Encode([...iv.bytes, ...encrypted.bytes]);
  }

  static String reveal(String sealed) {
    final packed = base64Decode(sealed);
    final iv = IV(Uint8List.fromList(packed.sublist(0, _ivLength)));
    final cipherBytes = Uint8List.fromList(packed.sublist(_ivLength));
    final shifted = _encrypter().decryptBytes(Encrypted(cipherBytes), iv: iv);
    return utf8.decode(shifted.map((byte) => (byte - _shift) & 0xFF).toList());
  }

  static Encrypter _encrypter() {
    return Encrypter(AES(Key(_deriveKey()), mode: AESMode.cbc));
  }

  static Uint8List _deriveKey() {
    final seed = utf8.encode(_seedParts.join('|'));
    final firstPass = sha256.convert(seed).bytes;
    return Uint8List.fromList(sha256.convert(firstPass).bytes);
  }
}