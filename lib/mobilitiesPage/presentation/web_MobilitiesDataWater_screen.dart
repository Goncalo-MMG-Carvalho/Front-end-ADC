import 'dart:math';
import 'dart:convert';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/mobilitiesPage/presentation/web_MobilitiesDataElectricity_screen.dart';
import 'package:adc_handson_session/mobilitiesPage/presentation/web_MobilitiesDataFood_screen.dart';
import 'package:adc_handson_session/mobilitiesPage/presentation/web_MobilitiesDataMobility_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:localstorage/localstorage.dart';
import 'package:adc_handson_session/mobilitiesPage/application/auth.dart';

import '../../AppPage/presentation/appPage_screen.dart';
import '../../AppPage/presentation/webPage_screen.dart';
import '../../exceptions/invalid_token.dart';
import 'MobilitiesDataElectricity_screen.dart';
import '../../login/domain/User.dart';
import '../../Utils/constants.dart' as constants;
import 'MobilitiesDataFood_screen.dart';
import 'MobilitiesDataMobility_screen.dart';

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

class WebMobilitiesWaterDataPage extends StatefulWidget {
  const WebMobilitiesWaterDataPage({super.key});
  @override
  State<WebMobilitiesWaterDataPage> createState() =>
      _WebMobilitiesWaterDataPage();
}

