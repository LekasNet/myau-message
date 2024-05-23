import 'package:http/http.dart' as http;
import 'package:myau_message/domains/requests/conversationRequest.dart';
import 'dart:convert';
import '../handlers/tokenStorage.dart';


// Функция для создания новой беседы
Future<void> createConversation(String name, String theme, String conversationImg) async {
  TokenStorage storage = TokenStorage();
  var tokens = await storage.getToken();
  String accessToken = tokens['accessToken']!;

  var url = Uri.parse('https://myau-message.onrender.com/api/conversations'); // Замените URL на актуальный
  var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken
      },
      body: jsonEncode({
        'name': name,
        'theme': theme,
        'conversation_img': conversationImg
      })
  );

  if (response.statusCode == 200) {
    print('Conversation created successfully');
    await fetchUserConversations();
  } else {
    print('Failed to create conversation: ${response.statusCode}');
    print('Error: ${response.body}');
  }
}