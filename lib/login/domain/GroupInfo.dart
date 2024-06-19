import 'package:adc_handson_session/AppPage/presentation/data/group_storage.dart';

class GroupInfo {
  final String groupName, color;

  const GroupInfo(
      {
        required this.groupName,
        required this.color
      });

  // Convert a User into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'groupName': groupName,
      'color': color
    };
  }

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      groupName: json['groupName'],
      color: json['color'],
    );
  }

// Implement toString to make it easier to see information about
// each user when using the print statement.
  @override
  String toString() {
    return 'Group{groupName: $groupName, color: $color}';
  }


}