class _WebMobilitiesWaterDataPage extends State<WebMobilitiesWaterDataPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController litersVal;

  String _selectedType = 'Tap';

  final Authentication auth = Authentication();

  bool isLoading = true;

  List<double> waterIndexHistory = [];

  bool isVisible = false;


  String waterIndexText = 'Lets go!';

  bool isFirstTime = true; // Define a flag variable to track the first time

  void _getWaterIndexText() {
    if (isFirstTime) {
      switch (80) {}
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
    User u = await userUtils().getUser();
    var history = u.waterHistory.split("|");
    List<double> newVal = [];
    for (String s in history) {
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
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Water Consumption',
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color: Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 10.0),
//PRIMEIRO PAINEL -----------------------------------------------------------------------------------
                                    Column(
                                      children: [
                                        Container(
                                          width: 900,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(82, 130, 103, 1.0),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          //PAINEL
                                          child: Stack(
                                            alignment: Alignment.centerLeft,
                                            children: [
                                              Positioned(
                                                left: 30,
                                                child: CircleAvatar(
                                                  radius: 70,
                                                  backgroundColor:
                                                      const Color.fromRGBO(
                                                          248, 237, 227, 1),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                      child: Center(
                                                        child: Text(
                                                          double.parse(user!
                                                                  .waterPoints)
                                                              .round()
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .getFont(
                                                            'Fjalla One',
                                                            textStyle:
                                                                const TextStyle(
                                                                  color: Color.fromRGBO(82, 130, 103, 1.0),// This color will be masked by the gradient
                                                                  fontSize: 90,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 140,
                                                top: 20,
                                                child: IconButton(
                                                  icon: const Icon(Icons.info_outline, color: const Color.fromRGBO(
                                                      248, 237, 227, 1)),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                                                          contentPadding: const EdgeInsets.all(20),
                                                          content:  Text(
                                                            "The values are changed weekly or monthly, \ndepending on the type of value entered.\n\n"
                                                            "Your Index is calculated from "
                                                          "the values you enter,\n"
                                                          "to give you an idea of how good "
                                                          "your footprint is.",
                                                            textAlign: TextAlign.center,
                                                            style: GoogleFonts.getFont(
                                                              'Inter',
                                                              textStyle: const TextStyle(
                                                                color: Color.fromRGBO(82, 130, 103, 1.0),
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
                                                                    color: Color.fromRGBO(82, 130, 103, 1.0),
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
                                                  color: const Color.fromRGBO(82, 130, 103, 1.0),
                                                ),
                                              ),
                                              Positioned(
                                                top: 30,
                                                left: 190,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "This Month's/Week Values:",
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(248, 237, 227, 1),
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 80,
                                                left: 190,
                                                child: Row(children: [
                                                  Text(
                                                    'Tap: ',
                                                    style: GoogleFonts.getFont(
                                                      'Inter',
                                                      textStyle:
                                                          const TextStyle(
                                                            color: Color.fromRGBO(248, 237, 227, 1),
                                                            fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    user!.tapConsumption,
                                                    style: GoogleFonts.getFont(
                                                      'Inter',
                                                      textStyle:
                                                          const TextStyle(
                                                            color: Color.fromRGBO(248, 237, 227, 1),
                                                            fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                       ),
                                                    ),
                                                  ),
                                                  Text(
                                                    'l',
                                                    style: GoogleFonts.getFont(
                                                      'Inter',
                                                      textStyle:
                                                          const TextStyle(
                                                            color: Color.fromRGBO(248, 237, 227, 1),
                                                            fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    '${user!.tapCo2}kg',
                                                    style: GoogleFonts.getFont(
                                                      'Inter',
                                                      textStyle:
                                                          const TextStyle(
                                                            color: Color.fromRGBO(248, 237, 227, 1),
                                                            fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                       ),
                                                    ),
                                                  ),
                                                  Text(
                                                    ' CO2',
                                                    style: GoogleFonts.getFont(
                                                      'Inter',
                                                      textStyle:
                                                          const TextStyle(
                                                            color: Color.fromRGBO(248, 237, 227, 1),
                                                            fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                       ),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              Positioned(
                                                top: 125,
                                                left: 190,
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 5.0),
                                                    Text(
                                                      'Plastic bottles: ',
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(248, 237, 227, 1),
                                                              fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      user!.bottleConsumption,
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(248, 237, 227, 1),
                                                              fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'l',
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(248, 237, 227, 1),
                                                              fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5.0),
                                                    Text(
                                                      '${user!.bottleCo2}kg',
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(248, 237, 227, 1),
                                                              fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          ),
                                                      ),
                                                    ),
                                                    Text(
                                                      ' CO2',
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(248, 237, 227, 1),
                                                              fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 30,
                                                right: 90,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Value information: ',
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(248, 237, 227, 1),
                                                              fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 60,
                                                right: 30,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      "Please enter your tap values monthly,\n"
                                                          "and plastic values whenever you want.\n"
                                                          "The Index will change monthly accordingly \nto "
                                                          "tap water, and weekly to plastic bottles.",
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(248, 237, 227, 1),
                                                              fontSize: 16,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 10,
                                                left: 0,
                                                right: 0,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      waterIndexText,
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(248, 237, 227, 1),
                                                              fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
//SEGUNDO PAINEL - GRÁFICO -------------------------------------------------------------------------------
                                        const SizedBox(height: 10.0),
                                        Row(children: [
                                          Container(
                                            width: 445,
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
                                                        style:
                                                            GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle:
                                                              const TextStyle(
                                                                color: Color.fromRGBO(248, 237, 227, 1),
                                                                fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                        getDrawingHorizontalLine:
                                                            (value) {
                                                          return const FlLine(
                                                            color: Color.fromRGBO(248, 237, 227, 1),
                                                            strokeWidth: 1,
                                                          );
                                                        },
                                                      ),
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        leftTitles: AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                            showTitles: true,
                                                            reservedSize: 40,
                                                            getTitlesWidget:
                                                                (value, meta) {
                                                              return Text(
                                                                '${value.toInt()}',
                                                                style:
                                                                    const TextStyle(
                                                                      color: Color.fromRGBO(248, 237, 227, 1),
                                                                      fontSize: 12,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        bottomTitles: const AxisTitles(
                                                            sideTitles:
                                                                SideTitles(
                                                                    showTitles:
                                                                        false)),
                                                        rightTitles: const AxisTitles(
                                                            sideTitles:
                                                                SideTitles(
                                                                    showTitles:
                                                                        false)),
                                                        topTitles: const AxisTitles(
                                                            sideTitles:
                                                                SideTitles(
                                                                    showTitles:
                                                                        false)),
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
                                                          right:
                                                              BorderSide.none,
                                                          top: BorderSide.none,
                                                        ),
                                                      ),
                                                      lineBarsData: [
                                                        LineChartBarData(
                                                          spots: List.generate(
                                                              waterIndexHistory
                                                                  .length,
                                                              (index) {
                                                            return FlSpot(
                                                                index
                                                                    .toDouble(),
                                                                waterIndexHistory[
                                                                        index]
                                                                    .toDouble());
                                                          }),
                                                          isCurved: true,
                                                          color: Color.fromRGBO(248, 237, 227, 1),
                                                          dotData:
                                                              const FlDotData(
                                                                  show: true),
                                                          belowBarData:
                                                              BarAreaData(
                                                                  show: false),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const Positioned(
                                                  bottom: 15,
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
                                          const SizedBox(width: 10.0),
                                          Container(
                                            width: 445,
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
                                                        'Insert values: ',
                                                        style:
                                                            GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle:
                                                              const TextStyle(
                                                                color: const Color.fromRGBO(248, 237, 227, 1),
                                                                fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 60,
                                                  left: 16,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Type: ',
                                                          style: GoogleFonts
                                                              .getFont(
                                                            'Inter',
                                                            textStyle:
                                                                const TextStyle(
                                                                  color: const Color.fromRGBO(248, 237, 227, 1),
                                                                  fontSize: 18,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        DropdownButton<String>(
                                                          value: _selectedType,
                                                          iconEnabledColor: const Color.fromRGBO(248, 237, 227, 1),
                                                          dropdownColor: const Color.fromRGBO(82, 130, 103, 1.0),
                                                          items: <String>[
                                                            'Tap',
                                                            'Plastic bottles'
                                                          ].map<
                                                              DropdownMenuItem<
                                                                  String>>((String
                                                              value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: Text(
                                                                value,
                                                                style:
                                                                    GoogleFonts
                                                                        .getFont(
                                                                  'Inter',
                                                                  textStyle:
                                                                       TextStyle(
                                                                         color: const Color.fromRGBO(248, 237, 227, 1),
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                          onChanged: (String?
                                                              newValue) {
                                                            setState(() {
                                                              _selectedType =
                                                                  newValue!;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 80,
                                                  left: 10,
                                                  right: 10,
                                                  child: Container(
                                                    height: 90,
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        10, 40, 10, 5),
                                                    child: TextField(
                                                      cursorColor: const Color.fromRGBO(189, 210, 182, 1),
                                                      style: GoogleFonts.getFont('Inter',
                                                        textStyle: const TextStyle(
                                                          fontSize: 20.0,
                                                          color:  Color.fromRGBO(82, 130, 103, 1.0),
                                                        ),),
                                                      controller: litersVal,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Enter liters',
                                                        hintStyle:
                                                            GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                                          ),
                                                        ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: const BorderSide(
                                                                  color:  const Color.fromRGBO(189, 210, 182, 1),
                                                                  width: 2.0),
                                                              borderRadius: BorderRadius.circular(5.0),
                                                            ),
                                                            filled: true,
                                                            fillColor: const Color.fromRGBO(248, 237, 227, 1),
                                                            prefixIcon: const Icon(
                                                              Icons.water_drop,
                                                              color:  const Color.fromRGBO(82, 130, 103, 1.0),
                                                            ),
                                                      ),
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal:
                                                                  true), // Allow numbers and decimal point
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'^\d+\.?\d{0,2}')), // Allow digits and optional decimal point
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 20,
                                                  left: 10,
                                                  right: 10,
                                                  child: Container(
                                                    height: 90,
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        10, 40, 10, 5),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        minimumSize: const Size
                                                            .fromHeight(50),
                                                        backgroundColor:
                                                            const Color
                                                                .fromRGBO(123,
                                                                175, 146, 1.0),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0), // Adjust the radius as needed
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Submit',
                                                        style:
                                                            GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle:
                                                              const TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                                    248,
                                                                    237,
                                                                    227,
                                                                    1),
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        updateWaterStatistics(
                                                            _selectedType,
                                                            litersVal.text);
                                                        _getWaterIndexText();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                        //INFORMAÇÃOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
                                        const SizedBox(height: 10.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              isVisible = !isVisible;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(82, 130, 103, 1.0),
                                            //padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10.0), // Adjust the radius as needed
                                            ),
                                          ),
                                          child: Text(isVisible ? 'Hide Information' : 'Show Information',
                                            style: GoogleFonts.getFont('Inter',
                                              textStyle: const TextStyle(
                                                color: Color.fromRGBO(248, 237, 227, 1),
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: isVisible,
                                          child: Row(children: [
                                            Container(
                                              width: 900,
                                              height: 860,
                                              color: Color.fromRGBO(189, 210, 182, 1),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Positioned(
                                                    top: 20,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'What is the carbon footprint of a bottle of water?',
                                                          style:
                                                          GoogleFonts.getFont(
                                                            'Inter',
                                                            textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(82, 130, 103, 1.0),
                                                              fontSize: 26,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 60,
                                                    left: 40,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "According to some studies, a 500 ml bottle of water has a carbon footprint "
                                                              "of around 82.8g of \ncarbon dioxide [1]. \n\n"
                                                              "Several studies indicate that the carbon footprint of tap water is lower than that of "
                                                              "bottled water, \nand can be up to 300 times lower [2][3].",
                                                          style:
                                                          GoogleFonts.getFont(
                                                            'Inter',
                                                            textStyle:
                                                             TextStyle(
                                                              color: Colors.grey.shade800,
                                                              fontSize: 18,
                                                              fontWeight:
                                                              FontWeight.normal,
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
                                                          'How can you contribute to reducing the carbon footprint?',
                                                          style:
                                                          GoogleFonts.getFont(
                                                            'Inter',
                                                            textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(82, 130, 103, 1.0),
                                                              fontSize: 26,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 240,
                                                    left: 40,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "Although the consumption of bottled water leaves a significant carbon footprint,"
                                                              "it is entirely \navoidable and, with some planning and willpower, you can "
                                                              "eliminate its  contribution altogether. \n \nHowever, if for some reason you have to consume "
                                                              "bottled water, here are some questions \nyou should be aware of:",
                                                          style:
                                                          GoogleFonts.getFont(
                                                            'Inter',
                                                            textStyle:
                                                             TextStyle(
                                                               color: Colors.grey.shade800,
                                                              fontSize: 18,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 380,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Some tips:',
                                                          style:
                                                          GoogleFonts.getFont(
                                                            'Inter',
                                                            textStyle:
                                                             TextStyle(
                                                               color: Color.fromRGBO(82, 130, 103, 1.0),
                                                              fontSize: 26,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 420,
                                                    left: 40,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "1. Don't buy imported water.\n\n"
                                                              "2. Opt for glass containers. \n\n"
                                                              "3. Drink tap water.",
                                                          style:
                                                          GoogleFonts.getFont(
                                                            'Inter',
                                                            textStyle:
                                                             TextStyle(
                                                              color: Colors.grey.shade800,
                                                              fontSize: 18,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 580,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Sources:',
                                                          style:
                                                          GoogleFonts.getFont(
                                                            'Inter',
                                                            textStyle:
                                                            const TextStyle(
                                                              color: Color.fromRGBO(82, 130, 103, 1.0),
                                                              fontSize: 26,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 620,
                                                    left: 40,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "[1] Blue, M.-L. (2 Mar. 2019). “What Is the Carbon Footprint of a Plastic Bottle?” \n Sciencing, sciencing.com/carbon-footprint-plastic-bottle-12307187.html.\n\n"
                                                              "[2] Botto, S. Tap Water vs. Bottled Water in a Footprint Integrated Approach. Nat Prec (2009)\n\n"
                                                              "[3] Fantin, V., Masoni, P., and Scalbi, S. 2011. Tap Water or Bottled Water? \nA Review of LCA Studies Supporting a Campaign for Sustainable Consumption. \n\n",
                                                          style:
                                                          GoogleFonts.getFont(
                                                            'Inter',
                                                            textStyle:
                                                             TextStyle(
                                                              color: Colors.grey.shade800,
                                                              fontSize: 18,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),

                                          ]),
                                        ),
                                      ],
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
            color: const Color.fromRGBO(82, 130, 103, 1.0),),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(
                  8.0), // Optional: add some padding for better appearance
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
                  builder: (context) => const WebMobilitiesMobilityDataPage()),
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
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WebMobilitiesFoodDataPage()),
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
                  builder: (context) => const WebMobilitiesElectricityDataPage()),
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
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WebMobilitiesWaterDataPage()),
            );
          },
        ),
      ],
    );
  }


  updateWaterStatistics(String selectedType, String waterVal) async {
    if (double.parse(waterVal) > 0.0) {
      try {
        User? u = await auth.updateWaterValues(waterVal, selectedType);

        if (u != null) {
          setState(() {
            user = u;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                content: Text('Values submitted successfully!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(82, 130, 103, 1.0),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont(
                        'Inter',
                        textStyle: const TextStyle(
                          color: Color.fromRGBO(82, 130, 103, 1.0),
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
      } on TokenInvalidoException catch (e) {
        print('Erro ao carregar grupos: $e');
        userUtils().invalidSessionDialog(context);
      }
    }
  }
}
