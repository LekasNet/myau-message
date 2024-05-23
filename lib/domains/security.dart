import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:myau_message/domains/handlers/tokenStorage.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:asn1lib/asn1lib.dart' as asn1;
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart'; // Импортируем convert для hex кодирования
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/asymmetric/api.dart';

// ------------------------ AES ШИФРОВАНИЕ ---------------------

// Функция для генерации ключа из SHA-256 хэша
String getKeyFromHash(String data) {
  var bytes = utf8.encode(data);
  var hash = sha256.convert(bytes);
  return hex.encode(hash.bytes).substring(0, 64);
}

// AES шифрование
Uint8List aesEncrypt(String data, String hexKey) {
  var key = Uint8List.fromList(hex.decode(hexKey)); // Преобразуем hex в Uint8List
  final iv = Uint8List(16); // Пока фиксированный IV
  final params = PaddedBlockCipherParameters(
      ParametersWithIV(KeyParameter(key), iv), null);

  final cipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESFastEngine()))
    ..init(true, params);
  final input = Uint8List.fromList(utf8.encode(data));
  return cipher.process(input);
}

// Сериализация для AES шифрования
String uint8ListToHex(Uint8List data) {
  return hex.encode(data);
}

// AES дешифровка
String aesDecrypt(Uint8List encryptedData, String hexKey) {
  var key = Uint8List.fromList(hex.decode(hexKey)); // Преобразуем hex в Uint8List
  final iv = Uint8List(16); // Пока фиксированный IV
  final params = PaddedBlockCipherParameters(
      ParametersWithIV(KeyParameter(key), iv), null);

  final cipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESFastEngine()))
    ..init(false, params);
  final output = cipher.process(encryptedData);
  return utf8.decode(output);
}

// Десериализация для AES расшифровки
Uint8List hexToUint8List(String hexString) {
  return Uint8List.fromList(hex.decode(hexString));
}

// Функции-сборщики для использования шифровки
Future<String> push(String message) async {
  var jwtGet = await TokenStorage().getToken();
  String? jwt = jwtGet["accessToken"];
  String? timestamp = jwtGet["timestamp"]?.replaceAll("T", " ");

  // Генерация ключа
  String key = getKeyFromHash("$jwt$timestamp");

  // Шифрование сообщения
  Uint8List encrypted = aesEncrypt(message, key);
  String encryptedd = uint8ListToHex(encrypted);
  print(uint8ListToHex(encrypted));

  return encryptedd;
}

// Функции-сборщики для использования расшифровки
Future<String> get(String message) async {
  var jwtGet = await TokenStorage().getToken();
  String? jwt = jwtGet["accessToken"];
  String? timestamp = jwtGet["timestamp"]?.replaceAll("T", " ");
  String key = getKeyFromHash("$jwt$timestamp");


  // Дешифрование сообщения
  String decrypted = aesDecrypt(hexToUint8List(message), key);
  return decrypted;
}

// ------------------------ RSA ШИФРОВАНИЕ -----------------------


// Функция для шифрования текста открытым ключом RSA
String encryptWithPublicKey(String publicKeyPem, String message) {
  // Создание открытого ключа из PEM строки
  final parser = encrypt.RSAKeyParser();
  final RSAPublicKey publicKey = parser.parse(publicKeyPem) as RSAPublicKey;

  // Создание шифровальщика
  final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));

  // Шифрование сообщения
  final encrypted = encrypter.encrypt(message);

  // Возвращаем зашифрованный текст в виде строки
  return encrypted.base64;
}