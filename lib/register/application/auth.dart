import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class Authentication {
  static String BUSINESS = "USER-BUSINESS";
  static String PERSONAL = "Personal";

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

  static bool isConfirmationCompliant(String password, String confirmation){
    if(confirmation.isEmpty){
        return false;
    }

    bool areTheSame = password == confirmation;

    return areTheSame;
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

  static bool isNameCompliant(String name,[int minLength = 4]){
    if(name.isEmpty) {
      return false;
    }

    bool hasLowercase = name.contains(RegExp(r'[a-z]'));
    bool hasMinLength = name.length > minLength;

    return
    hasLowercase &
    hasMinLength;
  }

  static bool isEmailCompliant(String email){
    if(email.isEmpty) {
      return false;
    }

    bool isValid = email.contains(RegExp(r'[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+[a-zA-Z0-9.]{2,4}'));

    return isValid;
  }

  static bool isAgeCompliant(String age){
    if(age.isEmpty) {
      return false;
    }

    int intAge = int.parse(age);

    return intAge > 18;
  }

  static bool registerUser(String username, String password, String email, String name, String age, String tipo) {
    //  API Call to authenticate an user (GoogleAppEngine endpoint)

    // Note: hash passwords before sending them through the communication channel
    // Example: https://pub.dev/packages/hash_password

    // In the meanwhile, if you don't have an endpoint to authenticate users in
    // Google app Engine, send a POST to https://dummyjson.com/docs/auth.
    // Body should be a json {'username': <username>, 'password': <password>}
    // Use username: hbingley1 - password: CQutx25i8r
    // More info: https://dummyjson.com/docs/auth

    fetchAuthenticate(username, name, password, email, age, tipo);

    return true;
  }

  //A password tem de ir ja encriptada?
  static Future<bool> fetchAuthenticate(String username, String name, String password, String email, String age, String tipo) async {
    var bytesP = utf8.encode(password);
    var encodedP = sha512.convert(bytesP);

    var tipoConta = tipo.split(".");
    String json;

    if(tipoConta[1] == "personal") {
      json = jsonEncode(<String, String>{
        'username': username,
        'password': encodedP.toString(),
        'email':email,
        'idade': age,
        'name': name,
      });
    }else {
      json = jsonEncode(<String, String>{
        'username': username,
        'password': encodedP.toString(),
        'email':email,
        'idade': age,
        'name': name,
        'accountType': BUSINESS
      });
      print(tipoConta[1]);
    }

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/register/v3'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },

      body: json
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(jsonDecode(response.body));
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