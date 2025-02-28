import 'package:adc_handson_session/AppPage/presentation/webPage_screen.dart';
import 'package:adc_handson_session/tipsPage/presentation/web_features_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../AppPage/presentation/WebGroups_screen.dart';

class WebAboutPage extends StatefulWidget {
  const WebAboutPage({super.key});

  @override
  State<WebAboutPage> createState() => _WebAboutPage();
}

class _WebAboutPage extends State<WebAboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
        title: Center(
          child: Image.asset(
            'assets/logo.png', // Replace with your image path
            height: 70,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: const Color.fromRGBO(82, 130, 103, 1.0),
          onPressed: () {
            Navigator.pushReplacement( //responsavel por passar para a outra pagina (mainScreen), pilha que empilha as paginas acessadas, podendo assim voltar a tras nas paginas
                context,
                MaterialPageRoute(builder: (context) => const WebPage()));
          },
        ),
        actions: const [
          SizedBox(width: 30.0),
        ],
      ),
      backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(100, 20, 100, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to Green Life!",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: const Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "We are here to help you improve your carbon footprint.",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: const Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Reducing our carbon footprint is crucial for preserving our planet's health and ensuring a "
                    "sustainable future for generations to come. \n\n"
                    "By making informed choices and tracking your impact across various aspects of your life, from food and transportation to water and electricity, you can actively contribute to environmental conservation. \n\n"
                    "What's better than improving individually? Improving in group allowing more people to amplify their impact collectively. \n"
                    "Green Life provides a platform where individuals and businesses can join groups, collaborate, and collectively work towards reducing their carbon footprint. \n\nTogether, we can make significant strides towards a greener and more sustainable world.",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                height: 1.0, // Adjust height as needed
                width: 350.0, // Adjust width as needed
                color:  const Color.fromRGBO(82, 130, 103, 1.0),
              ),
              Container(
                  height: 90,
                  padding: const EdgeInsets.fromLTRB(10,10,10,25),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color.fromRGBO(82, 130, 103, 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                        ),
                      ),
                      child: Text('See our features!',
                        style: GoogleFonts.getFont('Inter',
                          textStyle: const TextStyle(
                            color: Color.fromRGBO(248, 237, 227, 1),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WebFeaturesPage()),
                        );
                      }
                  )),
            ],
          ),
        ),
      ),
    );
  }
}