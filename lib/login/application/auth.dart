import 'dart:convert';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:flutter/cupertino.dart';

import '../data/users_local_storage.dart';
import '../domain/User.dart';
import '../domain/UserToken.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';


import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;


class Authentication {

  Future<void> insertToken(String username, String token) async {
    if (kIsWeb) {
      await initLocalStorage();
      WidgetsFlutterBinding.ensureInitialized();
      localStorage.clear();
      localStorage.setItem('token', token);
    } else {
      LocalDB db = LocalDB(localDatabaseName);
      //FAZ MAIS SENTIDO REMOVER A TABLE DOS USERS QUANDO É FEITO OUTRO LOGIN OU QUANDO E INICIADA A APP NO MAIS DART?
      //await db.restartDB();
      //TODO AINDA SO PARA TESTES TEMOS A BASE DE DADOS A RENICIAR

      //await db.deleteDB();
      await db.deleteUsersAndTokensTables();
      await db.initDB();

      print("INICIOU");

      UserToken u = UserToken(username: username, token: token);
      await db.addUserToken(u);
    }
  }

  Future<bool> loginUser(String email, String password) async {
    bool ret = await fetchAuthenticate(email, password);
    if (!ret) {
      ret = await fetchAuthenticateWithFirebase(email, password);
    }
    return ret;
  }

  Future<bool> fetchAuthenticate(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/login/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password /*encodedP.toString()*/,
      }),
    );

    if (response.statusCode != 200) {
      print(jsonDecode(response.body));
      return false;
    }else if(response.statusCode == 403){

    }
    print(response.body);

    String responseStr = jsonDecode(response.body);
    print(responseStr);

    int tokenStartIndex = responseStr.indexOf('|') + 1;
    final String token = responseStr.substring(tokenStartIndex);
    print("Token: $token");

    await insertToken(email, token);
    await fetchAuthenticateGetUser(token);

    // Extract cookie from response headers
    return true;
  }

  Future<bool> fetchAuthenticateWithFirebase(String email,
      String password) async {
    var firebaseToken = await getIdToken(email, password);
    if (firebaseToken == null) {
      return false;
    }

    //print("FirebaseToken: $firebaseToken");

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/login/firebase/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'newPassword': password,
        'idToken': firebaseToken.toString(),
      }),
    );

    if (response.statusCode != 200) {
      //print(response.body);
      return false;
    }

    //print(response.body);

    String responseStr = jsonDecode(response.body);
    //print(responseStr);


    int tokenStartIndex = responseStr.indexOf('|') + 1;
    final String token = responseStr.substring(tokenStartIndex);
    //print("Token: $token");

    // String token = responseStr;

    await insertToken(email, token);
    await fetchAuthenticateGetUser(token);

    // Extract cookie from response headers
    return true;
  }


  Future<User?> fetchAuthenticateGetUser(String token) async {
    String username = token
        .split(".")
        .first;

    print("TOKEN NO AUTHENTICATE $token");
    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/get_user/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token,
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      try {
        print(jsonDecode(response.body));
        Map<String, dynamic> responseData = jsonDecode(response.body);
        Map<String, dynamic> properties = responseData['properties'];

        print(properties);


        User user = User.fromJson(properties);

        print(user.role);
        print(user);

        userUtils().addUser(user);

        return user;
      }
      catch (e) {
        print("ERRO NO FETCHAUTHENTICATEGETUSER: $e");
        print(response.body);
        return null;
      }
    }
    else {
      print(response.body);
      return null;
    }
  }


  Future<String?> getIdToken(String email, String password) async {
    fb_auth.FirebaseAuth auth = fb_auth.FirebaseAuth.instance;

    fb_auth.UserCredential userCredential;
    try {
      userCredential = await auth
          .signInWithEmailAndPassword(email: email, password: password);
    }
    on fb_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      return null;
    }
    catch (e) {
      print('Error signing in: $e');
      return null;
    }

    fb_auth.User? user = userCredential.user;

    if (user == null) {
      print('User is not authenticated.');
      return null;
    }

    String? idToken;
    try {
      idToken = await user.getIdToken();
    }
    catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
    return idToken;
  }


  Future<bool?> forgotPassword(String email) async {
    return await fetchAuthenticateForgotPassword(email);
  }


  Future<bool?> fetchAuthenticateForgotPassword(String email) async {
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

}




void main() async {

  // Users lists: https://dummyjson.com/users
  //Authentication.fetchAuthenticate("hbingley1", "CQutx25i8r");
}
