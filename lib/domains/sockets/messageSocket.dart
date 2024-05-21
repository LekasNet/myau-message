import 'package:myau_message/domains/handlers/tokenStorage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

import 'dart:io';

void connectAndLogin(String content, String conversationId) async {
  var socket = await Socket.connect('myau-message.onrender.com', 8080);
  print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

  // Создание JSON строки для логина
  const type = 'action';
  print(type);
  var token = await TokenStorage().getToken();
  print(token["accessToken"]);
  String loginMessage = jsonEncode({"token": token["accessToken"], "content": content, "conversationId": conversationId});
  socket.write('$loginMessage');  // '\n'

  // Прослушивание ответов от сервера
  socket.listen(
      (List<int> data) {
        print('Received message: ${String.fromCharCodes(data).trim()}');
      },
      onError: (error) {
        print('Error: $error');
        socket.close();
      },
      // onDone: () {
      //   print('Connection closed by the server.');
      //   socket.close();
      // }
  );


  // Поддержание соединения открытым или закрытие по условию
  // await socket.close();
  // print('Connection closed.');
}


// class MessageSocket {
//   late WebSocketChannel channel;
//   bool isConnected = false;
//
//   Future<void> connect() async {
//     // Установка соединения с WebSocket сервером
//     channel = WebSocketChannel.connect(
//         Uri.parse('wss://myau-message.onrender.com')
//     );
//     isConnected = true;
//
//     await channel.ready;
//
//     channel.stream.listen((message) {
//       print(1);
//       channel.sink.add('received!');
//       print(2);
//       channel.sink.close(status.goingAway);
//       print(3);
//     });
//
//     // Прослушивание входящих сообщений
//     // channel.stream.listen(
//     //         (message) {
//     //       print('Received message: $message');
//     //       // Дополнительная обработка входящих сообщений
//     //     },
//     //     onDone: () {
//     //       print('WebSocket connection closed.');
//     //       isConnected = false;
//     //       // Действия при закрытии соединения
//     //     },
//     //     onError: (error) {
//     //       print('WebSocket error: $error');
//     //       isConnected = false;
//     //       // Обработка ошибок соединения
//     //     }
//     // );
//
//     // Отправка сообщения 'login' с токеном
//     var loginMessage = jsonEncode({
//       'type': 'login',
//       'token': '3'
//     });
//     channel.sink.add(loginMessage);
//     print('Login request sent with token 3');
//   }
//
//   void sendMessage(String message) {
//     if (isConnected) {
//       channel.sink.add(message);
//       print('Message sent: $message');
//     } else {
//       print('Connection is closed, cannot send message.');
//     }
//   }
//
//   void disconnect() {
//     if (isConnected) {
//       channel.sink.close();
//       isConnected = false;
//       print('Disconnected from WebSocket.');
//     } else {
//       print('Already disconnected.');
//     }
//   }
// }

