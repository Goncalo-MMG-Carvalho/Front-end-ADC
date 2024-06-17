import 'dart:ui';

import 'package:adc_handson_session/MapPage/presentation/mapPage.dart';
import 'package:adc_handson_session/profile/application/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adc_handson_session/login/data/users_local_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:localstorage/localstorage.dart';




class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

const String localDatabaseName = "app.db";



class _ProfilePage extends State<ProfilePage> {

  String username = "";

  final Authentication auth = Authentication();

  bool isLoading = true;

  //tem que ter o null, porque para correr precisa de estar inicializado
  userInfo? user;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  void getUserInfo() async {
    userInfo? user1 = await auth.getUser();
    setState(() {
       user = user1;
       isLoading = false;
    });
  }

  void changePasswordButtonPressed(String username, String oldPassword, String newPassword) {

    //Organizar melhor depois (usado por causa de nao poder ser chamado estaticamente)
    Authentication auth = Authentication();
    // TODO: Check if the User can be logged in.
    //  API Call to your GoogleAppEngine or Dummy API
    if (auth.changePassword(username, oldPassword, newPassword)) {



      /*Navigator.push( //responsavel por passar para a outra pagina (mainScreen), pilha que empilha as paginas acessadas, podendo assim voltar a tras nas paginas
        context,
        MaterialPageRoute(builder: (context) => const AppPage()),
      );*/
    } else {
      // Wrong credentials
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Wrong Password!"),
          );
        },
      );
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
                body: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                  children: [

                    Center(
                      child: Container(
                        margin: EdgeInsets.all(20),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                        //CAIXA COM AS INFORMAÇÕES DO UTILIZADOR
                        child: profileInfo(),
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      child:Container(
                        margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                        width: double.infinity,
                        color: const Color.fromRGBO(248, 237, 227, 1),
                        child:  Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                             Container(
                               alignment: Alignment.topLeft,
                                margin: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                                child: const Text(
                                  "Account settings",
                                  style: TextStyle(
                                  fontFamily: "Arial",
                                  fontSize: 20,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                  ),
                                )
                             ),

                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                      color: Color.fromRGBO(248, 237, 227, 1),
                                      border: Border(
                                        top: BorderSide(color: Color.fromRGBO(197, 189, 181, 1.0), width: 0.5),
                                        bottom: BorderSide(color: Color.fromRGBO(197, 189, 181, 1.0), width: 0.5),
                                      ),
                                      ),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                          padding: const EdgeInsets.all(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.lock_outline,
                                              color: Color.fromRGBO(121, 135, 119, 1),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                              child: const Text(
                                                "Change password",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(121, 135, 119, 1),
                                                  fontFamily: "Arial",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        onPressed: () {
                                          // TODO METER CHANGE PASSWORD
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              final TextEditingController previousPasswordController = TextEditingController();
                                              final TextEditingController newPasswordController = TextEditingController();
                                              final TextEditingController confirmNewPasswordController = TextEditingController();

                                              return AlertDialog(
                                                backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                title: Center(
                                                  child: Text(
                                                    'Change Password',
                                                    style: TextStyle(
                                                      fontFamily: 'Arial',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color.fromRGBO(121, 135, 119, 1),
                                                    ),
                                                  ),
                                                ),
                                                content: Form(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      TextFormField(
                                                        controller: previousPasswordController,
                                                        decoration: const InputDecoration(
                                                          labelText: 'Previous Password',
                                                          labelStyle: TextStyle(color: Color.fromRGBO(121, 135, 119, 1)),
                                                          enabledBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Color.fromRGBO(121, 135, 119, 1)),
                                                          ),
                                                        ),
                                                        obscureText: true,
                                                        validator: (value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Please enter your previous password';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      TextFormField(
                                                        controller: newPasswordController,
                                                        decoration: const InputDecoration(
                                                          labelText: 'New Password',
                                                          labelStyle: TextStyle(color: Color.fromRGBO(121, 135, 119, 1)),
                                                          enabledBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Color.fromRGBO(121, 135, 119, 1)),
                                                          ),
                                                        ),
                                                        obscureText: true,
                                                        validator: (value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Please enter a new password';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      TextFormField(
                                                        controller: confirmNewPasswordController,
                                                        decoration: const InputDecoration(
                                                          labelText: 'Confirm New Password',
                                                          labelStyle: TextStyle(color: Color.fromRGBO(121, 135, 119, 1)),
                                                          enabledBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Color.fromRGBO(121, 135, 119, 1)),
                                                          ),
                                                        ),
                                                        obscureText: true,
                                                        validator: (value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Please confirm your new password';
                                                          } else if (value != newPasswordController.text) {
                                                            return 'Passwords do not match';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      iconColor: Color.fromRGBO(121, 135, 119, 1),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    child: const Text('Confirm'),
                                                    onPressed: () => changePasswordButtonPressed(
                                                      user!.username, previousPasswordController.text, newPasswordController.text),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Colors.blue, // Adjust colors as needed
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                        },
                                      ),
                                    ),

                                    //LOGOUT TEM DE SER O ULTIMO DA SEQUENCIA
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Color.fromRGBO(248, 237, 227, 1),
                                        border: Border(
                                          top: BorderSide(color: Color.fromRGBO(197, 189, 181, 1.0), width: 0.5),
                                          bottom: BorderSide(color: Color.fromRGBO(197, 189, 181, 1.0), width: 0.5),
                                        ),
                                      ),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                          padding: const EdgeInsets.all(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.logout,
                                              color: Color.fromRGBO(121, 135, 119, 1),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                              child: const Text(
                                                "Logout",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(121, 135, 119, 1),
                                                  fontFamily: "Arial",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        onPressed: () {
                                          // TODO METER LOGOUT
                                        },
                                      ),
                                    )
                                  ]
                                ),
                              )
                          ]
                        )
                      )
                    )
                  ],
                ),
                backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
            )
    );
  }


  Widget profileInfo() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            //margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            child: Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Username:\n',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                              TextSpan(
                                text: user!.username,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 20.0, bottom: 20.0)
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Email:\n',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                              TextSpan(
                                text: user!.email,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 20.0, bottom: 20.0)
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Account type:\n',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                              TextSpan(
                                text: user!.role,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(left: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(top: 85.0)
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Name:\n',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                              TextSpan(
                                text: user!.name,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 20.0, bottom: 20.0)
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Age:\n',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                              TextSpan(
                                text: user!.age,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(121, 135, 119, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }





}
