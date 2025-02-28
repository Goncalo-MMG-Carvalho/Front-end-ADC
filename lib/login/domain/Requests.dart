class Request {
  String id;
  String groupName;
  String username;

  Request({
    required this.id,
    required this.groupName,
    required this.username,
  });

  factory Request.fromJson(Map<String, dynamic> json) => Request(
    id: json['requestId'],
    groupName: json['group_name'],
    username: json['userName'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'groupName': groupName,
    'username': username,
  };

  factory Request.fromMap(Map<String, dynamic> map) => Request(
    id: map['id'],
    groupName: map['groupName'],
    username: map['username'],
  );
}