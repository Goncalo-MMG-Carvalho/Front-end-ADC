import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../login/domain/User.dart';
import '../../mobilitiesPage/presentation/MobilitiesDataElectricity_screen.dart';
import '../../mobilitiesPage/presentation/MobilitiesDataFood_screen.dart';
import '../../mobilitiesPage/presentation/MobilitiesDataMobility_screen.dart';
import '../../mobilitiesPage/presentation/MobilitiesDataWater_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  userUtils uUtils = userUtils();


  User? user;

  String? AveragePoints;

  bool _isLoading = true;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  Future<void> getUser() async {
    User profile = await uUtils.getUser();
   // String average = userUtils().calculateAverage(profile);
   // print(average);
    setState(() {
        AveragePoints = profile.averagePoints;
        user = profile;
        _isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    int avgPoints = AveragePoints != null ? double.parse(AveragePoints!).toInt() : 0;


    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        :  SingleChildScrollView(
      child:Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 30,
            ),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(121, 135, 119, 1).withOpacity(0.5), // Color of the shadow
                    spreadRadius: 5, // Spread radius
                    blurRadius: 7, // Blur radius
                    offset: const Offset(0, 3), // Changes position of shadow
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(82, 130, 103, 1.0),
                    Color.fromRGBO(123, 175, 146, 1.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                /*border: Border.all(
                color: Color.fromRGBO(189, 210, 182, 1),
                width: 2, // Adjust the width of the border as needed
              ),*/
              ),
              //PAINEL
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 20,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Color.fromRGBO(248, 237, 227, 1),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                          child: Text(
                            //TODO INFORMAÇÂO DE VALOR GERAL DO USER
                            double.parse(user!.averagePoints).round().toString(),
                            style: GoogleFonts.getFont('Fjalla One',
                              textStyle: const TextStyle(
                                color: const Color.fromRGBO(82, 130, 103, 1.0),
                                fontSize: 70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                      ),
                    ),
                  ),
                  Positioned(
                    right: 70,
                    top: 10,
                    child: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                              contentPadding: const EdgeInsets.all(20),
                              content:  Text(
                                    "The Average Footprint is calculated from "
                                    "the values you insert in the mobilities, "
                                    "to give you an idea of how good"
                                    "your footprint is.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
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
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: const Color.fromRGBO(248, 237, 227, 1),
                    ),
                  ),

                  Positioned(
                    top: 140,
                    child: Row(
                      children: [
                        Text(
                          'Mobility: ',
                          style: GoogleFonts.getFont('Inter',
                            textStyle: const TextStyle(
                              color: Color.fromRGBO(248, 237, 227, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                        ),
                        Text(
                          double.parse(user!.fuelPoints).round().toString(),
                          style: GoogleFonts.getFont('Inter',
                            textStyle: TextStyle(
                              color: Color.fromRGBO(248, 237, 227, 1), // This color will be masked by the gradient
                              fontSize: 20,
                             ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 180,
                    child: Row(
                      children: [
                        //SizedBox(width: 1), // Adjust spacing between fields
                        Text(
                          'Food: ',
                          style: GoogleFonts.getFont('Inter',
                            textStyle: const TextStyle(
                              color: Color.fromRGBO(248, 237, 227, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          double.parse(user!.foodPoints).round().toString(),
                          style: GoogleFonts.getFont('Inter',
                            textStyle: TextStyle(
                              color: Color.fromRGBO(248, 237, 227, 1), // This color will be masked by the gradient
                              fontSize: 20,
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 220,
                    child: Row(
                      children: [
                        Text(
                          'Electricity: ',
                          style: GoogleFonts.getFont('Inter',
                            textStyle: const TextStyle(
                              color: Color.fromRGBO(248, 237, 227, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          double.parse(user!.energyPoints).round().toString(),
                          style: GoogleFonts.getFont('Inter',
                            textStyle: TextStyle(
                              color: Color.fromRGBO(248, 237, 227, 1), // This color will be masked by the gradient
                              fontSize: 20,
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 260,
                    child: Row(
                      children: [// Adjust spacing between fields
                        Text(
                          'Water: ',
                          style: GoogleFonts.getFont('Inter',
                            textStyle: const TextStyle(
                              color: Color.fromRGBO(248, 237, 227, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          double.parse(user!.waterPoints).round().toString(),
                          style: GoogleFonts.getFont('Inter',
                            textStyle: TextStyle(
                              color: Color.fromRGBO(248, 237, 227, 1), // This color will be masked by the gradient
                              fontSize: 20,
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 1.0, // Adjust height as needed
              width: 350.0, // Adjust width as needed
              color:  const Color.fromRGBO(82, 130, 103, 1.0),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'New values',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    fontSize: 24,
                    color: Color.fromRGBO(82, 130, 103, 1.0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),

            Container(
                height: 90,
                padding: const EdgeInsets.fromLTRB(10,10,10,25),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: const Color.fromRGBO(123, 175, 146, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                      ),
                    ),
                    child: Text('Mobility',
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
                        MaterialPageRoute(builder: (context) => const MobilitiesMobilityDataPage()),
                      );
                    }
                )),
            Container(
                height: 90,
                padding: const EdgeInsets.fromLTRB(10,10,10,25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color.fromRGBO(123, 175, 146, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                    ),
                  ),
                  child: Text('Food',
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
                      MaterialPageRoute(builder: (context) => const MobilitiesFoodDataPage()),
                    );
                  },
                )),
            Container(
                height: 90,
                padding: const EdgeInsets.fromLTRB(10,10,10,25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color.fromRGBO(123, 175, 146, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                    ),
                  ),
                  child: Text('Electricity',
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
                      MaterialPageRoute(builder: (context) => const MobilitiesElectricityDataPage()),
                    );
                  },
                )),
            Container(
                height: 90,
                padding: const EdgeInsets.fromLTRB(10,10,10,25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color.fromRGBO(123, 175, 146, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                    ),
                  ),
                  child: Text('Water',
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
                      MaterialPageRoute(builder: (context) =>  const MobilitiesWaterDataPage()),
                    );
                  },
                )),
            Container(
              height: 10,
            )
          ],
        ),
      ),
    );
  }


  //Cores Mobilidades
  Color getColor(double number) {
    if (number > 60) {
      return const Color.fromRGBO(143, 246, 143, 1.0);
    } else if (number > 30 && number <= 60) {
      return const Color.fromRGBO(248, 220, 86, 1.0);
    } else {
      return const Color.fromRGBO(217, 42, 30, 1.0);
    }
  }


  //Cores Número principal
  Color getColorMain(double number) {
    if (number > 60) {
      return const Color.fromRGBO(82, 130, 103, 1.0);
    } else if (number > 30 && number <= 60) {
      return const Color.fromRGBO(250, 173, 6, 1.0);
    } else {
      return const Color.fromRGBO(169, 19, 9, 1.0);
    }
  }

}
