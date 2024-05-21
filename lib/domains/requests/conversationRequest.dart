import 'package:http/http.dart' as http;

import '../handlers/tokenStorage.dart';

Future<void> fetchUserConversations() async {
  TokenStorage storage = TokenStorage();
  Map<String, String> tokens = await storage.getToken();
  String accessToken = tokens['accessToken']!;

  var url = Uri.parse('https://myau-message.onrender.com/api/conversations/user-conversations');
  print(accessToken);
  var response = await http.get(url, headers: {
    'Authorization': '$accessToken'
  });

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}