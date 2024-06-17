import 'package:adc_handson_session/AppPage/presentation/data/group_storage.dart';

class Group {
  final String owner, name;

  const Group(
      {required this.owner,
        required this.name
      });

  // Convert a User into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'groupName': name,
      'owner': owner,
    };
  }

  // Implement toString to make it easier to see information about
  // each user when using the print statement.
  @override
  String toString() {
    return 'Group{username: $name, token: $owner}';
  }

}