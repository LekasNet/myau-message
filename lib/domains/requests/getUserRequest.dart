import 'package:http/http.dart' as http;
import 'dart:convert';
import '../handlers/tokenStorage.dart';

class User {
  final int id;
  final String username;

  User({required this.id, required this.username});

  // Фабричный конструктор для создания экземпляра User из JSON-объекта
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        username: json['username']
    );
  }
}

// Функция получения списка всех пользователей в беседе
Future<List<User>> fetchConversationUsers(String conversationId) async {
  TokenStorage storage = TokenStorage();
  var tokens = await storage.getToken();
  String accessToken = tokens['accessToken']!;

  var url = Uri.parse('https://myau-message.onrender.com/api/conversations/$conversationId/users');
  var response = await http.get(
      url,
      headers: {
        'Authorization': accessToken
      }
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = jsonDecode(response.body);
    List<User> users = jsonData.map((userJson) => User.fromJson(userJson)).toList();
    return users;
  } else {
    throw Exception('Failed to load users: ${response.statusCode}, ${response.body}');
  }
}
