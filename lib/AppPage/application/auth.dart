import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';

import '../../login/data/users_local_storage.dart';
import '../../login/domain/User.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';




const String localDatabaseName = "app.db";


class Authentication {

  Future<String?> getUserRole() async {
    String? token = await getToken();
    return token?.split(".")[2];
  }

  Future<String?> getToken() async {
    String? token;
    if (kIsWeb) {
      await initLocalStorage();
      WidgetsFlutterBinding.ensureInitialized();
      token = localStorage.getItem("token");

    } else {
      LocalDB db = LocalDB(localDatabaseName);
      token = await db.getToken();
    }
    return token;
  }

  Future<void> addGroup(String groupName, String color) async {

    if (kIsWeb) {
      await initLocalStorage();
      WidgetsFlutterBinding.ensureInitialized();

    } else {
      LocalDB db = LocalDB(localDatabaseName);


    }
  }

  bool createGroup(String groupName, bool isPublic, bool isBusiness, String color) {

    fetchAuthenticate(groupName, isPublic, isBusiness, color);

    return true;
  }

  Future<bool> fetchAuthenticate(String groupName, bool isPublic, bool isBusiness, String color) async {

    String? token = await getToken();

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/create_group/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'groupName': groupName,
        'isPublic': isPublic.toString(),
        'isBusiness': isBusiness.toString(),
        'colorCode': color,
      }),
    );

    if (response.statusCode == 200) {

      print(jsonDecode(response.body));

      // Extract cookie from response headers
      return true;
    } else {
      return false;
    }
  }


}

void main() async {

  // Users lists: https://dummyjson.com/users
  //Authentication.fetchAuthenticate("hbingley1", "CQutx25i8r");
}
