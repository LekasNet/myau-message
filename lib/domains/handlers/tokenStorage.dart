import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String accessToken, String refreshToken) async {
    await _storage.write(key: "accessToken", value: accessToken);
    await _storage.write(key: "refreshToken", value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: "accessToken");
    await _storage.delete(key: "refreshToken");
  }

  Future<Map<String, String>> getToken() async {
    String? accessToken = await _storage.read(key: "accessToken");
    String? refreshToken = await _storage.read(key: "refreshToken");
    return {
      "accessToken": accessToken ?? "",
      "refreshToken": refreshToken ?? ""
    };
  }
}

