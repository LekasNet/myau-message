class Message {
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;
  final bool isSeen;

  Message({
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
    this.isSeen = false,
  });
}

