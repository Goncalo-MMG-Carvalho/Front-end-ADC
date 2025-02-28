import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../login/domain/Group.dart';
import '../application/auth.dart';

class TopGroupsPage extends StatefulWidget {
  const TopGroupsPage({Key? key}) : super(key: key);

  @override
  State<TopGroupsPage> createState() => _TopGroupsPage();
}

class _TopGroupsPage extends State<TopGroupsPage> {
  List<EnvironmentalData> topGroups = [];

  @override
  void initState() {
    getTopGroups();
    super.initState();
  }

  Future<void> getTopGroups() async {
    List<EnvironmentalData>? list = await AuthenticationTopGroups().getTopGroups();

    setState(() {
      if (mounted) {
        topGroups = list!;
      }
    });
  }

  Map<String, double> calculateAverageGroupValues() {
    if (topGroups.isEmpty) {
      return {
        'averageFuelCo2': 0.0,
        'averageFoodCo2': 0.0,
        'averageElectricityCo2': 0.0,
        'averageWaterCo2': 0.0,
        'averageElectricity': 0.0,
        'averageTapWater': 0.0,
        'averageBottleWater': 0.0,
      };
    }

    double totalFuelCo2 = 0;
    double totalFoodCo2 = 0;
    double totalElectricityCo2 = 0;
    double totalWaterCo2 = 0;
    double totalElectricity = 0;
    double totalTapWater = 0;
    double totalBottleWater = 0;

    for (var group in topGroups) {
      totalFuelCo2 += double.parse(group.fuelCo2).round();
      totalFoodCo2 += double.parse(group.foodCo2).round();
      totalElectricityCo2 += double.parse(group.electricityCo2).round();
      totalWaterCo2 += double.parse(group.tapCo2).round();

      totalElectricity += double.parse(group.averageElectricity);
      totalTapWater += double.parse(group.averageTapWater);
      totalBottleWater += double.parse(group.averageBottleWater);
    }

    int groupCount = topGroups.length;

    return {
      'averageFuelCo2': totalFuelCo2 / groupCount,
      'averageFoodCo2': totalFoodCo2 / groupCount,
      'averageElectricityCo2': totalElectricityCo2 / groupCount,
      'averageWaterCo2': totalWaterCo2 / groupCount,
      'averageElectricity': totalElectricity / groupCount,
      'averageTapWater': totalTapWater / groupCount,
      'averageBottleWater': totalBottleWater / groupCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> averageValues = calculateAverageGroupValues();
    return MaterialApp(
      title: 'Green Life',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
          title: Center(
            child: Text(
              "Community Page",
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  color:  const Color.fromRGBO(82, 130, 103, 1.0),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 900,
              height: 600,
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(248, 237, 227, 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Group Ranking',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          'Inter',
                          textStyle: const TextStyle(
                            color:  const Color.fromRGBO(82, 130, 103, 1.0),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  if (topGroups.isNotEmpty)
                    ...topGroups.asMap().entries.take(3).map((entry) {
                      int index = entry.key;
                      EnvironmentalData group = entry.value;
                      return buildUserWidget(
                        400 - (index * 25),
                        index + 1,
                        group.groupName,
                        double.parse(group.averageCo2).roundToDouble(),
                      );
                    }).toList()
                  else
                    CircularProgressIndicator(),
                  Spacer(),
                  Container(
                    width: 350,
                    height: 330,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(248, 237, 227, 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                     Positioned(
                      top: 20,
                      child: Row(
                        children: [
                          Text(
                            "Average Group Footprint",
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                        Positioned(
                          top: 60,
                          child: Row(
                            children: [
                              Text(
                                "Mobility: ",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                "${averageValues['averageFuelCo2']!.toStringAsFixed(2)}kg Co2",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 90,
                          child: Row(
                            children: [
                              Text(
                                "Food: ",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                "${averageValues['averageFoodCo2']!.toStringAsFixed(2)}kg Co2",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 120,
                          child: Row(
                            children: [
                              Text(
                                "Electricity: ",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                "${averageValues['averageElectricityCo2']!.toStringAsFixed(2)}kg Co2",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 150,
                          child: Row(
                            children: [
                              Text(
                                "Water: ",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                "${averageValues['averageWaterCo2']!.toStringAsFixed(2)}kg Co2",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
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
                                "Average Group Values",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 230,
                          child: Row(
                            children: [
                              Text(
                                "Electricity: ",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                "${averageValues['averageElectricity'].toString()}kWh/Month",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 260,
                          child: Row(
                            children: [
                              Text(
                                "Tap Water: ",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                "${averageValues['averageTapWater']!.toStringAsFixed(2)}l/Month",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 290,
                          child: Row(
                            children: [
                              Text(
                                "Bottled Water: ",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                "${averageValues['averageBottleWater']!.toStringAsFixed(2)}l/Week",
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: TextStyle(
                                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildUserWidget(double width, int index, String groupName, double averageCo2) {
    return Container(
      width: width,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(248, 237, 227, 0.8),
            Color.fromRGBO(248, 237, 227, 1.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: [
          Container(
            width: 35, // Set the width of the square
            height: 35,
            decoration: BoxDecoration(
              color: index <= 3
                  ? index == 1
                  ? Colors.amber
                  : index == 2
                  ? Color.fromRGBO(214, 214, 214, 1)
                  : Color.fromRGBO(205, 127, 50, 1)
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(6.0),
            ), // Background color of the square
            child: Center(
              child: Text(
                index.toString(),
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              groupName,
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              averageCo2.roundToDouble().toString(), // Display average CO2 with two decimal places
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
