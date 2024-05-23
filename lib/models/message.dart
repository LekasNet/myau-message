class Message {
  final String author;
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;
  final bool isSeen;

  Message({
    required this.author,
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
    this.isSeen = false,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      author: data['username'],
      text: data['content'],
      timestamp: DateTime.parse(data['sent_at']),
      isSentByMe: data['ismine'],
      isSeen: data['read'],
    );
  }
}

