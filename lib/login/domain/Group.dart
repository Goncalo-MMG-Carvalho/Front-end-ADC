import 'package:adc_handson_session/AppPage/presentation/data/group_storage.dart';

class Group {
  final String groupCode, groupOwner, groupName, color, groupAdmins, access, type, members;

  const Group(
      {
        required this.groupCode,
        required this.groupOwner,
        required this.groupName,
        required this.groupAdmins,
        required this.access,
        required this.type,
        required this.members,
        required this.color
      });

  // Convert a User into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'groupCode': groupCode,
      'groupName': groupName,
    //  'groupOwner': owner,
      'color': color
    };
  }

  // Implement toString to make it easier to see information about
  // each user when using the print statement.
//  @override
//  String toString() {
//    return 'Group{code: $code, name: $name, owner: $owner, color: $color}';
//  }

}