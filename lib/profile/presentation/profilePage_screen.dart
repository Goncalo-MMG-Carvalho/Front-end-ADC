import 'package:adc_handson_session/MapPage/presentation/mapPage.dart';
import 'package:flutter/material.dart';




class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Profile',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
                  title: Center(
                    child: Image.asset(
                      'assets/logo.png', // Replace with your image path
                      height: 70, // Adjust the height as needed
                    ),
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
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    )
                  ],
                ),
                backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            )
    );
  }
}