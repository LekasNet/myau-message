import 'package:http/http.dart' as http;
import '../domains/handlers/tokenStorage.dart';

// Функция для удаления беседы по conversationId
Future<void> deleteConversation(String conversationId) async {
  TokenStorage storage = TokenStorage();
  var tokens = await storage.getToken();
  String accessToken = tokens['accessToken']!;

  var url = Uri.parse('https://myau-message.onrender.com/api/conversations/$conversationId');
  var response = await http.delete(
      url,
      headers: {
        'Authorization': accessToken  // Подразумевается использование Bearer токена
      }
  );

  if (response.statusCode == 200) {
    print('Conversation deleted successfully');
  } else {
    print('Failed to delete conversation: ${response.statusCode}, ${response.body}');
  }
}
