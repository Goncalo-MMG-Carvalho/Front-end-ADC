import 'package:adc_handson_session/MapPage/presentation/mapPage.dart';
import 'package:adc_handson_session/mobilitiesPage/application/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../AppPage/presentation/appPage_screen.dart';
import 'package:adc_handson_session/Utils/userUtils.dart';
import '../../exceptions/invalid_token.dart';
import '../../login/domain/User.dart';
import 'MobilitiesDataElectricity_screen.dart';
import 'MobilitiesDataFood_screen.dart';
import 'MobilitiesDataWater_screen.dart';

class MobilitiesMobilityDataPage extends StatefulWidget {

  const MobilitiesMobilityDataPage({super.key});
  @override
  State<MobilitiesMobilityDataPage> createState() => _MobilitiesMobilityDataPage();
}

class _MobilitiesMobilityDataPage extends State<MobilitiesMobilityDataPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController mobilityVal;

  String _selectedType = 'Gasoline';
  String? _selectedType2;

  final Set<String> _fuel_types = {
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid'
  };

  final Authentication auth = Authentication();

  userUtils uUtils = userUtils();

  bool _isLoading = true;

  User? user;

  // Initialize accumulated values
  double kWh = 0.0;
  double plasticLiters = 0.0;
  double elecCo2 = 0.0;
  double plasticCo2 = 0.0;
  double mobilityIndex = 50;
  double mobilityIndexMax = 100;

  List<double> mobilityIndexHistory = [];

  String mobilityIndexText = 'We can do better!';

  double maxValue = 80;

  void _getmobilityIndexText() {
    switch (mobilityIndex) {
      case >= 0 && < 20:
        mobilityIndexText = "Let's start our journey!";
        break;
      case >= 20 && < 40:
        mobilityIndexText = "We can improve!";
        break;
      case >= 40 && < 60:
        mobilityIndexText = "You're on the right track!";
        break;
      case >= 60 && < 70:
        mobilityIndexText = "Good job! Dedication makes the difference!";
        break;
      case >= 70 && < 80:
        mobilityIndexText = "Excellent! Keep it up and you'll see great results!";
        break;
      case >= 80 && < 90:
        mobilityIndexText = "Wow, let's keep going. You're almost there!";
        break;
      case >= 90 && < 100:
        mobilityIndexText = "Congratulations! You're one of the best users!";
        break;
    }
  }

  void _updatemobilityIndexHistory(double newValue) {
    setState(() {
      mobilityIndexHistory.add(newValue);
      if (mobilityIndexHistory.length > 5) mobilityIndexHistory.removeAt(0);
    });
  }

  Future<void> getUser() async {
    User u = await userUtils().getUser();
    var history = u.fuelHistory.split("|");
    List<double> newVal = [];
    for(String s  in history){
      newVal.add(double.parse(s));
    }
    setState(() {
      _isLoading = false;
      user = u;
      mobilityIndexHistory = newVal;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this); // Define the number of tabs here
    _getmobilityIndexText();
    mobilityVal = TextEditingController();
    getUser();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    mobilityVal.dispose();
    super.dispose();
  }

  updateFuelValue(String fuelVal) async {
    try {
      User? u = await auth.updateFuelValue(fuelVal);
      if(u != null) {
        setState(() {
          user = u;
        });
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            content: Text('Values submitted successfully!',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                'Inter',
                textStyle:  TextStyle(
                  color:  const Color.fromRGBO(82, 130, 103, 1.0),
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
                    textStyle:  TextStyle(
                      color:  const Color.fromRGBO(82, 130, 103, 1.0),
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
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tips = [
      {
        'title': 'Mobility tips',
        'content': '1. Opt for Public Transportation.\n'
            '2. Use Non-Motorized Transport. \n'
            '3.Choose Fuel-Efficient Vehicles.'
      }
    ];

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
                  builder: (context) => const AppPage(initialTabIndex: 0)),
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
        width: MediaQuery.of(context).size.width * 0.6,
        backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
        child: menu(),
      ),
      body:  _isLoading
          ? const CircularProgressIndicator() // Replace with your preferred loading indicator widget
          : Column(
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
                          Text(
                            'Mobility Consumption',
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
                                    backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: Text(
                                              double.parse(user!.fuelPoints).round().toString(),
                                              style: GoogleFonts.getFont(
                                                'Fjalla One',
                                                textStyle: const TextStyle(
                                                  color: Color.fromRGBO(82, 130, 103, 1.0),// This color will be masked by the gradient
                                                  fontSize: 70,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                      ),
                                  ),
                                ),
                                Positioned(
                                  top: 140,
                                  child: Row(
                                    children: [
                                      Text(
                                        "This Week Values:",
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
                                      const SizedBox(width: 5.0),
                                      Text(
                                        '${user!.fuelCo2}kg',
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
                                        ' CO2',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                           ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 210,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Fuel Type: ",
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${user!.fuelType}",
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
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
                                        mobilityIndexText,
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
                                          spots: List.generate(mobilityIndexHistory.length, (index) {
                                            return FlSpot(index.toDouble(), mobilityIndexHistory[index].toDouble());
                                          }),
                                          isCurved: true,
                                          color: Color.fromRGBO(248, 237, 227, 1),
                                          dotData: const FlDotData(show: true),
                                          belowBarData: BarAreaData(show: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 15,
                                  left: 75,
                                  child: Center(
                                    child: Text(
                                      'Last 5 Good Mobility Indexes',
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
                        ],
                      ),
                    ),
                  ),
                ),
//SEGUNDA PÁGINA ------------------------------------------------------------------------------------------------
                SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mobility Consumption',
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
                          Container(
                            width: 350,
                            height: 250,
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
                                        'Change Fuel Type: ',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: const Color.fromRGBO(248, 237, 227, 1),
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
                                        'Current Fuel Type: ',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: const Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        user!.fuelType,
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: const Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 100,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Type: ',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            textStyle: const TextStyle(
                                              color: const Color.fromRGBO(248, 237, 227, 1),
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        DropdownButton<String>(
                                          value: _selectedType,
                                          iconEnabledColor: const Color.fromRGBO(248, 237, 227, 1),
                                          dropdownColor: const Color.fromRGBO(82, 130, 103, 1.0),
                                          items: _fuel_types.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: GoogleFonts.getFont(
                                                  'Inter',
                                                  textStyle: const TextStyle(
                                                    color: const Color.fromRGBO(248, 237, 227, 1),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedType = newValue!;
                                            });
                                          },
                                        ),
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
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 40, 10, 5),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(50),
                                        backgroundColor:
                                        const Color.fromRGBO(123, 175, 146, 1.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust the radius as needed
                                        ),
                                      ),
                                      child: Text(
                                        'Change',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(
                                                248, 237, 227, 1),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        updateFuelValue(_selectedType);
                                      //  _updateTotalkWh();
                                      //  _updateTotalPegada();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            width: 350,
                            height: 350,
                            color: const Color.fromRGBO(189, 210, 182, 1),
                            //PAINEL
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Positioned(
                                  top: 20,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Value information: ',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(
                                                82, 130, 103, 1.0),
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
                                        textAlign: TextAlign.center,
                                        "Please change your fuel type accordingly.\n\n"
                                            "Your Index is calculated from \n"
                                            "the values you enter, to \n"
                                            "give you an idea of how good\n"
                                            "your footprint is.\n\n"
                                            "The Index will change weekly accordingly \nto "
                                            "the routes and type of transport you take.\n"
                                            "If you're using a car, the type of fuel will \n"
                                            "have an affect in your Index. ",
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: const Color.fromRGBO(82, 130, 103, 1.0),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
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

                MapPage(),


//PARTE INFORMAÇÃO ---------------------------------------------------------------------------------------------------------
                SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Carbon footprint associated with Transportation and Mobility.",
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(82, 130, 103, 1.0),
                                fontSize: 26,
                                fontWeight: FontWeight.normal,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            "Transport is responsible for 21% of global CO₂ emissions, of which 40% stem from freight and 60% from passenger transport. Projections suggest that emissions from the transportation sector might soar as much as 60% by 2050 in the absence of mitigation measures.\n",
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1.0),
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            "How can you contribute to reducing the carbon footprint?",
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(82, 130, 103, 1.0),
                                fontSize: 26,
                                fontWeight: FontWeight.normal,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            "Opt for Public Transportation: Buses, Trains, and Subways. These modes of transport emit less CO2 per passenger than cars."
                            "Use Non-Motorized Transport. Walking: Great for short distances, it's the most eco-friendly option."
                            "Biking: Ideal for moderate distances, and bike-sharing programs make it accessible even if you don’t own a bike."
                            "Choose Fuel-Efficient Vehicles - Hybrid and Electric Vehicles (EVs): These have significantly lower emissions compared to conventional cars.",
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1.0),
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: tips.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          width: 1.0,
                                          color: Color.fromRGBO(
                                              82, 130, 103, 1.0)),
                                      bottom: BorderSide(
                                          width: 1.0,
                                          color: Color.fromRGBO(
                                              82, 130, 103, 1.0)),
                                    ),
                                    color: Color.fromRGBO(189, 210, 182, 0.7)),
                                child: ListTile(
                                  leading: const Icon(Icons.water_drop),
                                  title: Text(tips[index]['title']!),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                tips[index]['title']!,
                                                style: GoogleFonts.getFont(
                                                  'Inter',
                                                  textStyle: const TextStyle(
                                                    color: Color.fromRGBO(
                                                        123, 175, 146, 1.0),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                tips[index]['content']!,
                                                style: GoogleFonts.getFont(
                                                  textStyle: const TextStyle(
                                                    color: Color.fromRGBO(
                                                        7, 0, 0, 1.0),
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight.normal,
                                                    height: 1.5,
                                                  ),
                                                  'Inter',
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20.0),
                          Text(
                            'Sources:',
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(123, 175, 146, 1.0),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                          "Center for Climate and Energy Solutions",
                           style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: const TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1.0),
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10.0),
                          // Second tab content here
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
//PARTE NAVEGAÇÃO --------------------------------------------------------------------------------------------------
      bottomNavigationBar: Container(
        color: const Color.fromRGBO(82, 130, 103, 1.0),
        child: TabBar(
          controller: _tabController,
          labelColor: const Color.fromRGBO(248, 237, 227, 1),
          unselectedLabelColor: const Color.fromRGBO(248, 237, 227, 1),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(5.0),
          indicatorColor: const Color.fromRGBO(248, 237, 227, 1),
          tabs: const [
            Tab(
              icon: Icon(Icons.directions_car),
            ),
            Tab(
              icon: Icon(Icons.arrow_upward),
            ),
            Tab(
              icon: Icon(Icons.map),
            ),
            Tab(
              icon: Icon(Icons.info),
            ),
          ],
        ),
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
                  builder: (context) => const MobilitiesMobilityDataPage()),
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
                  builder: (context) => const MobilitiesFoodDataPage()),
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
                  builder: (context) => const MobilitiesElectricityDataPage()),
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
                  builder: (context) => const MobilitiesWaterDataPage()),
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