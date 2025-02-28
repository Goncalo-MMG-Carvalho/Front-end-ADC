class Message {
  String messageId; // New field

  String sender;
  String message;
  int timestamp;
  String groupName;

  Message({
    required this.messageId,
    required this.groupName,
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'], // Update to initialize messageId
      groupName: json['group_name'],
      sender: json['sender'],
      message: json['message'],
      timestamp: int.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'groupName': groupName,
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'],
      groupName: map['groupName'],
      sender: map['sender'],
      message: map['message'],
      timestamp: map['timestamp'],
    );
  }

  @override
  String toString() {
    return 'Message{messageId: $messageId, sender: $sender, message: $message, timestamp: $timestamp, groupName: $groupName}';
  }
}
