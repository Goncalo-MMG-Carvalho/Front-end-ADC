import 'package:adc_handson_session/AppPage/presentation/appPage_screen.dart';
import 'package:flutter/material.dart';
import 'package:adc_handson_session/login/application/auth.dart';
import 'package:adc_handson_session/login/presentation/main_page.dart';

import '../../register/presentation/regist_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();

    super.initState();
  }

  void logInButtonPressed(String username, String password) {

    //TODO: Also check the username
    bool pwCompliant = Authentication.isPasswordCompliant(password);
    bool usCompliant = Authentication.isUsernameCompliant(username);

    if (!pwCompliant) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Invalid password format!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(121, 135, 119, 1),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                height: 1.5,
              ),
              ),
          );
        },
      );
    }
    else if(!usCompliant){
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            backgroundColor: Color.fromRGBO(248, 237, 227, 1),
            contentPadding: EdgeInsets.all(20),
            content: Text("Invalid username format!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(121, 135, 119, 1),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                height: 1.5,
              ),
            ),
          );
        },
      );
    }
    // TODO: Check if the User can be logged in.
    //  API Call to your GoogleAppEngine or Dummy API
    else if (Authentication.loginUser(username, password)) {

      // TODO: Update the DB with the last active time of the user

      Navigator.push( //responsavel por passar para a outra pagina (mainScreen), pilha que empilha as paginas acessadas, podendo assim voltar a tras nas paginas
        context,
        MaterialPageRoute(builder: (context) => const AppPage()),
      );
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 45,
                    //fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                    color: Color.fromRGBO(121, 135, 119, 1),
                  ),
                ),
                // Additional content can be added below the title if needed
              ],
            ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
          child: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Username',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: TextField(
            obscureText: true,
            controller: passwordController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Password',
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(121, 135, 119, 1)),
          ),
          child: const Text('Forgot Password?'),

        ),
        Container(
            height: 80,
            padding: const EdgeInsets.fromLTRB(10,40,10,5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color.fromRGBO(121, 135, 119, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                ),
              ),
              child: const Text('Log In',
                style: TextStyle(
                  color: Color.fromRGBO(248, 237, 227, 1),
                  fontSize: 20,
                  fontFamily: 'Arial',
                )
                ,),
              onPressed: () => logInButtonPressed(
                  usernameController.text, passwordController.text),
            )),
        TextButton(
          onPressed: () {
            Navigator.push( //responsavel por passar para a outra pagina (mainScreen), pilha que empilha as paginas acessadas, podendo assim voltar a tras nas paginas
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
              //MaterialPageRoute(builder: (context) => const AppPage()),
            );
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(121, 135, 119, 1)),
          ),
          child: const Text('New here? Regist'),
        ),
      ],
    );
  }
}
