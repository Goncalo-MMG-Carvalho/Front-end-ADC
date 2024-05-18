import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';





class Authentication {


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

  static bool isUsernameCompliant(String username,[int minLength = 4]){
    if(username.isEmpty) {
      return false;
    }

    bool hasUppercase = username.contains(RegExp(r'[A-Z]'));
    bool hasDigits = username.contains(RegExp(r'[0-9]'));
    bool hasLowercase = username.contains(RegExp(r'[a-z]'));
    bool hasMinLength = username.length > minLength;

    return hasDigits &
    hasUppercase &
    hasLowercase &
    hasMinLength;
  }

  static bool loginUser(String username, String password) {
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


  static Future<bool> fetchAuthenticate(String username, String password) async {
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

        Map<String, List<String>> headersMap = response.headers.map;
        print(headersMap);

        String? setCookieHeader = headersMap['set-cookie']?.first ?? headersMap['Set-Cookie']?.first;

        print(response.data);
        var a = response.headers['set-cookie'];
        print(a.toString());
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
    } on DioError catch (e) {
      print(e);
      return false;
    }
  }

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

/*
  static Future<bool> fetchAuthenticate(String username, String password) async {
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
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(jsonDecode(response.body));
      String? a = response.headers['Set-Cookie'];
      print(a);
      var b = response.headers['session::apdc'];
      print(b.toString());
      String? c = response.headers['cookie'];
      print(c);
      print(response.headers.values);
        // Extract cookie from response headers
      return true;
    } else {
      return false;
    }
  }*/
}

void main() async {
  // Users lists: https://dummyjson.com/users
  //Authentication.fetchAuthenticate("hbingley1", "CQutx25i8r");
}
