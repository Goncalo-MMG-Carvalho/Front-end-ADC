
class GroupInfo {
  final String username, groupName, color;

  const GroupInfo(
      {
        required this.username,
        required this.groupName,
        required this.color
      });

  // Convert a User into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'groupName': groupName,
      'color': color
    };
  }

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      username: json['username'],
      groupName: json['groupName'],
      color: json['color'],
    );
  }

  factory GroupInfo.fromMap(Map<String, dynamic> map) {
    return GroupInfo(
      username: map['username'],
      groupName: map['groupName'],
      color: map['color'], // Convert int back to Color
    );
  }

// Implement toString to make it easier to see information about
// each user when using the print statement.
  @override
  String toString() {
    return 'Group{groupName: $groupName, color: $color}';
  }


}