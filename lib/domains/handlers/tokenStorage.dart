import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String accessToken, String refreshToken, String timestamp, String username) async {
    await _storage.write(key: "accessToken", value: accessToken);
    await _storage.write(key: "refreshToken", value: refreshToken);
    await _storage.write(key: "timestamp", value: timestamp);
    await _storage.write(key: "username", value: username);
  }

  Future<void> updateToken(String accessToken, String refreshToken) async {
    await _storage.write(key: "accessToken", value: accessToken);
    await _storage.write(key: "refreshToken", value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: "accessToken");
    await _storage.delete(key: "refreshToken");
    await _storage.delete(key: "timestamp");
    await _storage.delete(key: "username");
  }

  Future<Map<String, String>> getToken() async {
    String? accessToken = await _storage.read(key: "accessToken");
    String? refreshToken = await _storage.read(key: "refreshToken");
    String? timestamp = await _storage.read(key: "timestamp");
    String? username = await _storage.read(key: "username");
    return {
      "accessToken": accessToken ?? "",
      "refreshToken": refreshToken ?? "",
      "timestamp": timestamp ?? "",
      "username": username ?? "",
    };
  }
}

