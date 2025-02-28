
class UserToken {
  final String username, token;

  const UserToken(
      {required this.username,
        required this.token
      });

  // Convert a User into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'token': token,
    };
  }

  // Implement toString to make it easier to see information about
  // each user when using the print statement.
  @override
  String toString() {
    return 'UserToken{username: $username, token: $token}';
  }

}
