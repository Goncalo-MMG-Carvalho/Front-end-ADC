import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../login/data/users_local_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';
import '../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;


class userInfo {
  bool activationState;
  String age;
  DateTime creationTime;
  String email;
  String name;
  String password;
  String role;
  String username;

  userInfo({
    required this.activationState,
    required this.age,
    required this.creationTime,
    required this.email,
    required this.name,
    required this.password,
    required this.role,
    required this.username,
  });

  factory userInfo.fromJson(Map<String, dynamic> json) {
  return userInfo(
      activationState: json['properties']['activation_state']['value'],
      age: json['properties']['age']['value'],
      creationTime: DateTime.fromMillisecondsSinceEpoch(json['properties']['creation_time']['value']['seconds'] * 1000),
      email: json['properties']['email']['value'],
      name: json['properties']['name']['value'],
      password: json['properties']['password']['value'],
      role: json['properties']['role']['value'],
      username: json['properties']['username']['value'],
    );
  }
}

class AuthenticationProfile {

  String finalToken = "";

  static bool isPasswordCompliant(String password, [int minLength = 8]) {
    //Null-safety ensures that password is never null
    if (password.isEmpty) {
      return false;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
    password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length > minLength;

    return hasDigits &
    hasUppercase &
    hasLowercase &
    hasSpecialCharacters &
    hasMinLength;
  }


  Future<String?> getToken() async {
    String token;
    print("TAMOS NO GET TOKEN");
    if (kIsWeb) {
      token = localStorage.getItem("token")!;
    } else {
      LocalDB db = LocalDB(localDatabaseName);
      token = await db.getToken();
    }
    print(token);
    finalToken = token;
    //finalToken = token.split("u003d")[1];
    print(finalToken);

    return finalToken;
  }

  Future<void> removeToken() async {
    print("TAMOS A REMOVER O TOKEN");
    if (kIsWeb) {
      localStorage.removeItem("token");
    } else {
      LocalDB db = LocalDB(localDatabaseName);
      await db.deleteToken();
    }
  }

  Future<bool?> logout() async {
    return await fetchAuthenticateLogout();
  }

  Future<bool?> fetchAuthenticateLogout() async {
    await getToken();
    print("TOKEN NO AUTHENTICATE $finalToken");
    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/logout/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': finalToken,
      }),
    );

    if (response.statusCode == 200) {
      await removeToken();
      return true;
    } else {
      return false;
    }
  }


  Future<userInfo?> getUser() async {
    await getToken();

    userInfo? u = await fetchAuthenticate();
    return u;
  }

  Future<userInfo?> fetchAuthenticate() async {
    print("TOKEN NO AUTHENTICATE $finalToken");
    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/get_user/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': finalToken,
      }),
    );

    if (response.statusCode == 200) {
      userInfo user = userInfo.fromJson(jsonDecode(response.body));
      print(user.role);
      print(user);

      return user;
    } else {
      return null;
    }
  }

  /*Future<bool> changePasswordAuthenticate(String username, String oldPassword, String newPassword, String token) async {
    // Retrieve current user info
    userInfo? currentUser = await getUser();

    var bytesP = utf8.encode(oldPassword);
    var encodedP = sha512.convert(bytesP);

    // Check if the old password matches the current password
    if (currentUser != null && currentUser.password != encodedP.toString()) {
      print("Current password entered is incorrect.");
      return false;
    }

    var bytesNew = utf8.encode(newPassword);
    var encodedNew = sha512.convert(bytesNew);

    // Make an HTTP POST request to change password endpoint
    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/password_change/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token,
        'newPassword': encodedNew.toString()
      }),
    );

    if (response.statusCode == 200) {
      print("Password changed successfully");
      return true;
    } else {
      print("Failed to change password. Error ${response.statusCode}");
      return false;
    }
  }*/

  Future<bool> changePassword(String email) async {
    //bool authenticationResult = await changePasswordAuthenticate(username, oldPassword, newPassword, token);
    bool authenticationResult = await fetchAuthenticateForgotPassword(email);

    return authenticationResult;
  }

  Future<bool> fetchAuthenticateForgotPassword(String email) async {
    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/forgot_password/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    }
    else {
      print(response.body);
      return false;
    }
  }

  void main() async {
    // Users lists: https://dummyjson.com/users
    //Authentication.fetchAuthenticate("hbingley1", "CQutx25i8r");
  }
}
