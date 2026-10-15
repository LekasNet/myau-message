import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myau_message/domains/security.dart';

import '../handlers/tokenStorage.dart';


Future<String> verify(String username, String password, String pem) async {
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
    return 'success';
    // Proceed with navigation or further logic
  } else {
    return response.body;
    // Handle error
  }
}


Future<String> login(String username, String password) async {
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
    var responce = await verify(username, password, data["pem"]);
    if (responce == 'success') {
      return 'success'; // Возвращаем 'success' при успешном входе
    } else {
      return responce; // Возвращаем сообщение об ошибке от сервера
    }
  } else {
    return response.body; // Возвращаем сообщение об ошибке от сервера
  }
}


