import 'package:adc_handson_session/AppPage/application/auth.dart';
import 'package:adc_handson_session/AppPage/dialogs/appPage_dialogs.dart';
import 'package:adc_handson_session/AppPage/presentation/webPage_screen.dart';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/group/presentation/group_screen.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../company/presentation/web_company_values_screen.dart';
import '../../exceptions/invalid_token.dart';
import '../../group/presentation/web_group_screen.dart';
import '../../login/presentation/login_screen.dart';
import '../../mobilitiesPage/presentation/web_MobilitiesDataElectricity_screen.dart';
import '../../mobilitiesPage/presentation/web_MobilitiesDataFood_screen.dart';
import '../../mobilitiesPage/presentation/web_MobilitiesDataMobility_screen.dart';
import '../../mobilitiesPage/presentation/web_MobilitiesDataWater_screen.dart';
import '../../profile/presentation/web_profilePage_screen.dart';
import '../../tipsPage/presentation/web_about_screen.dart';
import '../../tipsPage/presentation/web_features_screen.dart';
import '../../topGroups/presentation/web_topGroups_screen.dart';

const String PUBLIC = "public";
const String PRIVATE = "private";

class WebgroupsScreen extends StatefulWidget {
  const WebgroupsScreen({super.key});

  @override
  State<WebgroupsScreen> createState() => _WebgroupsScreen();
}

class _WebgroupsScreen extends State<WebgroupsScreen> {
  int _pageIndex = 0;

  String PERSONAL_ROLE = "USER_PERSONAL";

  String userRole = "";

  AuthenticationAppPage auth = AuthenticationAppPage();

  userUtils uUtils = userUtils();

  bool _showAddForm = false;
  bool _showIcon = false;

  final TextEditingController _groupNameController = TextEditingController();

  Color _selectedColor = Colors.teal;

  bool isPublic = true;

  bool isBusiness = false;

  bool isLoading = true;

  List<GroupInfo> _groups = [];

  List<GroupInfo> _groupsToShow = [];

