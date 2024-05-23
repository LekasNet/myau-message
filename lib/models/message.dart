class Message {
  final String author;
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;
  final bool isSeen;
  final bool isBanned;

  Message({
    required this.author,
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
    required this.isSeen,
    required this.isBanned
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      author: data['username'],
      text: data['content'].substring(0, data['content'].length - 20),
      timestamp: DateTime.parse(data['sent_at']),
      isSentByMe: data['ismine'],
      isSeen: data['read'],
      isBanned: data['ban']
    );
  }
}