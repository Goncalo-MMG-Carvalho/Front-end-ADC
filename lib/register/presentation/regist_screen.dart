import 'package:adc_handson_session/main.dart';
import 'package:flutter/material.dart';
import 'package:adc_handson_session/register/application/auth.dart';
import 'package:google_fonts/google_fonts.dart';





class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}


enum TipoConta { personal, business }

class _RegisterScreen extends State<RegisterScreen>{
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController confPasswordController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController ageController;
  TipoConta? tipoContaSelecionado = TipoConta.personal;
  //TipoConta? tipoContaSelecionado;

  @override
  void initState() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    confPasswordController = TextEditingController();
    emailController = TextEditingController();
    ageController = TextEditingController();
    super.initState();
  }


 Future<void> registerButtonPressed(String username, String password,
     String confirmationPassword, String name, String email, String age, String tipo) async {

      bool usCompliant = Authentication.isUsernameCompliant(username);
      bool pwCompliant = Authentication.isPasswordCompliant(password);
      bool cpCompliant = Authentication.isConfirmationCompliant(password, confirmationPassword);
      bool nmCompliant = Authentication.isNameCompliant(name);
      bool emCompliant = Authentication.isEmailCompliant(email);
      bool agCopliant = Authentication.isAgeCompliant(age);

      if(!pwCompliant){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Invalid password format! Needs an Upper Case letter, Special Character and a Number.",
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
            );
          },
        );
      }
      else if(!usCompliant){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Invalid username format!",
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
            );
          },
        );
      }
      else if(!cpCompliant){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Passwords are different!",
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
            );
          },
        );
      }
      else if(!nmCompliant){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Invalid name!",
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
            );
          },
        );
      }
      else if(!emCompliant){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Invalid email format!",
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
            );
          },
        );
      }
      else if(!agCopliant){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Invalid age!",
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
            );
          },
        );
      }
      else if(await Authentication.registerUser(username, password, email, name, age, tipo)){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
              title: Text('$username registered',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: TextStyle(
                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Text('To login you need to activate your account, we sent you an email!',
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
                  child:  Text('OK',
                    style: GoogleFonts.getFont(
                      'Inter',
                      textStyle: const TextStyle(
                        color:  const Color.fromRGBO(82, 130, 103, 1.0),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fechar o diálogo
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
      else{
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              //VERIFICAR QUE MENSAGEM COLOCAR AQUI
              content: Text("Regist gone wrong!",
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
            );
          },
        );
      }
 }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Regist',
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
            child: Center(
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
                        height: 1100.0,
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
                         child: Column(
                           children: [
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                               child:  Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[
                                   Text('Register',
                                     style: GoogleFonts.getFont('Inter',
                                       textStyle: const TextStyle(
                                         color: Color.fromRGBO(82, 130, 103, 1.0),
                                         fontSize: 40,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                   ),
                                   // Additional content can be added below the title if needed
                                 ],
                               ),
                             ),
                             //USERNAME
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                               child: TextField(
                                 cursorColor: const Color.fromRGBO(82, 130, 103, 1.0), // Set the cursor color here
                                 controller: usernameController,
                                 decoration: InputDecoration(
                                   border: const UnderlineInputBorder(),
                                   labelText: 'Username',
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
                             //NAME
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                               child: TextField(
                                 cursorColor: const Color.fromRGBO(82, 130, 103, 1.0), // Set the cursor color here
                                 controller: nameController,
                                 decoration: InputDecoration(
                                   border: const UnderlineInputBorder(),
                                   labelText: 'Name',
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
                             //EMAIL
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                               child: TextField(
                                 cursorColor: const Color.fromRGBO(82, 130, 103, 1.0), // Set the cursor color here
                                 controller: emailController,
                                 decoration: InputDecoration(
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
                             //PASSWORD
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                               child: TextField(
                                 cursorColor: const Color.fromRGBO(82, 130, 103, 1.0), // Set the cursor color here
                                 obscureText: true,
                                 controller: passwordController,
                                 decoration: InputDecoration(
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
                             //PASSWORD CONFIRMATION
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                               child: TextField(
                                 cursorColor: const Color.fromRGBO(82, 130, 103, 1.0), // Set the cursor color here
                                 obscureText: true,
                                 controller: confPasswordController,
                                 decoration: InputDecoration(
                                   border: const UnderlineInputBorder(),
                                   labelText: 'Confirmation Password',
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
                             //BIRTHDAY
                             /*
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                               child: DOBInputField(
                                 firstDate: DateTime(1900),
                                 lastDate: DateTime.now(),
                                 showLabel: true,
                                 dateFormatType: DateFormatType.DDMMYYYY,
                                 autovalidateMode: AutovalidateMode.always,
                                 fieldLabelText: "With label",
                               ),
                             ),
                             */
                             //AGE (BEFORE AGE IS ALRIGHT)
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                               child: TextField(
                                 cursorColor: const Color.fromRGBO(82, 130, 103, 1.0), // Set the cursor color here
                                 controller: ageController,
                                 decoration: InputDecoration(
                                   border: const UnderlineInputBorder(),
                                   labelText: 'Age',
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
                             Container(// Adjust the height as needed to accommodate the content
                               child: selectConta(),
                             ),
                             Container(
                                 height: 80,
                                 padding: const EdgeInsets.fromLTRB(10,30,10,5),
                                 child: ElevatedButton(
                                   style: ElevatedButton.styleFrom(
                                     minimumSize: const Size.fromHeight(50),
                                     backgroundColor: const Color.fromRGBO(82, 130, 103, 1.0),
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                     ),
                                   ),
                                   child:  Text('Register',
                                     style: GoogleFonts.getFont('Inter',
                                       textStyle: const TextStyle(
                                         color: Color.fromRGBO(248, 237, 227, 1),
                                         fontSize: 20,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                   ),
                                   onPressed: () => registerButtonPressed(
                                       usernameController.text, passwordController.text, confPasswordController.text,
                                        nameController.text, emailController.text/*, birthDate.text */, ageController.text, tipoContaSelecionado.toString()),
                                 )),
                             TextButton(
                               onPressed: () {
                                 Navigator.push( //responsavel por passar para a outra pagina (mainScreen), pilha que empilha as paginas acessadas, podendo assim voltar a tras nas paginas
                                   context,
                                   // passar para outro eventual screen, o da app, ou o de Login mesmo
                                   MaterialPageRoute(builder: (context) => const MyApp()),
                                 );
                               },
                               style: ButtonStyle(
                                 foregroundColor: WidgetStateProperty.all<Color>(const Color.fromRGBO(121, 135, 119, 1)),
                               ),
                               child:  Text('Already have an account? Log in',
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
                         ),
                      //  child: const LoginScreen(),
                      ),
                    ),
                    Container(
                      padding:  const EdgeInsets.fromLTRB(0,0,0,25),
                    )
                    // TODO: uncomment to test the Local DB (Android)
                    //FloatingActionButton(onPressed: accessDB),
                  ],
                )
            )
        )
        ),
    );
  }


  Widget selectConta(){
    return Column(
      children: <Widget>[
         Padding(padding: const EdgeInsets.fromLTRB(30, 15, 15, 0),
          child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
                "Account type:",
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: RadioListTile<TipoConta>(
          title: Text('Personal',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(82, 130, 103, 1.0),
              ),
            ),
          ),
          value: TipoConta.personal,
          groupValue: tipoContaSelecionado,
          activeColor: const Color.fromRGBO(82, 130, 103, 1.0),
          onChanged: (TipoConta? value) {
            setState(() {
              tipoContaSelecionado = value;
            });
          },
        ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: RadioListTile<TipoConta>(
          title: Text('Business',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(82, 130, 103, 1.0),
              ),
            ),
          ),
          value: TipoConta.business,
          groupValue: tipoContaSelecionado,
          activeColor: const Color.fromRGBO(82, 130, 103, 1.0),
          onChanged: (TipoConta? value) {
            setState(() {
              tipoContaSelecionado = value;
              print(tipoContaSelecionado);
            });
          },
        ),
        )
      ],
    );
  }


}






