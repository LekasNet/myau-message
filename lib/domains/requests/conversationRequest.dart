import 'package:http/http.dart' as http;
import '../../commons/globals.dart';
import '../handlers/tokenStorage.dart';
import 'dart:convert'; // Для работы с json

Future<void> fetchUserConversations() async {
  TokenStorage storage = TokenStorage();
  Map<String, String> tokens = await storage.getToken();
  String accessToken = tokens['accessToken']!;

  var url = Uri.parse('https://myau-message.onrender.com/api/conversations/user-conversations');
  var response = await http.get(url, headers: {
    'Authorization': accessToken
  });

  if (response.statusCode == 200) {
    print(response.body);
    List<dynamic> jsonData = jsonDecode(response.body);
    items = jsonData.map((itemJson) => Item.fromJson(itemJson)).toList();
  } else if (response.statusCode == 401) {
    throw Exception('Пользователь не авторизован');
  } else {
    throw Exception('Request failed with status: ${response.statusCode}.');
  }
}