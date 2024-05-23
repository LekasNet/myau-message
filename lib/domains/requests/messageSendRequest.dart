import 'package:http/http.dart' as http;
import 'package:myau_message/domains/security.dart' as security;
import 'dart:convert';

import '../handlers/tokenStorage.dart';

// Функция для отправки сообщения
Future<void> sendMessage(String conversationId, String message) async {
  TokenStorage storage = TokenStorage();
  Map<String, String> tokens = await storage.getToken();
  String accessToken = tokens['accessToken']!;
  String finalMessage = await security.push(message);
  // Построение URL /conversation-messages/{conversationId}/messages
  var url = Uri.parse('https://myau-message.onrender.com/api/conversation-messages/$conversationId/messages');

  try {
    // Отправка POST запроса
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken, // Подставляем токен авторизации
      },
      body: jsonEncode({
        'content': finalMessage // Содержимое сообщения
      }),
    );

    // Проверка статуса ответа
    if (response.statusCode == 200) {
      print("Сообщение успешно отправлено");
    } else {
      print("Ошибка при отправке сообщения: ${response.body}");
    }
  } catch (e) {
    print("Исключение при отправке сообщения: $e");
  }
}
