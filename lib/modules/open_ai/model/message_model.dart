class Message {
  final String role;
  final String content;
  final String? text;
  final bool isImage;
  final String? source;
  final DateTime timestamp;
  final String chatId;

  Message({
    required this.role,
    required this.content,
    this.isImage = false,
    this.source,
    this.text,
    required this.timestamp,
    required this.chatId,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'isImage': isImage,
    'source': source,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'chatId': chatId,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    role: json['role'],
    content: json['content'],
    isImage: json['isImage'] ?? false,
    source: json['source'],
    text: json['text'],
    timestamp: DateTime.parse(json['timestamp']),
    chatId: json['chatId'],
  );
}