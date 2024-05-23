import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../handlers/tokenStorage.dart';


class TokenManager {
  static final TokenStorage _storage = TokenStorage();
  Timer? _timer;

  static Future<void> refreshToken() async {
    var tokens = await _storage.getToken();
    String refreshToken = tokens['refreshToken']!;

    var url = Uri.parse('https://myau-message.onrender.com/api/users/refresh');
    var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken})
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await _storage.updateToken(data['accessToken'], data['refreshToken']);
      print("Token refreshed successfully");
    } else {
      print("Failed to refresh token: ${response.statusCode}");
      _storage.clearTokens();
    }
  }

  void startRefreshTokenCycle() {
    refreshToken();  // Немедленно обновить токен при запуске
    _timer = Timer.periodic(Duration(minutes: 59), (Timer t) => refreshToken());
  }

  void stopRefreshTokenCycle() {
    _timer?.cancel();  // Отменить таймер при необходимости
  }
}