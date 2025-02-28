import 'package:adc_handson_session/mobilitiesPage/application/auth.dart';
import 'package:adc_handson_session/mobilitiesPage/presentation/web_MobilitiesDataFood_screen.dart';
import 'package:adc_handson_session/mobilitiesPage/presentation/web_MobilitiesDataMobility_screen.dart';
import 'package:adc_handson_session/mobilitiesPage/presentation/web_MobilitiesDataWater_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../AppPage/presentation/appPage_screen.dart';
import 'package:adc_handson_session/Utils/userUtils.dart';
import '../../AppPage/presentation/webPage_screen.dart';
import '../../exceptions/invalid_token.dart';
import '../../login/domain/User.dart';
import 'MobilitiesDataFood_screen.dart';
import 'MobilitiesDataMobility_screen.dart';
import 'MobilitiesDataWater_screen.dart';

class WebMobilitiesElectricityDataPage extends StatefulWidget {
  const WebMobilitiesElectricityDataPage({super.key});
  @override
  State<WebMobilitiesElectricityDataPage> createState() =>
      _WebMobilitiesElectricityDataPage();
}

class _WebMobilitiesElectricityDataPage
    extends State<WebMobilitiesElectricityDataPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController electricityVal;

  final Authentication auth = Authentication();

  userUtils uUtils = userUtils();

  bool _isLoading = true;

  User? user;

  List<double> elecIndexHistory = [];

  String elecIndexText = 'Lets go!';
  bool isFirstTime = true;
  bool isVisible = false;


  void _getelecIndexText() {
    if (isFirstTime) {
      switch (80) {}
      isFirstTime = false;
    } else {
      switch (double.parse(user!.energyPoints)) {
        case >= 0 && < 20:
          elecIndexText = "Let's start our journey!";
          break;
        case >= 20 && < 40:
          elecIndexText = "We can improve!";
          break;
        case >= 40 && < 60:
          elecIndexText = "You're on the right track!";
          break;
        case >= 60 && < 70:
          elecIndexText = "Good job! Dedication makes the difference!";
          break;
        case >= 70 && < 80:
          elecIndexText = "Keep it up and you'll see great results!";
          break;
        case >= 80 && < 90:
          elecIndexText = "Wow, let's keep going. You're almost there!";
          break;
        case >= 90 && < 100:
          elecIndexText = "Congratulations! You're one of the best users!";
          break;
      }
    }
  }

  Future<void> getUser() async {
    User u = await userUtils().getUser();
    var history = u.energyHistory.split("|");
    List<double> newVal = [];
    for (String s in history) {
      newVal.add(double.parse(s));
    }
    setState(() {
      _isLoading = false;
      user = u;
      elecIndexHistory = newVal;
    });
  }

  @override
  void initState() {
    _getelecIndexText();
    electricityVal = TextEditingController();
    getUser();
    super.initState();
  }

  @override
  void dispose() {
    electricityVal.dispose();
    super.dispose();
  }

  updateElectricityValues(String electricityVal) async {
    if (double.parse(electricityVal) > 0.0) {
      try {
        User? u = await auth.updateElectricityValues(electricityVal);

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
              MaterialPageRoute(builder: (context) => const WebPage()),
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
      body: _isLoading
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
                                'Electricity Consumption',
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color: Color.fromRGBO(82, 130, 103, 1.0),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
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
                                  Column(
                                    children: [
//PRIMEIRO PAINEL ----------------------------------------------------------------------------------
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
                                                      const EdgeInsets.all(4.0),
                                                      child: Center(
                                                        child: Text(
                                                          double.parse(user!
                                                                  .energyPoints)
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
                                                          textAlign:
                                                              TextAlign.center,
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
                                                          "The values are changed monthly.\n\n"
                                                              "Your Index is calculated from "
                                                              "the values you enter,\n"
                                                              "to give you an idea of how good "
                                                              "your footprint is.",textAlign: TextAlign.center,
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
                                                    "This Month's Values:",
                                                    style: GoogleFonts.getFont(
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
                                              child: Row(
                                                children: [
                                                  Text(
                                                    ' ${user!.energyConsumption} kWh',
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
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              top: 125,
                                              left: 190,
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                    '${user!.energyCo2}kg',
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
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              top: 30,
                                              right: 80,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Value information: ',
                                                    style: GoogleFonts.getFont(
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
                                              right: 45,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    textAlign: TextAlign.center,
                                                "Please enter your kWh values monthly.\n\n"
                                                    "The Index will change monthly.",
                                                    style: GoogleFonts.getFont(
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
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center, // Center the Row contents horizontally
                                                children: [
                                                  Text(
                                                    elecIndexText,
                                                    style: GoogleFonts.getFont(
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
                                                        sideTitles: SideTitles(
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
                                                      bottomTitles:
                                                          const AxisTitles(
                                                              sideTitles:
                                                                  SideTitles(
                                                                      showTitles:
                                                                          false)),
                                                      rightTitles:
                                                          const AxisTitles(
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
                                                        right: BorderSide.none,
                                                        top: BorderSide.none,
                                                      ),
                                                    ),
                                                    lineBarsData: [
                                                      LineChartBarData(
                                                        spots: List.generate(elecIndexHistory.length,
                                                            (index) {
                                                          return FlSpot(index.toDouble(), elecIndexHistory[index].toDouble());
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
                                                    'Last 5 Good Electricity Indexes',
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
                                                top: 20,
                                                left: 10,
                                                right: 10,
                                                child: Container(
                                                  height: 90,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 40, 10, 5),
                                                  child: TextField(
                                                    cursorColor: const Color.fromRGBO(189, 210, 182, 1),
                                                    style: GoogleFonts.getFont('Inter',
                                                      textStyle: const TextStyle(
                                                        fontSize: 20.0,
                                                        color:  Color.fromRGBO(82, 130, 103, 1.0),
                                                      ),),
                                                    controller: electricityVal,
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter kWh',
                                                      hintStyle: GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle:  TextStyle(
                                                          fontSize: 18.0,
                                                          fontWeight: FontWeight.normal,
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
                                                        Icons.electric_bolt,
                                                        color: Color.fromRGBO(
                                                            82, 130, 103, 1.0),
                                                      ),
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly // Allow only digits (numbers)
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
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 40, 10, 5),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      minimumSize:
                                                          const Size.fromHeight(
                                                              50),
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                              123,
                                                              175,
                                                              146,
                                                              1.0),
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
                                                          color: Color.fromRGBO(
                                                              248, 237, 227, 1),
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      updateElectricityValues(
                                                          electricityVal.text);
                                                      _getelecIndexText();
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
                                          height: 900,
                                          color: Color.fromRGBO(189, 210, 182, 1),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                top: 20,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Carbon footprint associated with electricity consumption.',
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
                                                      "The sectors that release the most carbon dioxide (CO2) emissions are the energy and transport \nsectors (Stern, 2006).\n\n"
                                                          "According to the European Commission (2012), a city is carbon neutral "
                                                          "when the production of \nheat and electricity is carbon neutral, i.e. "
                                                          "through renewable energy sources.\n\n"
                                                          "The energy industries and the transport sector were the ones that most "
                                                          "contributed to the \nCO2 emissions in Portugal between 2000 and 2014.\n",
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
                                                top: 300,
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
                                                top: 340,
                                                left: 40,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Keep natural light entrances properly unobstructed.\n\n"
                                                          "Regularly clean lamps, reflectors and diffusers "
                                                          "so that they maintain their effectiveness.\n\n"
                                                          "Reduce standby consumption by completely switching off "
                                                          "equipment after use.\n\n"
                                                          "More advanced solutions would be things like replacing "
                                                          "existing technology with more efficient  \ntechnology.",
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
                                                      'Some tips:',
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
                                                          '1. Keep natural light entrances unobstructed.\n\n'
                                                          '2. Turn off lighting whenever unnecessary. \n\n'
                                                          '3. Reduce standby consumption by switching off equipment.',
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
                                                top: 780,
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
                                                top: 820,
                                                left: 40,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Quantificação da pegada de carbono associada ao consumo de energia elétrica no município de \nLoulé. Ruben Filipe Dourado Simão.",
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
