import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/message.dart';
import '../handlers/tokenStorage.dart'; // Убедитесь, что путь корректен
import 'package:myau_message/domains/security.dart' as security;


Future<List<Message>> fetchConversationMessages(String conversationId) async {
  TokenStorage storage = TokenStorage();
  Map<String, String> tokens = await storage.getToken();
  String accessToken = tokens['accessToken']!;

  // Форматирование текущего времени в ISO 8601
  String formattedDate = DateTime.now().toUtc().toIso8601String();

  // Построение URL
  var url = Uri.parse('https://myau-message.onrender.com/api/conversation-messages/$conversationId/messages');

  try {
    // Отправка GET запроса
    var response = await http.get(
      url,
      headers: {
        'Authorization': accessToken, // Brearer токен
        'fromDate': formattedDate, // Передача текущего времени
      },
    );

    // Проверка статуса ответа и обработка данных
    if (response.statusCode == 200) {
      List<dynamic> encryptedMessages = jsonDecode(response.body);
      List<Message> messages = [];

      for (var encryptedMessage in encryptedMessages) {
        String decryptedJson = await security.get(encryptedMessage); // Расшифровка сообщения
        Map<String, dynamic> messageData = jsonDecode(decryptedJson);
        messages.add(Message.fromMap(messageData));
      }
      return messages;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      throw Error();
    }
  } catch (e) {
    print('Exception caught: $e');
    throw Error();
  }
}


