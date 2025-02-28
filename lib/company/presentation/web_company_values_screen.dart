import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../login/domain/Group.dart';
import '../application/auth.dart';

class WebCompanyValuesPage extends StatefulWidget {
  const WebCompanyValuesPage({Key? key}) : super(key: key);

  @override
  State<WebCompanyValuesPage> createState() => _WebCompanyValuesPage();
}

class _WebCompanyValuesPage extends State<WebCompanyValuesPage> {

  bool isLoading = true;

  Company? company;

  @override
  void initState() {
    getCompanyValues();
    super.initState();
  }

  Future<void> getCompanyValues() async {
    Company? c = await AuthenticationCompany().getCompany();

    setState(() {
      if (mounted) {
        company = c!;
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    ) :
    MaterialApp(
      title: 'Green Life',
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color:  const Color.fromRGBO(82, 130, 103, 1.0),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: const [
            SizedBox(width: 40.0),
          ],
        ),
        backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
//PRIMEIRO PAINEL -----------------------------------------------------------------------------------
                            Container(
                              width: 350,
                              height: 300,
                              decoration: BoxDecoration(
                                color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              //PAINEL
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Positioned(
                                    top: 20,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Average Footprint',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 30,
                                    top: 60,
                                    child: IconButton(
                                      icon: const Icon(Icons.info_outline, color: const Color.fromRGBO(248, 237, 227, 1),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                                              contentPadding: const EdgeInsets.all(20),
                                              content:  Text(
                                                "The Average Footprint is calculated from "
                                                    "the values the users of this company enter, \n"
                                                    "to give you an idea of how good "
                                                    "their footprint is.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.getFont(
                                                  'Inter',
                                                  textStyle:  const TextStyle(
                                                    color:  Color.fromRGBO(82, 130, 103, 1.0),
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
                                                      textStyle:  const TextStyle(
                                                        color:  Color.fromRGBO(82, 130, 103, 1.0),
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
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: const Color.fromRGBO(248, 237, 227, 1),
                                    ),
                                  ),
                                  Positioned(
                                    top: 80,
                                    child: Container(
                                      width: 250, // Adjust width as needed
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(248, 237, 227, 1),
                                        borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                            double.parse(company!.averageCO2String).truncate().toStringAsFixed(2),
                                            style: GoogleFonts.getFont(
                                              'Fjalla One',
                                              textStyle: const TextStyle(
                                                color:  Color.fromRGBO(82, 130, 103, 1.0),
                                                fontSize: 50,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 160,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Mobility: ',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${double.parse(company!.fuelCO2String).round().toStringAsFixed(2)}kg Co2",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 190,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Food: ',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${company!.foodCO2String}kg Co2",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
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
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${company!.electricityCO2String}kg Co2",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 250,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Water: ',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${company!.tapWaterCO2String}kg Co2",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            const SizedBox(width: 20.0),
//SEGUNDO PAINEL -----------------------------------------------------------
                            Container(
                              width: 350,
                              height: 300,
                              decoration: BoxDecoration(
                                color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              //PAINEL
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Positioned(
                                    top: 20,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Individual Values',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 70,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Electricity',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 24,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 100,
                                    child: Row(
                                      children: [
                                        Text(
                                          /*double.parse(widget.group!.foodValues!).round().toString(),*/
                                          "${company!.electricityConsumptionString}kWh/month",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 140,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Water',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 24,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 170,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Tap: ',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${company!.tapWaterConsumptionString}l/month",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 200,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Bottled : ',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${company!.bottleWaterConsumptionString}l/week",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ),
        ]),
      ),
    );
  }


}