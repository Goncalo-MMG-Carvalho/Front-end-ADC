import 'dart:math';

import 'package:adc_handson_session/AppPage/presentation/WebAdmins_control_screen.dart';
import 'package:adc_handson_session/mobilitiesPage/presentation/web_MobilitiesDataWater_screen.dart';
import 'package:adc_handson_session/tipsPage/presentation/web_about_screen.dart';
import 'package:adc_handson_session/tipsPage/presentation/web_features_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Utils/userUtils.dart';
import '../../company/presentation/web_company_values_screen.dart';
import '../../login/domain/User.dart';
import '../../mobilitiesPage/presentation/web_MobilitiesDataElectricity_screen.dart';
import '../../mobilitiesPage/presentation/web_MobilitiesDataFood_screen.dart';
import '../../mobilitiesPage/presentation/web_MobilitiesDataMobility_screen.dart';
import '../../profile/presentation/profilePage_screen.dart';
import '../../profile/presentation/web_profilePage_screen.dart';
import '../../topGroups/presentation/web_topGroups_screen.dart';
import 'WebGroups_screen.dart';

class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  bool isLoading = true;
  User? user;
  String? averagePoints;

  bool? isAdmin;
  String? role;


  @override
  void initState() {
    super.initState();
    getUserInfo();
    isAdm();
  }

  Future<void> isAdm() async {
    bool isAdm = await userUtils().isAdmin();
    String? r = await userUtils().getUserRole();
    setState(() {
      role = r!;
      isAdmin = isAdm;
    });
  }

  Future<void> getUserInfo() async {
    await isAdm();
    User profile = await userUtils().getUser();
    String avg = userUtils().calculateAverage(profile);
    String? r = await userUtils().getUserRole();
    setState(() {
      role = r!;
      user = profile;
      averagePoints = avg;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
        title: Center(
          child: Image.asset(
            'assets/logo.png',
            height: 70,
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color:  const Color.fromRGBO(82, 130, 103, 1.0),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color:  const Color.fromRGBO(82, 130, 103, 1.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const WebProfilePage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
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
              leading: const Icon(Icons.group),
              title:  Text('Groups',
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
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WebgroupsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title:  Text('Community',
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
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WebTopGroupsPage()),
                );
              },
            ),
            if(role == 'USER_BUSINESS')
              ListTile(
                leading: const Icon(Icons.business),
                title:  Text('Your company',
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
                    MaterialPageRoute(builder: (context) => const WebCompanyValuesPage()),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title:  Text('About us!',
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
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WebAboutPage()),
                );
                // Implement navigation logic here
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title:  Text('Our features',
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
                // Navigate to Tips screen
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WebFeaturesPage()),
                );
                // Implement navigation logic here
              },
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
                Navigator.pop(context);
                Navigator.pushReplacement(
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
                Navigator.pop(context);
                Navigator.pushReplacement(
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
                Navigator.pop(context);
                Navigator.pushReplacement(
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
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WebMobilitiesWaterDataPage()),
                );
              },
            ),
            if(isAdmin != null && isAdmin!)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title:  Text('Admin Panel',
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
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WebAdminPage()),
                );
              },
            ),
          ],
        ),
      ),
    body: isLoading
    ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
    length: 2,
      child: SingleChildScrollView(
    child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                  'Welcome ${user!.name}!',
                    style: GoogleFonts.getFont(
                      'Inter',
                      textStyle: const TextStyle(
                        color:  const Color.fromRGBO(82, 130, 103, 1.0),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
              SizedBox(height:10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 200,
                      height: 600,
                      child: ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromRGBO(189, 210, 182, 1),
                                      Color.fromRGBO(123, 175, 146, 1.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                  child: Center(
                                  child: Text(
                                    'Menu',
                                    textAlign: TextAlign.center,
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
                              ListTile(
                                leading: const Icon(Icons.group),
                                title:  Text('Groups',
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
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const WebgroupsScreen()),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.star),
                                title:  Text('Community',
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
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const WebTopGroupsPage()),
                                  );
                                },
                              ),
                              if(role == 'USER_BUSINESS')
                                ListTile(
                                  leading: const Icon(Icons.business),
                                  title:  Text('Your company',
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
                                      MaterialPageRoute(builder: (context) => const WebCompanyValuesPage()),
                                    );
                                  },
                                ),
                              ListTile(
                                leading: const Icon(Icons.lightbulb_outline),
                                title:  Text('About us!',
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
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const WebAboutPage()),
                                  );
                                  // Implement navigation logic here
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.list),
                                title:  Text('Our features',
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
                                  // Navigate to Tips screen
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const WebFeaturesPage()),
                                  );
                                  // Implement navigation logic here
                                },
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
                                  Navigator.pop(context);
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
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WebMobilitiesFoodDataPage()),
                                  );
                                },
                              ),
                              ListTile(
                                leading:  Icon(Icons.flash_on),
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
                                  Navigator.pop(context);
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
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const WebMobilitiesWaterDataPage()),
                                  );
                                },
                              ),
                              if(isAdmin != null && isAdmin!)
                                ListTile(
                                  leading: const Icon(Icons.admin_panel_settings),
                                  title:  Text('Admin Panel',
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
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const WebAdminPage()),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                width: 1200,
                height: 600, // Max width constraint
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(121, 135, 119, 1).withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(189, 210, 182, 1),
                      Color.fromRGBO(123, 175, 146, 1.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 1160),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0), // Adjust padding as needed
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 360,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 120),
                                _buildAveragePointsCard(),
                              ],
                            ),
                          ),// Add spacing between columns if needed
                          SizedBox(
                            width: 800,
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 1.5,
                              shrinkWrap: true,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              children: [
                                _buildChartCard('Mobility', user!.fuelHistory, user!.fuelPoints, WebMobilitiesMobilityDataPage()),
                                _buildChartCard('Food', user!.foodHistory, user!.foodPoints, WebMobilitiesFoodDataPage()),
                                _buildChartCard('Electricity', user!.energyHistory, user!.energyPoints, WebMobilitiesElectricityDataPage()),
                                _buildChartCard('Water', user!.waterHistory, user!.waterPoints, WebMobilitiesWaterDataPage()),

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
            ],
          ),
    ),
      ),
    ),
    );
  }

  Widget _buildAveragePointsCard() {
    int avgPoints = averagePoints != null ? double.parse(averagePoints!).toInt() : 0;

    return Column(
      children: [
        Text(
          'Footprint Points',
          textAlign: TextAlign.center,
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: const TextStyle(
              color:  const Color.fromRGBO(82, 130, 103, 1.0),
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              color:  const Color.fromRGBO(82, 130, 103, 1.0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$avgPoints',
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont(
                  'Fjalla One',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1), // This color will be masked by the gradient
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChartCard(String title, String history, String points, Widget page) {
    List<double> values =
        history.split('|').map((e) => double.parse(e)).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                color:  const Color.fromRGBO(82, 130, 103, 1.0),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  page),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                  ),
                ),
              ),
              Text(
                '${double.parse(points).round()}',
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont(
                  'Fjalla One',
                  textStyle: const TextStyle(
                    color: const Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color:  const Color.fromRGBO(82, 130, 103, 1.0),
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
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(
                      color:  const Color.fromRGBO(82, 130, 103, 1.0),
                      width: 1,
                    ),
                    left: BorderSide(
                      color:  const Color.fromRGBO(82, 130, 103, 1.0),
                      width: 1,
                    ),
                    right: BorderSide.none,
                    top: BorderSide.none,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      min(5, values.length),
                      (index) {
                        return FlSpot(
                            index.toDouble(), values[index].toDouble());
                      },
                    ),
                    isCurved: true,
                    color:  const Color.fromRGBO(82, 130, 103, 1.0),
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
