import 'dart:async';
import 'dart:convert';

import 'package:adc_handson_session/Utils/groupUtils.dart';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../login/domain/Group.dart';
import '../../login/domain/Messages.dart';

import 'package:http/http.dart' as http;

class firebaseUtils{

  Future<String?> getToken(FirebaseMessaging firebaseMessaging) async {
    String? tokenFb = await firebaseMessaging.getToken();
    print('Token: $tokenFb');
    return tokenFb;
  }

  Future<void> sendTokenToServer(Group group, FirebaseMessaging firebaseMessaging) async {
    String? fbToken = await getToken(firebaseMessaging);
    String? token = await userUtils().getToken();

    final response = await http.post(
      Uri.parse(
          'https://projeto-adc-423314.ew.r.appspot.com/rest/subscribe_topic/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'fbToken': fbToken!,
        'group': group.groupName,
      }),
    );

    if (response.statusCode == 200) {
      print('Token enviado com sucesso para o backend');
    } else {
      print('Falha ao enviar token para o backend');
    }

  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Mensagem recebida em segundo plano: ${message.data}');
    Message message1 = Message.fromJson(message.data);
    groupUtils().addMessageToGroup(message1);
  }

}