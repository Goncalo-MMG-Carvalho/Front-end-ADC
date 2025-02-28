import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../AppPage/presentation/appPage_screen.dart';
import 'about_screen.dart';

class FeaturesPage extends StatefulWidget {
  const FeaturesPage({super.key});

  @override
  State<FeaturesPage> createState() => _FeaturesPage();
}

class _FeaturesPage extends State<FeaturesPage> {
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
                MaterialPageRoute(builder: (context) => const AppPage()));
          },
        ),
        actions: const [
          SizedBox(width: 30.0),
        ],
      ),
      backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Our App Features",
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
                "Carbon FootPrint Calculation",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: const Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                "•	Perform detailed calculations to understand how your daily choices impact the environment.\n\n"
                "•	Monitor your monthly usage of tap water and electricity, as well as track your daily activities such as meals, transportation, and bottled water.",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                "Points System",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: const Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                "• Earn points based on your sustainable choices in mobility and overall practices.\n\n"
                    "• Accumulate points to track your progress and contribute positively to the environment.\n\n"
                "• Every month we do a reset on your consumption of tap water and electricity and we calculate, and update your points.\n\n"
               "• Every week we do a reset on your consumption of fuel, food, and bottle water, and update your points.\n\n"
                "• If you are in a group you need to know your consumption and carbon footprint, will directly change the groups consumption and footprint, so, you need to be very responsible and try to improve all days to not let your friends down.",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                "Groups",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: const Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                "• You can create private or public groups.\n\n"
                    "• Accumulate points to track your progress and contribute positively to the environment.\n\n"
                    "• Groups will have the consumption and footprint of all the users, and there will be a top five of all the public groups, decided by the carbon emissions of the groups.\n\n"
                    "• You can send messages and interact with the member in a way to help everyone improving their sustainability.\n\n"
                    "• The owners of the groups can create polls to the groups where the results can be seen by all the users when the polls is finished, that way the users can decide and vote for options that can lead to a improve of the sustainability too.",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                "Business",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: const Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                "• Business accounts, can create business groups, and there monitoring their employee’s sustainability values, and improve all the company values.\n\n"
                    "• They can have many groups and obviously create groups for all the sections or departments of the company.\n\n"
                    "• They can have many groups and obviously create groups for all the sections or departments of the company."
                    "• There companies can improve their sustainability and footprint too.\n\n",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                      child: Text('Learn about us!',
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
                          MaterialPageRoute(builder: (context) => const AboutPage()),
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
