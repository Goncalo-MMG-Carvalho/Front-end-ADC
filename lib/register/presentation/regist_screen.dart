import 'package:adc_handson_session/main.dart';
import 'package:flutter/material.dart';
import 'package:adc_handson_session/register/application/auth.dart';




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


 void registerButtonPressed(String username, String password,
     String confirmationPassword, String name, String email, String age, String tipo){

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
      else if(!cpCompliant){
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Passwords are different!",
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
      else if(!nmCompliant){
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Invalid name!",
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
      else if(!emCompliant){
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Invalid email format!",
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
      else if(!agCopliant){
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              content: Text("Invalid age!",
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
      else if(Authentication.registerUser(username, password, email, name, age, tipo)){
        //PASSAR DEPOIS PARA UMA PAGINA ORIGINAL
        Navigator.push( //responsavel por passar para a outra pagina (mainScreen), pilha que empilha as paginas acessadas, podendo assim voltar a tras nas paginas
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      }
      else{
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              backgroundColor: Color.fromRGBO(248, 237, 227, 1),
              contentPadding: EdgeInsets.all(20),
              //VERIFICAR QUE MENSAGEM COLOCAR AQUI
              content: Text("Regist gone wrong!",
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
            backgroundColor: const Color.fromRGBO(162, 178, 159, 1),
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
                        height: 1000.0,
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
                         child: Column(
                           children: [
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                               child: const Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[
                                   Text(
                                     'Sign In',
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
                             //USERNAME
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                               child: TextField(
                                 controller: usernameController,
                                 decoration: const InputDecoration(
                                   border: UnderlineInputBorder(),
                                   labelText: 'Username',
                                 ),
                               ),
                             ),
                             //NAME
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                               child: TextField(
                                 controller: nameController,
                                 decoration: const InputDecoration(
                                   border: UnderlineInputBorder(),
                                   labelText: 'Name',
                                 ),
                               ),
                             ),
                             //EMAIL
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                               child: TextField(
                                 controller: emailController,
                                 decoration: const InputDecoration(
                                   border: UnderlineInputBorder(),
                                   labelText: 'Email',
                                 ),
                               ),
                             ),
                             //PASSWORD
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
                             //PASSWORD CONFIRMATION
                             Container(
                               padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                               child: TextField(
                                 obscureText: true,
                                 controller: confPasswordController,
                                 decoration: const InputDecoration(
                                   border: UnderlineInputBorder(),
                                   labelText: 'Confirmation password',
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
                               padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                               child: TextField(
                                 controller: ageController,
                                 decoration: const InputDecoration(
                                   border: UnderlineInputBorder(),
                                   labelText: 'Age',
                                 ),
                               ),
                             ),
                             Container(
                               child: selectConta(),

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
                                   child: const Text('Sign In',
                                     style: TextStyle(
                                       color: Color.fromRGBO(248, 237, 227, 1),
                                       fontSize: 20,
                                       fontFamily: 'Arial',
                                     )
                                     ,),
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
                               child: const Text('Already have an account? Log in'),
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
        const Padding(padding: EdgeInsets.fromLTRB(30, 30, 20, 5),
          child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
                "Tipo de conta:",
              style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              ),
          ),
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
        child: RadioListTile<TipoConta>(
          title: const Text('Personal'),
          value: TipoConta.personal,
          groupValue: tipoContaSelecionado,
          activeColor: const Color.fromRGBO(121, 135, 119, 1),
          onChanged: (TipoConta? value) {
            setState(() {
              tipoContaSelecionado = value;
            });
          },
        ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
        child: RadioListTile<TipoConta>(
          title: const Text('Business'),
          value: TipoConta.business,
          groupValue: tipoContaSelecionado,
          activeColor: const Color.fromRGBO(121, 135, 119, 1),
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






