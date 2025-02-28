import 'dart:convert';

import 'package:adc_handson_session/profile/application/auth.dart';
import 'package:adc_handson_session/statisticsPage/presentation/UserStatisticsElecPage_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adc_handson_session/login/data/users_local_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../login/domain/User.dart';
import '../../statisticsPage/presentation/UserStatisticsWaterPage_screen.dart';
import '../../Utils/constants.dart' as constants;
import '../../statisticsPage/presentation/WebUserStatisticsElecPage_screen.dart';

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;



class UserInfoPage extends StatefulWidget {
  final User user;

  const UserInfoPage({super.key, required this.user});
  @override
  State<UserInfoPage> createState() => _UserInfoPage();
}

class _UserInfoPage extends State<UserInfoPage> {
  String username = "";

  final AuthenticationProfile auth = AuthenticationProfile();

  List<String>? trophies;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "${widget.user.username}'s information",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
            title: Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  "${widget.user.username}'s information",
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(82, 130, 103, 1.0),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: Color.fromRGBO(82, 130, 103, 1.0),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              Container(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              )
            ],
          ),
          body:  Column(
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
                    ElevatedButton(
                        onPressed: () {
                          if(kIsWeb) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => WebUserStatisticsElectricityPage(user: widget.user)),
                            );
                          }else
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserStatisticsElectricityPage(user: widget.user)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(82, 130, 103, 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'View Statistics',
                          style: GoogleFonts.getFont(
                            'Inter',
                            textStyle: const TextStyle(
                              color: Color.fromRGBO(248, 237, 227, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        )),
                    //    const Spacer
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
                            text: widget.user.username,
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
                            text: widget.user.email,
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
                            text: widget.user.role,
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
                            text: widget.user.name,
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
                            text: widget.user.age,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }





}
