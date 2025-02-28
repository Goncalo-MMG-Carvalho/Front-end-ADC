import 'package:adc_handson_session/AppPage/presentation/appPage_screen.dart';
import 'package:adc_handson_session/AppPage/presentation/webPage_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adc_handson_session/login/application/auth.dart';

import '../../register/presentation/regist_screen.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color.fromRGBO(82, 130, 103, 1.0),
          selectionColor: Color.fromRGBO(82, 130, 103, 0.5),
          selectionHandleColor: Color.fromRGBO(82, 130, 103, 1.0),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}


class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  Authentication auth = Authentication();

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();

    super.initState();
  }


  Future<void> logInButtonPressed(String username, String password) async {

    if (await auth.loginUser(username, password)) {

      if(kIsWeb) {
        Navigator.pushReplacement( //responsavel por passar para a outra pagina (mainScreen), pilha que empilha as paginas acessadas, podendo assim voltar a tras nas paginas
          context,
          MaterialPageRoute(builder: (context) => const WebPage()),
        );
      }else{
        Navigator.pushReplacement( //responsavel por passar para a outra pagina (mainScreen), pilha que empilha as paginas acessadas, podendo assim voltar a tras nas paginas
          context,
          MaterialPageRoute(builder: (context) => const AppPage()),
        );
      }

    } else {
      // Wrong credentials
      showDialog(
        context: context,
        builder: (context) {
          return  AlertDialog(
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            content: Text("Wrong Password!",
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
            actions: <Widget>[
              TextButton(
                child:  Text(
                  'OK',
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void forgotPassword(String email) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            title: Text('Email Sent',
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
            content: Text('An email has been sent to $email with instructions to reset your password.',
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
                child:  Text(
                  'OK',
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    auth.forgotPassword(email);

  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome',
                  style: GoogleFonts.getFont(
                    'Inter', // Replace with your desired Google Font
                    fontSize: 45,
                    fontWeight: FontWeight.normal,
                    color: const Color.fromRGBO(82, 130, 103, 1.0),
                  ),
                ),
                // Additional content can be added below the title if needed
              ],
            ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
          child: TextField(
            cursorColor: const Color.fromRGBO(82, 130, 103, 1.0), // Set the cursor color here
            controller: emailController,
            decoration:  InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'Email',
              labelStyle: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade800,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(82, 130, 103, 1.0),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: TextField(
            cursorColor: const Color.fromRGBO(82, 130, 103, 1.0), // Set the cursor color here
            obscureText: true,
            controller: passwordController,
            decoration:  InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'Password',
              labelStyle: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade800,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(82, 130, 103, 1.0),
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            _showResetPasswordDialog(context);
          },
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(121, 135, 119, 1)),
          ),
          child:  Text('Forgot Password?',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Color.fromRGBO(82, 130, 103, 1.0),
              ),
            ),
          ),

        ),
        Container(
            height: 80,
            padding: const EdgeInsets.fromLTRB(10,40,10,5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color.fromRGBO(82, 130, 103, 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                ),
              ),
              child: Text('Log In',
                style: GoogleFonts.getFont('Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () => logInButtonPressed(
                  emailController.text, passwordController.text),
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
            foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(121, 135, 119, 1)),
          ),
          child: Text('New here? Register',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Color.fromRGBO(82, 130, 103, 1.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title:  Text('Reset Password',
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
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: "Enter your email",
              hintStyle: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child:  Text('Cancel',
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit',
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
              onPressed: () {
                Navigator.of(context).pop();
                forgotPassword(emailController.text);
              },
            ),
          ],
        );
      },
    );
  }


}
