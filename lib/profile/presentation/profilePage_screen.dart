import 'package:adc_handson_session/MapPage/presentation/mapPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adc_handson_session/login/data/users_local_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

const String localDatabaseName = "app.db";
String username = "";

class _ProfilePage extends State<ProfilePage> {



  @override
  void initState() {
    super.initState();
    getUsername();
  }

  Future<void> getUsername() async {
    if(kIsWeb){
      final token = localStorage.getItem("token");
      print("TOKEN: $token");
      final parts = token?.split(".");
      username = parts![0].split("u003d")[1].toString();
      print(username);

    }else {

      LocalDB db = LocalDB(localDatabaseName);
      print("TAMOS NO PROFILE PAGE STATE INIT");
      db.getUsername();

    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Profile',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
                  title: Center(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      child: const Text(
                          "Profile",
                        style: TextStyle(
                          fontFamily: "Arial",
                          fontSize: 36,
                          color: Color.fromRGBO(248, 237, 227, 1),
                        ),
                      ),
                    ),
                    //APAGAR SE NAO QUISER TER O LOGO NO TITLE
                    /*child: Image.asset(
                      'assets/logo.png', // Replace with your image path
                      height: 70, // Adjust the height as needed
                    ),*/
                  ),
                  leading:
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: const Color.fromRGBO(121, 135, 119, 1),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  actions: [
                    Container(
                      //PARA O LOGO FICAR CENTRADO (PODE HAVER UMA MANEIRA MELHOR)
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    )
                  ],
                ),
                body:  Column(
                  children: [
                    Center(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 70),
                      alignment: Alignment.center,
                      width: 350.0,
                      height: 300.0,
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
                      child: profileInfo(),
                    ),


                    ),
                  ],
                ),
                backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
            )
    );
  }

  Widget profileInfo() {
    return Column(
      children: [

          /*child: Text(
            "Username: \n$username",
            style: TextStyle(
              fontFamily: "Arial",

            ),*/
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Username:\n',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 15, // Size for "Username:"
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(121, 135, 119, 1),// Optional, to make "Username:" bold
                  ),
                ),
                TextSpan(
                  text: username,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 20, // Size for the username variable
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(121, 135, 119, 1),
                  ),
                ),
              ],
            ),
          ),
        )

      ],
    );
  }





}