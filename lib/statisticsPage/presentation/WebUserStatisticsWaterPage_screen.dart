import 'dart:math';
import 'dart:convert';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:localstorage/localstorage.dart';
import 'package:adc_handson_session/mobilitiesPage/application/auth.dart';

import '../../AppPage/presentation/appPage_screen.dart';
import '../../AppPage/presentation/webPage_screen.dart';
import '../../exceptions/invalid_token.dart';
import '../../login/domain/User.dart';
import '../../Utils/constants.dart' as constants;
import 'UserStatisticsElecPage_screen.dart';
import 'UserStatisticsFoodPage_screen.dart';
import 'UserStatisticsMobilityPage_screen.dart';
import 'WebUserStatisticsElecPage_screen.dart';
import 'WebUserStatisticsFoodPage_screen.dart';
import 'WebUserStatisticsMobilityPage_screen.dart';

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

class WebUserStatisticsWaterPage extends StatefulWidget {
  final User user;

  WebUserStatisticsWaterPage({super.key, required this.user});
  @override
  State<WebUserStatisticsWaterPage> createState() => _WebUserStatisticsWaterPage();
}

class _WebUserStatisticsWaterPage extends State<WebUserStatisticsWaterPage> with SingleTickerProviderStateMixin {
  late TextEditingController litersVal;

  String _selectedType = 'Tap';

  final Authentication auth = Authentication();

  bool isLoading = true;

  List<double> waterIndexHistory = [];

  String waterIndexText = 'We can do better!';


  bool isFirstTime = true; // Define a flag variable to track the first time

  void _getWaterIndexText() {
    if (isFirstTime) {
      switch (80) {
      }
      isFirstTime = false;
    } else {
      switch (double.parse(user!.waterPoints)) {
        case >= 0 && < 20:
          waterIndexText = "Let's start our journey!";
          break;
        case >= 20 && < 40:
          waterIndexText = "We can improve! Each drop counts!";
          break;
        case >= 40 && < 60:
          waterIndexText = "You're on the right track!";
          break;
        case >= 60 && < 70:
          waterIndexText = "Good job! Dedication makes the difference!";
          break;
        case >= 70 && < 80:
          waterIndexText = "Keep it up and you'll see great results!";
          break;
        case >= 80 && < 90:
          waterIndexText = "Wow, let's keep going. You're almost there!";
          break;
        case >= 90 && < 100:
          waterIndexText = "Congratulations! You're one of the best users!";
          break;
      }
    }
  }

  //tem que ter o null, porque para correr precisa de estar inicializado
  User? user;

  @override
  void initState() {
    getUser();
    litersVal = TextEditingController();
    _getWaterIndexText();
    super.initState();
  }

  @override
  void dispose() {
    litersVal.dispose();
    super.dispose();
  }

