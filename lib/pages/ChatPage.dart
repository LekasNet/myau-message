import 'package:flutter/material.dart';
import 'package:myau_message/templates/decorations/messageBubbble.dart';
import 'package:myau_message/templates/decorations/textField.dart';

import '../commons/theme.dart';
import '../domains/requests/conversationRequest.dart';
import '../domains/sockets/messageSocket.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String chatTitle;
  final String chatAvatarUrl;

  ChatScreen({required this.chatTitle, required this.chatAvatarUrl});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [
    Message(
      text: 'Привет! Как дела?',
      timestamp: DateTime.now().subtract(Duration(minutes: 1)),
      isSentByMe: false,
      isSeen: true,
    ),
    Message(
      text: 'Всё хорошо, спасибо! А у тебя?',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      isSentByMe: true,
      isSeen: false,
    ),
    Message(
      text: 'Тоже неплохо, работаю над новым проектом.',
      timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      isSentByMe: false,
      isSeen: true,
    ),
  ];

// Сортировка сообщений по времени перед отображение



  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      DateTime now = new DateTime.now();
      DateTime date = new DateTime(now.day, now.hour, now.minute, now.day);
      fetchUserConversations();
      setState(() {
        messages.add(Message(text: _controller.text, timestamp: date, isSentByMe: true));
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.theme.secondaryHeaderColor,
        leadingWidth: 30,
        leading: Padding(
          padding: EdgeInsets.only(left: 6),
          child: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.white,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatAvatarUrl),
            ),
            const SizedBox(width: 22),
            Text(widget.chatTitle),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: messages[index]);
              },
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFieldDecorator(controller: _controller, func: _sendMessage,)
              ),
              // IconButton(
              //   icon: Icon(Icons.send),
              //   onPressed: _sendMessage,
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
