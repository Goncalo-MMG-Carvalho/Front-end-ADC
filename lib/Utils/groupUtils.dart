import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/login/domain/Group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../login/data/users_local_storage.dart';
import '../login/domain/Messages.dart';
import '../login/domain/User.dart';
import '../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

class groupUtils {

  userUtils uUtils = userUtils();


  Color getGroupColor(String color) {
    int colorValue = int.parse(color, radix: 16);
    return Color(colorValue);
  }

  Future<bool> isAdmin(Group group, String username) async {
    print("GROUP IN ISADMIN :$group");
    print(username);
    var admNames = group.adminNames.split("|");
    print(admNames);
    bool isA = admNames.contains(username);
    print("IS ADM OF THE GROUP: $isA");
    return isA;
  }

  String formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDateTime = DateFormat('HH:mm dd/MM').format(dateTime);
    return formattedDateTime;
  }

  addMessageToGroup(Message message) async {
    if(!kIsWeb){
      LocalDB db = LocalDB(localDatabaseName);
      await db.addMessage(message);
      print("Mensagem adicionada ao grupo: $message");
    }
  }

  Future<List<Message>?> getGroupMessages(Group group) async {
    List<Message>? messageList = [];
    if(!kIsWeb){
      LocalDB db = LocalDB(localDatabaseName);
      final gMessages = await db.getGroupMessages(group.groupName);

      for(Map<String, Object?> msg in gMessages){
        messageList.add(Message.fromMap(msg));
      }
    }

    return messageList;
  }




}