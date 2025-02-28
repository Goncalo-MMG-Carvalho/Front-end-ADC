import 'package:adc_handson_session/AppPage/presentation/groups_screen.dart';
import 'package:adc_handson_session/MapPage/presentation/mapPage.dart';
import 'package:adc_handson_session/profile/presentation/profilePage_screen.dart';
import 'package:adc_handson_session/tipsPage/presentation/features_screen.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';


import '../../Utils/userUtils.dart';
import '../../company/presentation/company_values_screen.dart';
import '../../tipsPage/presentation/about_screen.dart';
import '../../topGroups/presentation/topGroups_screen.dart';
import 'admins_control_screen.dart';
import 'homeUserPage_screen.dart';

class AppPage extends StatefulWidget {
  final int initialTabIndex;

  const AppPage({super.key, this.initialTabIndex = 0});

  @override
  State<AppPage> createState() => _AppPage();
}

class _AppPage extends State<AppPage> {

  bool? isAdmin;
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isAdm();
  }

  Future<void> isAdm() async {
    bool isAdm = await userUtils().isAdmin();
    String? r = await userUtils().getUserRole();
    setState(() {
      role = r!;
      isAdmin = isAdm;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        title: 'Green Life',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color.fromRGBO(248, 237, 227, 1),
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(82, 130, 103, 1.0)),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Green Life',
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: (isAdmin != null && isAdmin!) ? 3 : 2,
        initialIndex: widget.initialTabIndex,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
            title: Center(
              child: Image.asset(
                'assets/logo.png', // Replace with your image path
                height: 70, // Adjust the height as needed
              ),
            ),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  color: const Color.fromRGBO(82, 130, 103, 1.0),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                color: const Color.fromRGBO(82, 130, 103, 1.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: tapBar(),
          body: TabBarView(
            children: [
              Container(child: const HomePage()),
              Container(child: const GroupsPage()),
              if(isAdmin != null && isAdmin!)
                Container(child: const AdminPage(),)
            ],
          ),
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          //DRAWER
          drawer: Drawer(
            width: MediaQuery.of(context).size.width * 0.7,
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            child: menu(),
          ),
        ),
      ),
    );
  }

  Widget tapBar() {
    return Container(
      color: const Color.fromRGBO(82, 130, 103, 1.0),
      child: TabBar(
        labelColor: const Color.fromRGBO(248, 237, 227, 1),
        unselectedLabelColor: const Color.fromRGBO(248, 237, 227, 1),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(5.0),
        indicatorColor: const Color.fromRGBO(248, 237, 227, 1),
        tabs: [
          const Tab(
            icon: Icon(Icons.home),
          ),
          const Tab(
            icon: Icon(Icons.group),
          ),
          if(isAdmin != null && isAdmin!)
            const Tab(
              icon: Icon(Icons.admin_panel_settings),
            )
        ],
      ),
    );
  }

  Widget menu() {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 100, // Set your desired height here
          decoration: const BoxDecoration(
            color: Color.fromRGBO(82, 130, 103, 1.0),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            );
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FeaturesPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.star),
          title:  Text('Community Page',
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
              MaterialPageRoute(builder: (context) => const TopGroupsPage()),
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
                MaterialPageRoute(builder: (context) => const CompanyValuesPage()),
              );
            },
          ),
      ],
    );
  }
}
