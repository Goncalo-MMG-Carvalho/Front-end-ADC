import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/main.dart';
import 'package:adc_handson_session/profile/application/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../AppPage/presentation/webPage_screen.dart';
import '../../login/domain/User.dart';

class WebProfilePage extends StatefulWidget {
  const WebProfilePage({super.key});
  @override
  State<WebProfilePage> createState() => _WebProfilePage();
}

const String localDatabaseName = "app.db";

class _WebProfilePage extends State<WebProfilePage> {
  final AuthenticationProfile auth = AuthenticationProfile();

  bool isLoading = true;

  User? user;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  void getUserInfo() async {
    User? u = await userUtils().getUserInfo();
    setState(() {
      user = u;
      isLoading = false;
    });
  }

  Future<void> logout() async {
    bool? res = await auth.logout();

    if (res!) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
              title:  Text('Logout Successful',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('You have been successfully logged out.',
                      style: GoogleFonts.getFont(
                        'Inter',
                        textStyle:  TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(82, 130, 103, 1.0),
                    borderRadius: BorderRadius.circular(
                        10), // Optional: Round the corners
                  ),
                  child: TextButton(
                    child: Text(
                      'OK',
                      style: GoogleFonts.getFont(
                        'Inter',
                        textStyle: const TextStyle(
                          color: const Color.fromRGBO(248, 237, 227, 1),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                            (Route<dynamic> route) =>
                        false, // Removes all routes from stack
                      );
                    },
                  ),
                ),
              ],
            );
          });
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
                child: Text(
                  'Profile',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(82, 130, 103, 1.0),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: const Color.fromRGBO(82, 130, 103, 1.0),
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
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  alignment: Alignment.center,
                  width: 350.0,
                  height: 300.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromRGBO(248, 237, 227, 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(121, 135, 119, 1)
                              .withOpacity(0.5), // Shadow color
                          spreadRadius: 5, // Spread radius
                          blurRadius: 7, // Blur radius
                          offset: const Offset(0, 3), // Offset
                        ),
                      ]),
                  //CAIXA COM AS INFORMAÇÕES DO UTILIZADOR
                  child: profileInfo(),
                ),
              ),
              //    const Spacer(),
              Expanded(
                  child: Container(
                      margin:
                      const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                      width: double.infinity,
                      color: const Color.fromRGBO(248, 237, 227, 1),
                      child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.fromLTRB(
                                    20.0, 10.0, 0.0, 10.0),
                                child: Text(
                                  "Account settings",
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    textStyle: TextStyle(
                                      color: Color.fromRGBO(82, 130, 103, 1.0),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                            Expanded(
                              child: Column(children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color:
                                    Color.fromRGBO(248, 237, 227, 1),
                                    border: Border(
                                      top: BorderSide(
                                          color: Color.fromRGBO(
                                              197, 189, 181, 1.0),
                                          width: 0.5),
                                      bottom: BorderSide(
                                          color: Color.fromRGBO(
                                              197, 189, 181, 1.0),
                                          width: 0.5),
                                    ),
                                  ),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                      const Color.fromRGBO(
                                          248, 237, 227, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(0),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.lock_outline,
                                            color: Color.fromRGBO(72, 112, 79, 1.0),
                                        ),
                                        Container(
                                          margin:
                                          const EdgeInsets.fromLTRB(
                                              10.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            "Change password",
                                            style: GoogleFonts.getFont(
                                              'Inter',
                                              textStyle: const TextStyle(
                                                color: Color.fromRGBO(82, 130, 103, 1.0),
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    onPressed: () async {
                                      await changePassword();
                                    },
                                  ),
                                ),

                                //LOGOUT TEM DE SER O ULTIMO DA SEQUENCIA
                                Container(
                                  decoration: const BoxDecoration(
                                    color:
                                    Color.fromRGBO(248, 237, 227, 1),
                                    border: Border(
                                      top: BorderSide(
                                          color: Color.fromRGBO(
                                              197, 189, 181, 1.0),
                                          width: 0.5),
                                      bottom: BorderSide(
                                          color: Color.fromRGBO(
                                              197, 189, 181, 1.0),
                                          width: 0.5),
                                    ),
                                  ),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                      const Color.fromRGBO(
                                          248, 237, 227, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(0),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.logout,
                                          color: Color.fromRGBO(72, 112, 79, 1.0),
                                        ),
                                        Container(
                                          margin:
                                          const EdgeInsets.fromLTRB(
                                              10.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            "Logout",
                                            style: GoogleFonts.getFont(
                                              'Inter',
                                              textStyle: const TextStyle(
                                                color: Color.fromRGBO(82, 130, 103, 1.0),
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    onPressed: () {
                                      logout();
                                    },
                                  ),
                                )
                              ]),
                            )
                          ])))
            ],
          ),
          backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
        ));
  }

  Widget profileInfo() {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topLeft,
        //margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          TextSpan(
                            text: 'Username:\n',
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(105, 147, 112, 1.0),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: user!.username,
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 20.0, bottom: 20.0)),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Email:\n',
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(105, 147, 112, 1.0),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: user!.email,
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 20.0, bottom: 20.0)),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Account type:\n',
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(105, 147, 112, 1.0),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: user!.role,
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
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
              //flex: 1,
              child: Container(
                //alignment: Alignment.topRight,
                padding: const EdgeInsets.only(left: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Name:\n',
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(105, 147, 112, 1.0),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: user!.name,
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 20.0, bottom: 20.0)),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Age:\n',
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(105, 147, 112, 1.0),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: user!.age,
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
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
    );
  }

  Future changePassword() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController previousPasswordController =
        TextEditingController();
        final TextEditingController newPasswordController =
        TextEditingController();
        final TextEditingController confirmNewPasswordController =
        TextEditingController();

        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text('Change password?',
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont(
              'Inter',
              textStyle:  TextStyle(
                color:  const Color.fromRGBO(82, 130, 103, 1.0),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
          content: Text('If you confirm, we will send you an email with a link to change your password.',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('Cancel',
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle:  TextStyle(
                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                bool success = await auth.changePassword(user!.email);
                if (success) {
                  Navigator.of(context).pop();
                }
                else {
                  print("DEU ERRO NO PEDIDO");
                }
              },
              child: Text('Confirm',
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle:  TextStyle(
                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        );

        /*return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              'Change Password',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  color: Color.fromRGBO(82, 130, 103, 1.0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),
          ),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                    controller: previousPasswordController,
                    decoration: InputDecoration(
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(82, 130, 103, 1.0),
                        ),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(
                              82, 130, 103, 1.0), // Set your desired color here
                        ),
                      ),
                      labelText: 'Previous Password',
                      labelStyle: GoogleFonts.getFont(
                        'Inter',
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(82, 130, 103, 0.8),
                        ),
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
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(82, 130, 103, 1.0),
                        ),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(
                              82, 130, 103, 1.0), // Set your desired color here
                        ),
                      ),
                      labelText: 'Enter New Password',
                      labelStyle: GoogleFonts.getFont(
                        'Inter',
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(82, 130, 103, 0.8),
                        ),
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
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                    controller: confirmNewPasswordController,
                    decoration: InputDecoration(
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(82, 130, 103, 1.0),
                        ),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(
                              82, 130, 103, 1.0), // Set your desired color here
                        ),
                      ),
                      labelText: 'Confirm New Password',
                      labelStyle: GoogleFonts.getFont(
                        'Inter',
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(82, 130, 103, 0.8),
                        ),
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
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                iconColor: const Color.fromRGBO(121, 135, 119, 1),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (newPasswordController.text ==
                    confirmNewPasswordController.text) {
                  String? token = await auth.getToken();

                  bool pwCompliant = AuthenticationProfile.isPasswordCompliant(
                      newPasswordController.text);

                  if (pwCompliant) {
                    // Call the changePassword method from Authentication class
                    bool success = await auth.changePassword(user!.email);
                    if (success) {
                      Navigator.of(context).pop();
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor:
                            const Color.fromRGBO(248, 237, 227, 1),
                            contentPadding: const EdgeInsets.all(20),
                            content: Text(
                              "Current password entered is incorrect.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(
                                'Inter',
                                textStyle: TextStyle(
                                  color: Color.fromRGBO(82, 130, 103, 1.0),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child:  Text(
                                  'OK',
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    textStyle: const TextStyle(
                                      color: Color.fromRGBO(82, 130, 103, 1.0),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor:
                          const Color.fromRGBO(248, 237, 227, 1),
                          contentPadding: const EdgeInsets.all(20),
                          content:  Text(
                            "Invalid password format! Needs an Upper Case letter, etc?",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: TextStyle(
                                color: Color.fromRGBO(82, 130, 103, 1.0),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child:  Text(
                                'OK',
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color: Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                        contentPadding: const EdgeInsets.all(20),
                        content:  Text(
                          "Passwords do not match!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.getFont(
                            'Inter',
                            textStyle: TextStyle(
                              color: Color.fromRGBO(82, 130, 103, 1.0),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'OK',
                              style: GoogleFonts.getFont(
                                'Inter',
                                textStyle: const TextStyle(
                                  color: Color.fromRGBO(82, 130, 103, 1.0),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor:
                Color.fromRGBO(82, 130, 103, 1.0), // Green background
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        );*/
      },
    );
  }
}
