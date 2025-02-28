import 'dart:convert';

import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:flutter/material.dart';

import 'Utils/groupUtils.dart';
import 'login/domain/ClosedPoll.dart';
import 'login/domain/Group.dart';
import 'login/domain/Messages.dart';
import 'login/domain/OpenPolls.dart';
import 'login/domain/PollToVote.dart';
import 'login/domain/Requests.dart';
import 'login/presentation/login_screen.dart';
import 'login/data/users_local_storage.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyD64y1BSMir25H-cH4kL2xu1SYMLzk-720",
          authDomain: "projeto-adc-423314.firebaseapp.com",
          projectId: "projeto-adc-423314",
          storageBucket: "projeto-adc-423314.appspot.com",
          messagingSenderId: "937310044902",
          appId: "1:937310044902:web:e6dcd190e003e298ce7127",
          measurementId: "G-Q344DS8CWM"
      ),
    );
  }
  else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCWtafmvtd7635qhcIFVBuj5OZmIm9bYlA',
        authDomain: "projeto-adc-423314.firebaseapp.com",
        appId: '1:937310044902:android:6c3db6494063d678ce7127',
        messagingSenderId: '937310044902',
        projectId: 'projeto-adc-423314',
        storageBucket: "projeto-adc-423314.appspot.com",
      ),
    );
    print('Firebase initialized for Android');
  }
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

 FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle the message when the app is opened from a terminated state
    print('Message opened app: ${message.notification!.title}');

    String type = message.data['type'];
    if(type == 'message') {
      Message message1 = Message.fromJson(message.data);

      groupUtils().addMessageToGroup(message1);
    }
    if(type == 'update'){
      Group g = Group.fromJson2(jsonDecode(message.data["GROUP"])['properties']);

      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.addGroup(g);
      }
    }
    if(type == 'pollToVote') {
      PolltoVote p = PolltoVote.fromJson(jsonDecode(message.data["POLL"]));
      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.addPullToVote(p);
      }
    }
    if( type == 'responsePoll'){

      if (!kIsWeb) {
        updatePoll(message.data['pollId'], message.data['index']);
      }

    }
    if(type == 'closedPoll'){
      Closedpoll p = Closedpoll.fromJson(message.data);
      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.addClosedPoll(p);
      }
    }
    if(type == 'request') {
      Request r = Request.fromJson(message.data);
      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.addRequest(r);
      }
    }
    if(type == 'request_delete') {
      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.deleteRequest(message.data['requestId']);
      }
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensagem recebida em segundo plano: ${message.data}');
  String type = message.data['type'];
  if(type == 'message') {
    Message message1 = Message.fromJson(message.data);

    groupUtils().addMessageToGroup(message1);
  }
  if(type == 'update'){
    Group g = Group.fromJson2(jsonDecode(message.data["GROUP"])['properties']);

    if (!kIsWeb) {
      LocalDB db = LocalDB(localDatabaseName);
      db.addGroup(g);
    }
  }
  if( type == 'responsePoll'){

    if (!kIsWeb) {
      updatePoll(message.data['pollId'], message.data['index']);
    }

  }
  if(type == 'closedPoll'){
    print("IMPORTANTE CLOSED POLL ${message.data}");
    Closedpoll p = Closedpoll.fromJson(message.data);
    if (!kIsWeb) {
      LocalDB db = LocalDB(localDatabaseName);
      db.addClosedPoll(p);
    }
  }
  if(type == 'delete'){
    String? username = await userUtils().getUsername();
    if (!kIsWeb) {
      LocalDB db = LocalDB(localDatabaseName);
      db.deleteGroup(message.data['group_name']);
      db.removeGroupInfoByUsername(message.data['group_name'], username!);
    }

  }
  if(type == 'pollToVote') {
    PolltoVote p = PolltoVote.fromJson(jsonDecode(message.data["POLL"]));
    if (!kIsWeb) {
      LocalDB db = LocalDB(localDatabaseName);
      db.addPullToVote(p);
    }
  }
  if(type == 'request') {
    print(message.data);
    Request r = Request.fromJson(message.data);
    if (!kIsWeb) {
      LocalDB db = LocalDB(localDatabaseName);
      db.addRequest(r);
    }
  }
  if(type == 'request_delete') {
    if (!kIsWeb) {
      LocalDB db = LocalDB(localDatabaseName);
      db.deleteRequest(message.data['requestId']);
    }
  }
}

Future<void> updatePoll(String pollId, String index) async {
  LocalDB db = LocalDB(localDatabaseName);
  OpenPoll op = await db.getOpenPoll(pollId);

  int updatesVotes = int.parse(op.totalVotes) + 1;

  op.totalVotes = updatesVotes.toString();

  int i = int.parse(index);

  List<String> elements = op.fields.split('|');
  List<String> parts = elements[i].split(':');
  int value = int.parse(parts[1]) + 1;
  elements[i] = '${parts[0]}:$value';
  String updatedFields = elements.join('|');

  op.fields = updatedFields;
  db.addOpenPoll(op);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Uncomment later on to test the Local DB
  // Test it on Android! Doesn't work on the browser
  void accessDB(){
    LocalDB db = LocalDB(localDatabaseName);
    db.initDB();
    db.countUsers();
    db.listAllTables();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Login',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.black),
          textTheme: const TextTheme(
            titleMedium: TextStyle(color: Colors.black),
          ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: const OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        home: Scaffold(
            backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(60, 0, 0, 0),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 300,
                      height: 200,
                    ),
                  ),
                  Center(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 70),
                        alignment: Alignment.center,
                        width: 350.0,
                        height: 550.0,
                        decoration:  BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors:[
                                Color.fromRGBO(248, 237, 227, 1),
                                Color.fromRGBO(189, 210, 182, 1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                              color: const Color.fromRGBO(121, 135, 119, 1).withOpacity(0.5), // Shadow color
                              spreadRadius: 5, // Spread radius
                              blurRadius: 7, // Blur radius
                              offset: const Offset(0, 3), // Offset
                              ),
                            ]
                        ),
                        child: const LoginScreen(),
                      ),
                    ),
                ],
            )
    )
    ));
  }
}