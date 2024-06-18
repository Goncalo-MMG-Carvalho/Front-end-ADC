import 'package:adc_handson_session/AppPage/presentation/data/group_storage.dart';

class Group {
  final String code, owner, name, color;

  const Group(
      {required this.owner,
        required this.name,
        required this.code,
        required this.color
      });

  // Convert a User into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'owner': owner,
      'color': color
    };
  }

  // Implement toString to make it easier to see information about
  // each user when using the print statement.
  @override
  String toString() {
    return 'Group{code: $code, name: $name, owner: $owner, color: $color}';
  }

}