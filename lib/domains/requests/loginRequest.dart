import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myau_message/domains/security.dart';

import '../handlers/tokenStorage.dart';


Future<void> verify(String username, String password, String pem) async {
  String timestamp = DateTime.now().toIso8601String();
  var response = await http.post(
    Uri.parse('https://myau-message.onrender.com/api/users/login/verify'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'lastLoginTimestamp': encryptWithPublicKey(pem, timestamp.replaceAll("T", " ")),
      'password': encryptWithPublicKey(pem, password),
      'username': username,
    }),
  );
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print("---------------");
    print(data);
    await TokenStorage().saveToken(data['accessToken'], data['refreshToken'], timestamp, username);
    print("Tokens saved successfully.");
    // Proceed with navigation or further logic
  } else {
    print("Failed to verify: ${response.body}");
    // Handle error
  }
}


Future<void> login(String username, String password) async {

  var response = await http.post(
    Uri.parse('https://myau-message.onrender.com/api/users/login'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'username': username,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print("Starting verifying with");
    await verify(username, password, data["pem"]);
  } else {
    print("Failed to login: ${response.body}");
    // Handle error
  }
}

