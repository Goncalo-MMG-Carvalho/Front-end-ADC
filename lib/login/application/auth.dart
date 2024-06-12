import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';

import '../data/users_local_storage.dart';
import '../domain/User.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';




const String localDatabaseName = "app.db";


class Authentication {

  Future<void> insertToken(String username, String token) async {
    LocalDB db = LocalDB(localDatabaseName);
    await db.initDB();
    print("INICIOU");
    User u = User(username: username, token: token);
    db.addUser(u);
  }

   bool loginUser(String username, String password) {
    //  API Call to authenticate an user (GoogleAppEngine endpoint)

    // Note: hash passwords before sending them through the communication channel
    // Example: https://pub.dev/packages/hash_password

    // In the meanwhile, if you don't have an endpoint to authenticate users in
    // Google app Engine, send a POST to https://dummyjson.com/docs/auth.
    // Body should be a json {'username': <username>, 'password': <password>}
    // Use username: hbingley1 - password: CQutx25i8r
    // More info: https://dummyjson.com/docs/auth

    fetchAuthenticate(username, password);

    return true;
  }

/*
   Future<bool> fetchAuthenticate(String username, String password) async {
    var bytesP = utf8.encode(password);
    var encodedP = sha512.convert(bytesP);
    print(encodedP);

    final dio = Dio();


    try {
      final response = await dio.post(
        'https://projeto-adc-423314.ew.r.appspot.com/rest/login/v1',
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode(<String, String>{
          'username': username,
          'password': encodedP.toString()
        }),
      );

      if (response.statusCode == 200) {
        print(response.data);

        final tokenString = response.data.split("|");

        insertToken(username,"TOKEN DO USER");



        Map<String, List<String>> headersMap = response.headers.map;
        print(headersMap);

        final setCookieHeader = headersMap['Set-Cookie'];

        print(response.data);
        var a = response.headers['set-cookie'];
        print(a);
        var b = response.headers['Set-Cookie'];
        print(b.toString());
        var c = response.headers['cookie'];
        print(c.toString());
        print(response.headers.map);

        // Extract cookie from response headers
        return true;
      } else {
        print(response.toString());
        return false;
      }
    } on DioException catch (e) {
      print(e);
      return false;
    }
  }
*/
/*
  static Future<bool> fetchAuthenticate(String username, String password) async {
    var bytesP = utf8.encode(password);
    var encodedP = sha512.convert(bytesP);

    //final dio = Dio();
    final Dio dio = Dio();

    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        // Process response to handle cookies
        final setCookieHeader = response.headers.map['Set-Cookie'];
          // Handle cookie here
          print('Set-Cookie header: $setCookieHeader');
          print(response.headers.map);
        return handler.next(response);
      },
    ));


    try {
      final response = await dio.post(
        'https://projeto-adc-423314.ew.r.appspot.com/rest/login/v1',
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode(<String, String>{
          'username': username,
          'password': encodedP.toString(),
        }),

      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Successful authentication

        return true;
      } else {
        // Authentication failed
        return false;
      }
    } on DioError catch (e) {
      // Handle Dio errors
      print(e);
      return false;
    }
  }
*/


   Future<bool> fetchAuthenticate(String username, String password) async {
    var bytesP = utf8.encode(password);
    var encodedP = sha512.convert(bytesP);

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/login/v1'),
      //Uri.parse('http://localhost:8080/rest/login/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': encodedP.toString(),
      }),
    );

    if (response.statusCode == 200) {

      final tokenFull = response.body.split("|");
      String token = tokenFull[1];

      if(kIsWeb){

        await initLocalStorage();
        WidgetsFlutterBinding.ensureInitialized();
        localStorage.setItem('token', token);

      }else {

        insertToken(username, token);
      }

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
