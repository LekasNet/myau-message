import 'package:http/http.dart' as http;
import 'dart:convert';

import '../handlers/tokenStorage.dart';


// Функция добавления пользователя в беседу
Future<void> addUserToConversation(String conversationId, String username) async {
  TokenStorage storage = TokenStorage();
  var tokens = await storage.getToken();
  String accessToken = tokens['accessToken']!;

  var url = Uri.parse('https://myau-message.onrender.com/api/conversations/$conversationId/users');
  var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken
      },
      body: jsonEncode({'username': username})
  );

  if (response.statusCode == 200) {
    print('User added successfully');
  } else {
    print('Failed to add user: ${response.statusCode}, ${response.body}');
  }
}
