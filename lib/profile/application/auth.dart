import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';

import '../../login/data/users_local_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';


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

const String localDatabaseName = "app.db";


class Authentication {

  String finalToken = "";



  Future<String?> getToken() async {
    String token;
    print("TAMOS NO GET TOKEN");
    if(kIsWeb){
      token = localStorage.getItem("token")!;

    }else {
      LocalDB db = LocalDB(localDatabaseName);
      token = await db.getToken();
    }
    print(token);
    finalToken = token.split("u003d")[1];
    print(finalToken);

    return finalToken;
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

}

void main() async {
  // Users lists: https://dummyjson.com/users
  //Authentication.fetchAuthenticate("hbingley1", "CQutx25i8r");
}
