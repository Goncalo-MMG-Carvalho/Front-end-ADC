import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../login/domain/Group.dart';

class GroupStatisticsPage extends StatefulWidget {
  final Group? group;

  const GroupStatisticsPage({required this.group, super.key});

  @override
  State<GroupStatisticsPage> createState() => _GroupStatisticsPage();
}

class _GroupStatisticsPage extends State<GroupStatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Group? group;

  @override
  void initState() {
    _tabController =
        TabController(length: 1, vsync: this); // Define the number of tabs here
    group = widget.group;
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Life',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: getGroupColor(widget.group!.color),
          title: Center(
            child: Text(
              "${group!.groupName}'s statistics",
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  color: Color.fromRGBO(248, 237, 227, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color.fromRGBO(248, 237, 227, 1),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: const [
            SizedBox(width: 40.0),
          ],
        ),
        backgroundColor: getGroupColor(widget.group!.color),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
//PRIMEIRO PAINEL -----------------------------------------------------------------------------------
                            Container(
                              width: 350,
                              height: 300,
                              decoration: BoxDecoration(
                                gradient:  const LinearGradient(
                                  colors: [
                                    Color.fromRGBO(248, 237, 227, 0.6),
                                    Color.fromRGBO(248, 237, 227, 1.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 50,
                                    child: IconButton(
                                      icon: Icon(Icons.info_outline, color: getGroupColor(widget.group!.color)), // This color will be masked by the gradient),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                                              contentPadding: const EdgeInsets.all(20),
                                              content:  Text(
                                                "The Average Footprint is calculated from "
                                                    "the values the users of this group enter,"
                                                    "to give you an idea of how good"
                                                    "their footprint is.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.getFont(
                                                  'Inter',
                                                  textStyle:  TextStyle(
                                                    color: getGroupColor(widget.group!.color), // This color will be masked by the gradient
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
                                                        color: getGroupColor(widget.group!.color), // This color will be masked by the gradient
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
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(248, 237, 227, 1),
                                          border: Border.all(
                                            color: getGroupColor(widget.group!.color),
                                            width: 2, // Border width
                                          ),
                                          borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: Text(
                                              double.parse(widget.group!.averageCo2!).round().toStringAsFixed(2),
                                              style: GoogleFonts.getFont(
                                                'Fjalla One',
                                                textStyle: TextStyle(
                                                  color: getGroupColor(widget.group!.color),
                                                  fontSize: 40,
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${double.parse(widget.group!.fuelCo2!).round().toStringAsFixed(2)}kg Co2",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color),
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${double.parse(widget.group!.foodCo2!).round().toStringAsFixed(2)}kg Co2",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color),
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${double.parse(widget.group!.electricityCo2!).round().toStringAsFixed(2)}kg Co2",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color),
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${double.parse(widget.group!.tapCo2!).round().toStringAsFixed(2)}kg Co2",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color),
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

                            const SizedBox(height: 20.0),
//SEGUNDO PAINEL -----------------------------------------------------------
                            Container(
                              width: 350,
                              height: 300,
                              decoration: BoxDecoration(
                                gradient:  const LinearGradient(
                                  colors: [
                                    Color.fromRGBO(248, 237, 227, 0.6),
                                    Color.fromRGBO(248, 237, 227, 1.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
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
                                          "${widget.group!.averageElectricity!}kWh/month",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color),
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${widget.group!.averageTapWater!}l/month",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color),
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
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color).withOpacity(0.8),
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${widget.group!.averageBottleWater!}l/week",
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: TextStyle(
                                              color: getGroupColor(widget.group!.color),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getGroupColor(String color) {
    int colorValue = int.parse(color, radix: 16);
    return Color(colorValue);
  }

  Color changeGroupColor(String color) {
    int colorValue = int.parse(color, radix: 16);
    Color colorEnviar = Color.fromARGB(
      Color(colorValue).alpha,
      Color(colorValue).red,
      Color(colorValue).green + 20,
      Color(colorValue).blue,
    );
    return colorEnviar;
  }
 
  Color getColor(int number) {
    if (number > 60) {
      return const Color.fromRGBO(143, 246, 143, 1.0);
    } else if (number > 30 && number <= 60) {
      return const Color.fromRGBO(248, 220, 86, 1.0);
    } else {
      return const Color.fromRGBO(217, 42, 30, 1.0);
    }
  }

  //Cores Número principal
  Color getColorMain(int number) {
    if (number > 60) {
      return const Color.fromRGBO(121, 175, 143, 1.0);
    } else if (number > 30 && number <= 60) {
      return const Color.fromRGBO(250, 173, 6, 1.0);
    } else {
      return const Color.fromRGBO(169, 19, 9, 1.0);
    }
  }
}
