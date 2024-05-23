// lib/widgets/message_tile.dart
import 'package:flutter/material.dart';
import 'package:myau_message/models/message.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;


class MessageBubble extends StatelessWidget {
  final Message message;

  MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    DateTime timestampPlusThreeHours = message.timestamp.add(Duration(hours: 3));
    String formattedTime = DateFormat('HH:mm').format(timestampPlusThreeHours);


    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * 0.75;
        final timeAndIconWidth = 150.0;

        final textSpan = TextSpan(
          text: message.text,
          style: TextStyle(color: message.isSentByMe ? Colors.white : Colors.black),
        );
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: 1,
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout(maxWidth: maxWidth - timeAndIconWidth);
        final textSize = textPainter.size;

        bool oneLine = textSize.width <= maxWidth - timeAndIconWidth;

        return Align(
          alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5 ),
            decoration: BoxDecoration(
              color: message.isBanned ? Colors.red : message.isSentByMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                if (!message.isSentByMe) Text(message.author, style: TextStyle(color: Colors.black.withOpacity(0.5)),),
                if (oneLine && message.isSentByMe)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    alignment: message.isSentByMe ? WrapAlignment.end : WrapAlignment.start,
                    children: [
                      Text(message.text, style: TextStyle(color: message.isSentByMe ? Colors.white : Colors.black)),
                      SizedBox(width: 5),
                      Text(formattedTime, style: TextStyle(color: message.isSentByMe ? Colors.white70 : Colors.black, fontSize: 12)),
                      if (message.isSentByMe) SizedBox(width: 2),
                      if (message.isSentByMe) Icon(message.isSeen ? Icons.done_all : Icons.done, size: 16, color: message.isSeen ? Colors.white : Colors.white70),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.text, style: TextStyle(color: message.isSentByMe ? Colors.white : Colors.black)),
                      SizedBox(height: 5),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(formattedTime, style: TextStyle(color: message.isSentByMe ? Colors.white70 : Colors.black, fontSize: 12)),
                          if (message.isSentByMe) Icon(message.isSeen ? Icons.done_all : Icons.done, size: 16, color: message.isSeen ? Colors.blue : Colors.white70),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
