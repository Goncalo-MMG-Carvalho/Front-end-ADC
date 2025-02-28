import 'dart:convert';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/login/domain/Group.dart';
import 'package:adc_handson_session/login/domain/OpenPolls.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Utils/firebaseUtils.dart';
import '../../exceptions/invalid_token.dart';
import '../../login/data/users_local_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import '../../Utils/constants.dart' as constants;
import '../../login/domain/ClosedPoll.dart';
import '../../profile/application/auth.dart';

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class AuthenticationGroup {

  userUtils uUtils = userUtils();

  Future<Group?> getGroup(String groupName) async {
    try{
      Group? group;
      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        if(!await db.groupExists(groupName)) {
          group = await fetchAuthenticateGetGroup(groupName);
          db.addGroup(group!);
        }else{
          final dbGroup = await db.getGroup(groupName);
          group = Group.fromMap(dbGroup.first);
        }

      }else {
        group = await fetchAuthenticateGetGroup(groupName);
      }
      print(group);

      return group;
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<Group?> fetchAuthenticateGetGroup(String groupName) async {
    String? token = await uUtils.getToken();
    final http.Response response;
    if(kIsWeb){
       response = await http.post(
        Uri.parse(
            'https://projeto-adc-423314.ew.r.appspot.com/rest/get_group/v1'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'cookie': token!,
          'groupName': groupName,
          'fbToken': '',
        }),
      );
    }else {

      String? fbToken = await firebaseUtils().getToken(_firebaseMessaging);
       response = await http.post(
        Uri.parse(
            'https://projeto-adc-423314.ew.r.appspot.com/rest/get_group/v1'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'cookie': token!,
          'groupName': groupName,
          'fbToken': fbToken!,
        }),
      );
    }
    if (response.statusCode == 200) {
      //SE FOI CRIADO COM SUCESSO ADICIONAR GRUPO ÀS PERSISTENCIAS
      print(jsonDecode(response.body));

      Map<String, dynamic> responseData = jsonDecode(response.body);

      Map<String, dynamic> properties = responseData['properties'];
      print(properties);

      Group group = Group.fromJson2(properties);
      print("GRUPO FROM JSON $group");

      //FALTA PASSAR OS DADOS PARA O G
      // Extract cookie from response headers
      return group;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      return null;
    }
  }


  dynamic getGroupRequests(String groupName){
    try{
     return fetchAuthenticateGetGroupRequests(groupName);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<dynamic> fetchAuthenticateGetGroupRequests(String groupName) async {
    String? token = await uUtils.getToken();

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/get_group_requests/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'groupName': groupName,
      }),
    );

    if (response.statusCode == 200) {
      var requests = jsonDecode(response.body);

      print("REQUESTS: ${jsonDecode(response.body)}");

      return requests;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      return null;
    }
  }


  Future<bool> requestResponse(String groupName, String username, String id, bool accept) async {
    try{
      return await fetchAuthenticateResponseRequest(groupName, username, id, accept);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchAuthenticateResponseRequest(String groupName, String username, String id, bool accept) async {
    String? token = await uUtils.getToken();

    print("INFOS $username $groupName");

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/handle_group_request/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'cookie': token!,
        'groupName': groupName,
        'userToHandle': username,
        'accepted': accept,
        'requestId': id,
      }),
    );

    if (response.statusCode == 200) {
      var requests = jsonDecode(response.body);
      print("TAMOS NO ACCEPT REQUEST $requests");

      if(accept){
        Map<String, dynamic> responseData = requests;

        Map<String, dynamic> properties = responseData['properties'];
        print("properties: $properties");

        Group group = Group.fromJson2(properties);
        print("GRUPO FROM JSON NO ACCEPT REQUEST $group");

        if (!kIsWeb) {
          LocalDB db = LocalDB(localDatabaseName);
          db.addGroup(group);
        }
      }

      print("REQUESTS: ${jsonDecode(response.body)}");

      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      return false;
    }
  }

  Future<void> removeUserFromGroup(Group group) async {
    String? username = await uUtils.getUsername();

    GroupInfo toRemove = GroupInfo(username: username!, groupName: group.groupName, color: group.color);

    if (kIsWeb) {
      await initLocalStorage();
      WidgetsFlutterBinding.ensureInitialized();

      String? info = localStorage.getItem("GroupsInfo");

      var infoList = json.decode(info!);
      List<dynamic> jsonList = jsonDecode(infoList);
      List<GroupInfo> groupInfos = jsonList.map((map) => GroupInfo.fromMap(json.decode(map))).toList();

      groupInfos.removeWhere((gi) => gi.username == toRemove.username && gi.groupName == toRemove.groupName && gi.color == toRemove.color);

      String jsonString = jsonEncode(groupInfos.map((group) => json.encode(group.toMap())).toList());
      print("GROUP INFOR DEPOIS DE REMOVER: $jsonString");

      localStorage.setItem("GroupsInfo", json.encode(jsonString));

    } else {

      LocalDB db = LocalDB(localDatabaseName);
      db.removeGroupInfo(toRemove);

    }

  }

  Future<bool> leaveGroup(Group group) async {
    try {
      bool res = await fetchAuthenticateLeaveGroup(group.groupName);

      if (res) {
        await removeUserFromGroup(group);
      }

      return res;
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchAuthenticateLeaveGroup(String groupName) async {
    String? token = await uUtils.getToken();

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/leave_group/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'cookie': token!,
        'groupName': groupName,
      }),
    );

    if (response.statusCode == 200) {
      var requests = jsonDecode(response.body);

      print("REQUESTS: ${jsonDecode(response.body)}");

      print(jsonDecode(response.body));

      Map<String, dynamic> responseData = jsonDecode(response.body);

      Map<String, dynamic> properties = responseData['properties'];
      print(properties);

      Group group = Group.fromJson2(properties);
      print("GRUPO FROM JSON $group");

      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
          db.addGroup(group);
      }

      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');

    } else {
      return false;
    }
  }


  Future<bool> removeUser(Group group, String userToRemove) async {
    try{
    return await fetchAuthenticateRemoveUser(group.groupName, userToRemove);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchAuthenticateRemoveUser(String groupName, String userToRemove) async {
    String? token = await uUtils.getToken();
    print(groupName);
    print(userToRemove);

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/remove_user_from_group/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'groupName': groupName,
        'userToRemove': userToRemove,
      }),
    );

    if (response.statusCode == 200) {
      var requests = jsonDecode(response.body);

      print("REQUESTS: ${jsonDecode(response.body)}");

      print(jsonDecode(response.body));

      Map<String, dynamic> responseData = jsonDecode(response.body);

      Map<String, dynamic> properties = responseData['properties'];
      print(properties);

      Group group = Group.fromJson2(properties);
      print("GRUPO FROM JSON $group");

      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.addGroup(group);
      }

      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      return false;
    }
  }


  Future<bool> roleTransition(Group group, String userToTransition, bool promote) async {
    try{
    return await fetchAuthenticateTransition(group.groupName, userToTransition, promote);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchAuthenticateTransition(String groupName, String userToTransition, bool promote) async {
    String? token = await uUtils.getToken();
    print(groupName);
    print(userToTransition);
    print("PROMOTE OR DEMOTE: $promote");

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/group_role_change/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'cookie': token!,
        'groupName': groupName,
        'userToHandle': userToTransition,
        'accepted': promote,
      }),
    );

    if (response.statusCode == 200) {
      var requests = jsonDecode(response.body);

      print("REQUESTS: ${jsonDecode(response.body)}");

      print(jsonDecode(response.body));

      Map<String, dynamic> responseData = jsonDecode(response.body);

      Map<String, dynamic> properties = responseData['properties'];
      print(properties);

      Group group = Group.fromJson2(properties);
      print("GRUPO FROM JSON $group");

      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.addGroup(group);
      }

      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print(response.body);
      return false;
    }
  }


  void sendMessage(String messageToSend, Group group) {
    try{
    fetchAuthenticateSendMessage(messageToSend, group);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchAuthenticateSendMessage(String messageToSend, Group group) async {
    String? token = await uUtils.getToken();

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/send_message/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'cookie': token,
        'group': group.groupName,
        'message': messageToSend,
      }),
    );

    if (response.statusCode == 200) {


      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      return false;
    }
  }

  Future<bool> createPoll(String title, List<String> fields, String groups) async {
    try{
    return await fetchAuthenticateCreatePoll(title, fields, groups);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchAuthenticateCreatePoll(String title, List<String> fields, String groups) async {
    String? token = await uUtils.getToken();

    String fieldsString = fields.join("|");
    print("FIELD STRINGS $fieldsString");

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/create_poll/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'cookie': token,
        'groupNames': groups,
        'title': title,
        'fields': fieldsString,
      }),
    );

    if (response.statusCode == 200) {

      Map<String, dynamic> responseData = jsonDecode(response.body);
      print("RESPONSE DATA DO CREATE POLL: $responseData");

      OpenPoll poll = OpenPoll.fromJson(jsonDecode(response.body));

      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        await db.initDB();
        db.addOpenPoll(poll);
      }

      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      return false;
    }
  }

  Future<bool> endPoll(OpenPoll poll) async {
    try {
      return await fetchAuthenticateEndPoll(poll);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchAuthenticateEndPoll(OpenPoll poll) async {
    String? token = await uUtils.getToken();

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/close_poll/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'cookie': token,
        'pollId': poll.pollId,
        'groups': poll.groups,
        'fields': poll.fields,
        'title' : poll.title,
        'totalVotes' : poll.totalVotes,
      }),
    );

    if (response.statusCode == 200) {

      //Closedpoll poll = Closedpoll.fromJson(jsonDecode(response.body));

      //if (!kIsWeb) {
      //  LocalDB db = LocalDB(localDatabaseName);
      //  db.addClosedPoll(poll);
      //}

      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      return false;
    }
  }

  Future<bool> castVote(String pollId, String field) async {
    try{
    return await fetchAuthenticateCastVote(pollId, field);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<bool> fetchAuthenticateCastVote(String pollId, String field) async {
    String? token = await uUtils.getToken();

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/send_vote/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'cookie': token,
        'pollId': pollId,
        'index': field,
      }),
    );

    if (response.statusCode == 200) {


      print("OK VOTED");

      return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      return false;
    }
  }




}