  Future<void> getUser() async {
    User u = widget.user;
    var history = u.waterHistory.split("|");
    List<double> newVal = [];
    for(String s  in history){
      newVal.add(double.parse(s));
    }
    setState(() {
      isLoading = false;
      user = u;
      waterIndexHistory = newVal;
    });
  }

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const WebPage()),
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              color: const Color.fromRGBO(82, 130, 103, 1.0),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.2,
        backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
        child: menu(),
      ),
      body: isLoading
          ? const CircularProgressIndicator() // Replace with your preferred loading indicator widget
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Water Consumption - ${widget.user.name}',
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(82, 130, 103, 1.0),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
//PRIMEIRO PAINEL -----------------------------------------------------------------------------------
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 350,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(82, 130, 103, 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            //PAINEL
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Positioned(
                                  top: 20,
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor:
                                        const Color.fromRGBO(248, 237, 227, 1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                          double.parse(user!.waterPoints).round().toString(),
                                          style: GoogleFonts.getFont(
                                              'Fjalla One',
                                              textStyle: const TextStyle(
                                                color: Color.fromRGBO(82, 130, 103, 1.0),// This color will be masked by the gradient
                                                fontSize: 70,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 140,
                                  child: Row(
                                    children: [
                                      Text(
                                        "This Month's/Week Values:",
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
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
                                      Text(
                                        'Tap: ',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        user!.tapConsumption,
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                              color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Color.fromRGBO(
                                                82, 130, 103, 1.0),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'l',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            decorationColor: Color.fromRGBO(
                                                82, 130, 103, 1.0),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5.0),
                                      Text(
                                        '${user!.tapCo2}kg',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Color.fromRGBO(
                                                82, 130, 103, 1.0),
                                          ),
                                        ),
                                      ),

                                      Text(
                                        ' CO2',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            decorationColor: Color.fromRGBO(
                                                82, 130, 103, 1.0),
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
                                        'Plastic bottles: ',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        user!.bottleConsumption,
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Color.fromRGBO(
                                                82, 130, 103, 1.0),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'l',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            decorationColor: Color.fromRGBO(
                                                82, 130, 103, 1.0),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5.0),
                                      Text(
                                        '${user!.bottleCo2}kg',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Color.fromRGBO(
                                                82, 130, 103, 1.0),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        ' CO2',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            decorationColor: Color.fromRGBO(
                                                82, 130, 103, 1.0),
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
                                        waterIndexText,
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10.0),
//SEGUNDO PAINEL - GRÁFICO -------------------------------------------------------------------------------
                          const SizedBox(height: 20.0),
                          Container(
                            width: 350,
                            height: 300,
                            decoration: BoxDecoration(
                              color:  Color.fromRGBO(82, 130, 103, 1.0),
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
                                        'Progress chart: ',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
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
                                  left: 20,
                                  right: 20,
                                  bottom: 40,
                                  child: LineChart(
                                    LineChartData(
                                      minY: 0,
                                      maxY: 100,
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (value) {
                                          return const FlLine(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '${value.toInt()}',
                                                style: const TextStyle(
                                                  color: Color.fromRGBO(248, 237, 227, 1),
                                                  fontSize: 12,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: const Border(
                                          bottom: BorderSide(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            width: 1,
                                          ),
                                          left: BorderSide(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            width: 1,
                                          ),
                                          right: BorderSide.none,
                                          top: BorderSide.none,
                                        ),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: List.generate(waterIndexHistory.length, (index) {
                                            return FlSpot(index.toDouble(), waterIndexHistory[index].toDouble());
                                          }),
                                          isCurved: true,
                                          color: Color.fromRGBO(248, 237, 227, 1),
                                          dotData: const FlDotData(show: true),
                                          belowBarData:
                                              BarAreaData(show: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 15,
                                  left: 90, // A
                                  child: Center(
                                    child: Text(
                                      'Last 5 Good Water Indexes',
                                      style: TextStyle(
                                        color: Color.fromRGBO(248, 237, 227, 1),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
    );
  }

  Widget menu() {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 100, // Set your desired height here
          decoration: BoxDecoration(
            color: const Color.fromRGBO(82, 130, 103, 1.0),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Optional: add some padding for better appearance
              child: Text(
                'Menu',
                textAlign: TextAlign.start,
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
          ),
        ),
        ListTile(
          leading: const Icon(Icons.directions_car),
          title:  Text('Mobility',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle:  TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>  WebUserStatisticsMobilityPage(user: widget.user)),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.restaurant),
          title:  Text('Food',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle:  TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),          onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>  WebUserStatisticsFoodPage(user: widget.user)),
          );
        },
        ),
        ListTile(
          leading: const Icon(Icons.flash_on),
          title:  Text('Electricity',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle:  TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>  WebUserStatisticsElectricityPage(user: widget.user)),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.local_drink),
          title:  Text('Water',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle:  TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),          onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebUserStatisticsWaterPage(user: widget.user)),
          );
        },
        ),
      ],
    );
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

  updateWaterStatistics(String selectedType, String waterVal) async {
    try {
      User? u = await auth.updateWaterValues(waterVal, selectedType);
      setState(() {
        if(u != null){
          user = u;
        }
      });
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }
}
