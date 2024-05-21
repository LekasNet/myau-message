import 'dart:convert';
import 'package:http/http.dart' as http;

import '../handlers/tokenStorage.dart';

Future<void> login(String username, String password) async {
  var response = await http.post(
    Uri.parse('https://myau-message.onrender.com/api/users/login'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'username': username,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    await TokenStorage().saveToken(data['accessToken'], data['refreshToken']);
    print("Tokens saved successfully.");
    // Proceed with navigation or further logic
  } else {
    print("Failed to login: ${response.body}");
    // Handle error
  }
}

