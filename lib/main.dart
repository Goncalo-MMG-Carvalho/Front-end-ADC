import 'package:flutter/material.dart';

import 'login/data/users_local_storage.dart';
import 'login/presentation/login_screen.dart';

void main() {
  runApp(const MyApp());
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
            backgroundColor: const Color.fromRGBO(162, 178, 159, 1),
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
                        height: 500.0,
                        decoration:  BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromRGBO(248, 237, 227, 1),
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
                  // TODO: uncomment to test the Local DB (Android)
                  //FloatingActionButton(onPressed: accessDB),
                ],
            )
    )
    ));
  }
}