  Future<void> navigateToLogin() async {
    // Navegar para a tela de login e remover todas as rotas empilhadas anteriores
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  void getUserRole() async {
    String role = (await uUtils.getUserRole())!;
    setState(() {
      userRole = role;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserRole();
    addGroupsInfo();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _toggleAddForm() {
    setState(() {
      _showAddForm = !_showAddForm;
    });
  }

  void _toggleIcon() {
    setState(() {
      _showIcon = !_showIcon;
    });
  }

  Future<void> addGroupsInfo() async {
    try {
      _groups = (await auth.getGroups())!;

      setState(() {
        isLoading = false;
        _groupsToShow = _groups;
      });
      print(_groups);

    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);

    }
  }

  Future<void> createGroupButtonPressed(String groupName, Color color) async {
    print('entrou');
    String colorString = color.value.toRadixString(16).padLeft(8, '0');

    if(!auth.isGroupNameValid(groupName)){
      print('é nao é valido');
      appPage_dialogs().invalidGroupAlert(context);
    }else {
      print('entrou');
      bool verification = await auth.createGroup(groupName, isPublic, isBusiness, colorString);

      if (verification) {
        print('entrou verification');
        setState(() {
          isLoading = true;
        });
        addGroupsInfo();
      }
    }

  }

  Future<void> joinGroupButtonPressed(String groupName) async {
    try{
    print("BOTAO PRESSIONADO");
    String res = await auth.joinGroup(groupName);
    print(res);
    if (res == PUBLIC) {
      setState(() {
        isLoading = true;
      });
      addGroupsInfo();
    } else {
      print("GRUPO PRIVADO");
      privateGroupAlert();
    }
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);

    }
  }

  void privateGroupAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          content: Text('The group is private, request to join sent',
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
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
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
                  MaterialPageRoute(builder: (context) =>  const WebProfilePage())
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
              leading: const Icon(Icons.home),
              title:  Text('Home Page',
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
                  MaterialPageRoute(builder: (context) =>  const WebPage()),
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
            if(userRole == 'USER_BUSINESS')
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
          ],
        ),
      ),
      // Change color as desired
      body: isLoading
          ? const Center(
              // Display a loading indicator or message while loading
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 10.0, 16.0),
                          child: TextField(
                            cursorColor:
                                const Color.fromRGBO(82, 130, 103, 1.0),
                            style: GoogleFonts.getFont('Inter',
                              textStyle: const TextStyle(
                              fontSize: 20.0,
                              color:  Color.fromRGBO(82, 130, 103, 1.0),
                            ),
                            ),
                            onChanged: (value) {

                              setState(() {
                                _groupsToShow = _groups
                                    .where((group) =>
                                    group.groupName.toLowerCase().contains(value.toLowerCase()))
                                    .toList();
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color.fromRGBO(82, 130, 103, 1.0),
                              ),
                              hintText: "Search groups",
                              hintStyle: GoogleFonts.getFont('Inter',
                                  textStyle: const TextStyle(
                                      fontSize: 20.0,
                                      color:
                                          Color.fromRGBO(82, 130, 103, 0.9))),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(82, 130, 103, 1.0),
                                    width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(82, 130, 103, 1.0),
                                    width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color.fromRGBO(82, 130, 103, 1.0),
                                    width: 2.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showAddForm)
                    _buildForms(), // Show form if _showAddForm is true
                  const SizedBox(height: 20.0),
                  // Display added groups using Wrap instead of Row
                  Column(
                    children: _groupsToShow
                        .map((group) => _buildGroupSquare(group, context))
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildForms() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            //Color.fromRGBO(189, 210, 182, 1),
            //Color.fromRGBO(123, 175, 146, 1.0),
            Color.fromRGBO(82, 130, 103, 1.0),
            Color.fromRGBO(123, 175, 146, 1.0),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        //color: const Color.fromRGBO(189, 210, 182, 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(121, 135, 119, 1).withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _pageIndex = 0; // Set index for Create Group page
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pageIndex == 0
                      ? const Color.fromRGBO(82, 130, 103, 1.0)
                    : const Color.fromRGBO(172, 199, 164, 1.0),
                ),
                child: Text(
                  'Create Group',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _pageIndex = 1; // Set index for Join Group page
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pageIndex == 1
                      ? const Color.fromRGBO(82, 130, 103, 1.0)
                      : const Color.fromRGBO(172, 199, 164, 1.0),
                ),
                child: Text(
                  'Join Group',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20.0),
          IndexedStack(
            index: _pageIndex,
            children: [
              _buildAddGroupForm(),
              _buildJoinGroupForm(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJoinGroupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10.0),
        TextField(
          controller: _groupNameController,
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
              color: Color.fromRGBO(248, 237, 227, 1), // Set your desired text color here
            ),
          ),
          decoration: InputDecoration(
            labelText: 'Group Name',
            labelStyle: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(248, 237, 227, 1),
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromRGBO(82, 130, 103, 1.0),
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromRGBO(
                    248, 237, 227, 1), // Set your desired color here
              ),
            ),
          ),
          cursorColor: const Color.fromRGBO(82, 130, 103, 1.0),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            // Handle join group form submission
            String groupName = _groupNameController.text;
            joinGroupButtonPressed(groupName);
            _toggleAddForm();
            _groupNameController.clear(); // Clear text fields
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          ),
          child: Text(
            'Join Group',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                color: Color.fromRGBO(82, 130, 103, 1.0),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddGroupForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              //Color.fromRGBO(217, 229, 213, 1.0),
              //Color.fromRGBO(189, 210, 182, 1),
              Color.fromRGBO(248, 237, 227, 1),
              Color.fromRGBO(189, 210, 182, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(121, 135, 119, 1)
                  .withOpacity(0.5), // Shadow color
              spreadRadius: 5, // Spread radius
              blurRadius: 7, // Blur radius
              offset: const Offset(0, 3), // Offset
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _groupNameController,
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                color: Color.fromRGBO(82, 130, 103, 1.0), // Set your desired text color here
              ),
            ),
            decoration: InputDecoration(
              labelText: 'Group Name',
              labelStyle: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(121, 135, 119, 1),
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(82, 130, 103, 1.0),
                ),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(
                      121, 135, 119, 1), // Set your desired color here
                ),
              ),
            ),
            cursorColor: const Color.fromRGBO(82, 130, 103, 1.0),
          ),
          const SizedBox(height: 20.0),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Privacy:",
                    style: GoogleFonts.getFont(
                      'Inter',
                      textStyle: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                        color: Color.fromRGBO(82, 130, 103, 1.0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                child: RadioListTile<bool>(
                  title: Text(
                    'Public',
                    style: GoogleFonts.getFont(
                      'Inter',
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(82, 130, 103, 1.0),
                      ),
                    ),
                  ),
                  value: true,
                  groupValue: isPublic,
                  activeColor: const Color.fromRGBO(82, 130, 103, 1.0),
                  onChanged: (value) {
                    setState(() {
                      isPublic = value!;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                child: RadioListTile<bool>(
                  title: Text(
                    'Private',
                    style: GoogleFonts.getFont(
                      'Inter',
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(82, 130, 103, 1.0),
                      ),
                    ),
                  ),
                  value: false,
                  groupValue: isPublic,
                  activeColor: const Color.fromRGBO(82, 130, 103, 1.0),
                  onChanged: (value) {
                    setState(() {
                      isPublic = value!;
                    });
                  },
                ),
              )
            ],
          ),
          if (userRole != PERSONAL_ROLE) groupTypeChoice(),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Select Color:",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(82, 130, 103, 1.0),
                  ),
                ),
              ),
              //  const SizedBox(width: 10.0),
              // Color picker
              ElevatedButton(
                onPressed: () => _showColorPicker(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  shape: const CircleBorder(),
                ),
                child: const Text(""),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              // Handle form submission
              String groupName = _groupNameController.text;
              createGroupButtonPressed(groupName, _selectedColor);
              _toggleAddForm(); // Hide the form after submission
              _groupNameController.clear(); // Clear text fields
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(82, 130, 103, 1.0),
            ),
            child: Text(
              'Create Group',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  color: Color.fromRGBO(248, 237, 227, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget groupTypeChoice() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Group Type:",
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                  color: Color.fromRGBO(82, 130, 103, 1.0),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          child: RadioListTile<bool>(
            title: Text(
              'Personal',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(82, 130, 103, 1.0),
                ),
              ),
            ),
            value: false,
            groupValue: isBusiness,
            activeColor: const Color.fromRGBO(82, 130, 103, 1.0),
            onChanged: (value) {
              setState(() {
                isBusiness = value!;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          child: RadioListTile<bool>(
            title: Text(
              'Business',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(82, 130, 103, 1.0),
                ),
              ),
            ),
            value: true,
            groupValue: isBusiness,
            activeColor: const Color.fromRGBO(82, 130, 103, 1.0),
            onChanged: (value) {
              setState(() {
                isBusiness = value!;
              });
            },
          ),
        )
      ],
    );
  }

  // Method to show color picker dialog

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title: Text(
            'Choose a color:',
            style: GoogleFonts.getFont('Inter',
              textStyle: const TextStyle(
                color: Color.fromRGBO(82, 130, 103, 1.0),
                fontSize: 24,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
              displayThumbColor: false,
              labelTypes: const [ColorLabelType.rgb],
              paletteType: PaletteType.hueWheel,
              pickerAreaBorderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
          ),


          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(82, 130, 103, 1.0)),
              child:  Text(
                'Done',
                style: GoogleFonts.getFont('Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildGroupSquare(GroupInfo group, BuildContext context) {
  Color getGroupColor(String color) {
    int colorValue = int.parse(color, radix: 16);
    return Color(colorValue);
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 10.0), // Space under the button
    width: 350,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: getGroupColor(group.color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Make it squared
        ),
        padding: const EdgeInsets.all(0), // Remove default padding
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Custom padding for content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              group.groupName,
              textAlign: TextAlign.start,
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  color: Color.fromRGBO(248, 237, 227, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
      onPressed: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebGroupScreen(groupInfo: group,)
            )
        );
      },
    ),
  );
}
