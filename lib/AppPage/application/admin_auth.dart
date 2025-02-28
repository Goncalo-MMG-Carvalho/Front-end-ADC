import 'dart:convert';


import 'package:adc_handson_session/profile/application/auth.dart';

import '../../Utils/userUtils.dart';
import '../../exceptions/invalid_token.dart';
import '../../login/domain/User.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

//TODO METER BEM O ADICIONADO
const String PRIVATE_GROUP_RESPONSE = "Pedido de entrada criado com sucesso";
const String PUBLIC_GROUP_RESPONSE = "Utilizador adiconado ao grupo";
const String PUBLIC = "public";
const String PRIVATE = "private";


class AdminAuthentication {

  Future<User?> getUserAdm(String username) async {
    try{
    return await fetchAuthenticateGetUser(username);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }


  Future<User?> fetchAuthenticateGetUser(String username) async {
    String? token = await userUtils().getToken();
    print("ADM GET: $username");
    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/get_user/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'username': username
      }),
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      Map<String, dynamic> responseData = jsonDecode(response.body);

      Map<String, dynamic> properties = responseData['properties'];

      print(properties);

      User user = User.fromJson(properties);
      print(user.role);
      print(user);

      return user;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print(response.body);
      return null;
    }
  }

  Future<bool> changeUserRoles(String username, String newRole) async {
    try{
    return await fetchChangeUserRoles(username, newRole);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchChangeUserRoles(String username, String newRole) async {
    String? token = await userUtils().getToken();
    print("Change User Role: $username to $newRole");

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/role_change/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'usernameToChange': username,
        'role': newRole,
      }),
    );

    if (response.statusCode == 200) {
      print("User role changed successfully.");
      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print(response.body);
      return false;
    }
  }

  Future<bool> removeGroup(String groupName) async {
    try{
    return await fetchRemoveGroup(groupName);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchRemoveGroup(String groupName) async {
    String? token = await userUtils().getToken();
    print("Remove Group: $groupName");

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/remove_group/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'groupName': groupName,
      }),
    );

    if (response.statusCode == 200) {
      print("Group removed successfully.");
      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print(response.body);
      return false;
    }
  }

  Future<bool> removeUser(String username) async {
    try{
    return await fetchRemoveUser(username);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchRemoveUser(String username) async {
    String? token = await userUtils().getToken();
    print("Remove User: $username");

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/remove_user/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      print("User removed successfully.");
      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print(response.body);
      return false;
    }
  }

}



