import 'package:http/http.dart' as http;
import '../handlers/tokenStorage.dart';

// Функция удаления пользователя из беседы
Future<void> removeUserFromConversation(String conversationId, String userId) async {
  TokenStorage storage = TokenStorage();
  var tokens = await storage.getToken();
  String accessToken = tokens['accessToken']!;

  var url = Uri.parse('https://myau-message.onrender.com/api/conversations/$conversationId/users/$userId');
  var response = await http.delete(
      url,
      headers: {
        'Authorization': accessToken
      }
  );

  if (response.statusCode == 200) {
    print('User removed successfully');
  } else {
    print('Failed to remove user: ${response.statusCode}, ${response.body}');
  }
}
