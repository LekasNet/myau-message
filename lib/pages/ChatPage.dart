import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myau_message/domains/requests/messageRequest.dart';
import 'package:myau_message/templates/decorations/messageBubbble.dart';
import 'package:myau_message/templates/decorations/textField.dart';

import '../commons/theme.dart';
import '../domains/requests/conversationRequest.dart';
import '../domains/requests/messageSendRequest.dart';
import '../models/message.dart';
import '../domains/security.dart' as security;

class ChatScreen extends StatefulWidget {
  final String id;
  final String chatTitle;
  final String chatAvatarUrl;

  ChatScreen({required this.id, required this.chatTitle, required this.chatAvatarUrl});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];
  late Timer timer;

  @override
  void initState() {
    super.initState();
    fetchMessages(); // Загружаем начальные сообщения
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => fetchMessages());
  }

  void fetchMessages() async {
    try {
      List<Message> newMessages = await fetchConversationMessages(widget.id);
      setState(() {
        messages = newMessages;
      });
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  @override
  void dispose() {
    timer.cancel(); // Отменяем таймер при уничтожении виджета
    super.dispose();
  }

// Сортировка сообщений по времени перед отображение



  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      DateTime now = DateTime.now();
      DateTime date = DateTime(now.day, now.hour, now.minute, now.second);
      fetchUserConversations();
      sendMessage(widget.id, _controller.text);
      setState(() {
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchConversationMessages(widget.id);
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(child: ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return MessageBubble(message: messages[messages.length - 1 - index]);
            },
          ),),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFieldDecorator(controller: _controller, func: _sendMessage,)
              ),
            ],
          ),
        ],
      ),
    );
  }
}
