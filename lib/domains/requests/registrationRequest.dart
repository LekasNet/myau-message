import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> register(String phone, String username, String password) async {
  var response = await http.post(
    Uri.parse('https://myau-message.onrender.com/api/users/register'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'phone': phone,
      'username': username,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print("Access Token: ${data['accessToken']}");
    print("Refresh Token: ${data['refreshToken']}");
    // Handle navigation or storage of tokens
  } else {
    print("Failed to register: ${response.body}");
    // Handle error
  }
}
