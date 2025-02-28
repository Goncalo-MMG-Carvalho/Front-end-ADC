import 'dart:convert';
import 'package:adc_handson_session/Utils/firebaseUtils.dart';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../exceptions/invalid_token.dart';
import '../../login/data/users_local_storage.dart';
import '../../group/application/auth.dart';
import '../../profile/application/auth.dart';
import '../../login/domain/Group.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import '../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

//TODO METER BEM O ADICIONADO
const String PRIVATE_GROUP_RESPONSE = "Pedido de entrada criado com sucesso";
const String PUBLIC_GROUP_RESPONSE = "Utilizador adiconado ao grupo";
const String PUBLIC = "public";
const String PRIVATE = "private";


class AuthenticationAppPage {


  AuthenticationGroup auth = AuthenticationGroup();

  AuthenticationProfile auth1 = AuthenticationProfile();

  userUtils uUtils = userUtils();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  isGroupNameValid(String groupName) {
    return groupName.contains(RegExp(r'^[a-zA-Z0-9_-]{1,256}$'));
  }

  Future<void> addGroup(String groupName, String color) async {
    String? username = await uUtils.getUsername();

    GroupInfo newGroup = GroupInfo(username: username!, groupName: groupName, color: color);
    if (kIsWeb) {
      await initLocalStorage();
      WidgetsFlutterBinding.ensureInitialized();

      String? info = localStorage.getItem("GroupsInfo");

      var infoList = json.decode(info!);
      List<dynamic> jsonList = jsonDecode(infoList);
      List<GroupInfo> groupInfos = jsonList.map((map) => GroupInfo.fromMap(json.decode(map))).toList();

      groupInfos.add(newGroup);

      String jsonString = jsonEncode(groupInfos.map((group) => json.encode(group.toMap())).toList());

      localStorage.setItem("GroupsInfo", json.encode(jsonString));

    } else {
      LocalDB db = LocalDB(localDatabaseName);
      db.addGroupInfo(newGroup);
    }
  }

  Future<String> joinGroup(String groupName) async {
    return await fetchAuthenticateJoinGroup(groupName);
  }


  Future<String> fetchAuthenticateJoinGroup(String groupName) async {
    String? token = await uUtils.getToken();
    String? fbToken = await firebaseUtils().getToken(_firebaseMessaging);

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/add_user_to_group/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'groupName': groupName,
        'fbToken' : fbToken!,
      }),
    );

    if (response.statusCode == 200) {
      final responseStr = jsonDecode(response.body);
      print("RESPOSTA DE ADICIONAR USER AO GROUP $responseStr");

      if(responseStr == PRIVATE_GROUP_RESPONSE) {
        return PRIVATE;
      }else {

        Map<String, dynamic> responseData = jsonDecode(response.body);

        Map<String, dynamic> properties = responseData['properties'];

        Group group = Group.fromJson2(properties);

        await addGroup(groupName, group.color);
        if(!kIsWeb){
          LocalDB db = LocalDB(localDatabaseName);
          db.addGroup(group);
        }
        return PUBLIC;
      }
    }else if(response.statusCode == 403){
      await auth1.removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print(jsonDecode(response.body));
      return "";
    }
  }



  Future<bool> createGroup(String groupName, bool isPublic, bool isBusiness, String color) {
    try {
      print("entroi");
      return fetchAuthenticate(groupName, isPublic, isBusiness, color);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
      }
  }

  Future<bool> fetchAuthenticate(String groupName, bool isPublic, bool isBusiness, String color) async {
    print("ANTES GET TOKEN");
    String? token = await uUtils.getToken();
    print("depois getToken");
    String? fbToken = await firebaseUtils().getToken(_firebaseMessaging);//TODO COLOCAR A SER ENVIADO

    print("aNTES REQUEST");
    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/create_group/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'groupName': groupName,
        'isPublic': isPublic.toString(),
        'isBusiness': isBusiness.toString(),
        'colorCode': color,
        'fbToken' : fbToken!,
      }),
    );

    print("depois do request");
    if (response.statusCode == 200) {
      //SE FOI CRIADO COM SUCESSO ADICIONAR GRUPO ÀS PERSISTENCIAS

      addGroup(groupName, color);
      print(jsonDecode(response.body));
      // Extract cookie from response headers
      return true;
    }else if(response.statusCode == 403){
      print("NAO TEVE SUCESSO");
      await auth1.removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {

      print("NAO TEVE SUCESSO");
      print(response.statusCode);
      return false;
    }
  }

  Future<List<GroupInfo>?> getGroups() async {
    try {
      String? username = await uUtils.getUsername();
      List<GroupInfo> groupInfos = [];

      if (kIsWeb) {
        await initLocalStorage();
        WidgetsFlutterBinding.ensureInitialized();
        String? info = localStorage.getItem("GroupsInfo");

        if (info == null) {
          print("NAO TINHA");
          return await fetchAuthenticateGetGroups();
        } else {
          print("JA TENHO");
          var infoList = json.decode(info);
          List<dynamic> jsonList = jsonDecode(infoList);
          groupInfos = jsonList.map((map) => GroupInfo.fromMap(json.decode(map))).toList();
          return groupInfos;
        }
      } else {
        LocalDB db = LocalDB(localDatabaseName);
        var groupsInfo = await db.getGroupsInfo(username!);

        if (groupsInfo.isEmpty) {
          print("NAO TINHA OS GRUPOS");
          return await fetchAuthenticateGetGroups();
        } else {
          for (Map<String, Object?> list in groupsInfo) {
            groupInfos.add(GroupInfo.fromMap(list));
          }
          return groupInfos;
        }
      }
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }

  }


  Future<List<GroupInfo>?> fetchAuthenticateGetGroups() async {
    String? token = await uUtils.getToken();

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/get_user_groups/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      print("RESPOSTA DO GET GROUPS: $jsonResponse");
      List<List<String>> groupsData = jsonResponse.map((dynamic item) {
        return List<String>.from(item);
      }).toList();

      String? username = await uUtils.getUsername();

      List<GroupInfo> groupInfos = [];
      for (List<String> group in groupsData) {
        GroupInfo gi = GroupInfo(username: username!, groupName: group[0], color: group[1]);
        print(gi);
        groupInfos.add(gi);
      }

      print(groupsData);

      if (kIsWeb) {
        await initLocalStorage();
        WidgetsFlutterBinding.ensureInitialized();
        String jsonString = jsonEncode(groupInfos.map((group) => json.encode(group.toMap())).toList());

        localStorage.setItem("GroupsInfo", json.encode(jsonString));
      } else {
        LocalDB db = LocalDB(localDatabaseName);
        for (GroupInfo gi in groupInfos) {
          db.initDB();
          db.addGroupInfo(gi);
          //  db.listAllTables();
        }
      }

      print(groupInfos);

      // Extract cookie from response headers
      return groupInfos;
    }else if(response.statusCode == 403){
      await auth1.removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      return null;
    }
  }




}

void main() async {
  // Users lists: https://dummyjson.com/users
  //Authentication.fetchAuthenticate("hbingley1", "CQutx25i8r");
}
