import 'dart:async';

import 'package:adc_handson_session/AppPage/application/admin_auth.dart';
import 'package:adc_handson_session/AppPage/presentation/appPage_screen.dart';
import 'package:adc_handson_session/Utils/firebaseUtils.dart';
import 'package:adc_handson_session/Utils/groupUtils.dart';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/group/application/auth.dart';
import 'package:adc_handson_session/group/presentation/requests_screen.dart';
import 'package:adc_handson_session/group/presentation/top_users_screen.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../AppPage/application/auth.dart';
import '../../exceptions/invalid_token.dart';
import '../../login/domain/Group.dart';
import '../../login/domain/Messages.dart';
import '../dialogs/group_dialogs.dart';
import 'group_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'group_statistics_screen.dart';

const String SYSTEM_ADMIN = "SYS_ADMIN"; //TODO MUDAR DE ACORDO COM O BACKEND
const String SYSTEM_ADMIN_MANAGER =
    "SYS_MANAGER"; //TODO MUDAR DE ACORDO COM O BACKEND

class WebGroupScreen extends StatefulWidget {
  final GroupInfo groupInfo;

  const WebGroupScreen({required this.groupInfo, super.key});

  @override
  State<WebGroupScreen> createState() => _WebGroupScreen();
}

class _WebGroupScreen extends State<WebGroupScreen> {
  AdminAuthentication adminAuth = AdminAuthentication();
  AuthenticationGroup auth = AuthenticationGroup();
  AuthenticationAppPage authApp = AuthenticationAppPage();

  bool _isLoading = true;

  List<String>? users = [];
  List<String>? admins = [];

  bool? isAdm;

  String? usernameLog;

  String? role;

  String? userRole;

  String? owner;

  Group? group;

  bool _isExpandedOwner = false;
  bool _isExpandedAdmins = false;
  bool _isExpandedUsers = false;
  bool showUserList = false;

  void _toggleUserList() {
    setState(() {
      showUserList = !showUserList;
    });
  }

  @override
  void initState() {
    getGroup();
    super.initState();
  }

  Future<void> getUserRole() async {
    String? role = await userUtils().getUserRole();
    setState(() {
      userRole = role;
    });
  }

  bool isPublic(Group group) {
    print("ISPUBLIC: ${group.access}");
    return group.access;
  }

  bool isSysAdmin() {
    return role == SYSTEM_ADMIN;
  }

  bool isSysAdminManager() {
    return role == SYSTEM_ADMIN_MANAGER;
  }

  Future<void> isAdmin(Group group) async {
    bool isA = await groupUtils().isAdmin(group, usernameLog!);
    setState(() {
      isAdm = isA;
    });
  }

  Future<void> getUserNameAndRole() async {
    final token = await userUtils().getToken();
    var tokenSplit = token?.split(".");
    setState(() {
      usernameLog = tokenSplit?[0];
      role = tokenSplit?[2];
    });
  }

  bool canRemoveUser(String userToRem) {
    if (userToRem == owner || users!.contains(usernameLog)) {
      return false;
    } else if ((admins!.contains(usernameLog) && users!.contains(userToRem)) ||
        usernameLog == owner) {
      return true;
    } else {
      return false;
    }
  }

  bool canSeeRequests() {
    return !isPublic(group!) && isAdm!;
  }

  Future<void> getGroup() async {
    try{
      await getUserNameAndRole();
      Group? groupR = await auth.getGroup(widget.groupInfo.groupName);
      setState(() {
        group = groupR;
      });
      await isAdmin(group!);
      createUsersList();
      setState(() {
        _isLoading = false;
      });
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  void createUsersList() {
    owner = group?.groupOwner;

    var adminsNames = group?.adminNames.split("|");
    admins = adminsNames;

    var usersNames = group?.members.split("|");
    users = usersNames;

    users?.remove(owner);

    admins?.remove(owner);

    admins?.forEach((admin) {
      users?.remove(admin);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Life',
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor:
                    groupUtils().getGroupColor(widget.groupInfo.color),
                title: Center(
                    child: Text(
                  widget.groupInfo.groupName,
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: const Color.fromRGBO(248, 237, 227, 1),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        color: const Color.fromRGBO(248, 237, 227, 1),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  ),
                ],
              ),
              endDrawer: Drawer(
                backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                child: menu(),
              ),
              body: Row(
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
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10.0),
                                  Row(children: [
//PAINEIS ESQUERDA ----------------------------------------------------------------------
                                    Container(
                                      width: 200,
                                      height: 410,
                                      child: ListView(
                                        padding: EdgeInsets.zero,
                                        children: <Widget>[
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  248, 237, 227, 0.6),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Menu',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.getFont(
                                                  'Inter',
                                                  textStyle: TextStyle(
                                                    color: Color.fromRGBO(248, 237, 227, 1.0),
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (showUserList)
                                            SizedBox(
                                              height:
                                                  360, // Adjust this if necessary
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: ListView(
                                                      children:
                                                          _buildUserListWeb(),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    title: Text(
                                                      'Back',
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: Color.fromRGBO(248, 237, 227, 1),
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: _toggleUserList,
                                                  ),
                                                ],
                                              ),
                                            )
                                          else
                                            SizedBox(
                                              height:
                                                  360, // Adjust this if necessary
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: ListView(
                                                      children:
                                                          _buildMainMenuWithoutTopUsers(),
                                                    ),
                                                  ),
                                                  if (!isSysAdminManager() &&
                                                      !isSysAdmin() &&
                                                      usernameLog != owner)
                                                    ListTile(
                                                      leading: const Icon(Icons
                                                          .exit_to_app, color: Color.fromRGBO(248, 237, 227, 1.0)), // Icon for LeaveGroup
                                                      title: Text(
                                                        'Leave Group',
                                                        style:
                                                            GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle: TextStyle(
                                                            color: Color.fromRGBO(248, 237, 227, 1),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        _showLeaveGroupConfirmationDialog(
                                                            group!);
                                                      },
                                                    ),
                                                  if (usernameLog == owner)
                                                    ListTile(
                                                      leading: const Icon(Icons
                                                          .exit_to_app, color: Color.fromRGBO(248, 237, 227, 1.0)), // Icon for LeaveGroup
                                                      title: Text(
                                                        'Delete Group',
                                                        style:
                                                            GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle: TextStyle(
                                                            color: Color.fromRGBO(248, 237, 227, 1),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        showDeleteGroupConfirmationDialog(
                                                            groupUtils()
                                                                .getGroupColor(
                                                                    widget
                                                                        .groupInfo
                                                                        .color),
                                                            group!);
                                                      },
                                                    ),
                                                ],
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
//PAINEIS CENTRAIS ----------------------------------------------------------------------
                                    Column(
                                      children: [
//PRIMEIRO PAINEL -----------------------------------------------------------------------------------
                                        Container(
                                          width: 900,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromRGBO(
                                                    248, 237, 227, 0.6),
                                                Color.fromRGBO(
                                                    248, 237, 227, 1.0),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          //PAINEL
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                left: 60,
                                                child: Container(
                                                  width: 300, // Adjust width as needed
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(248, 237, 227, 1),
                                                    border: Border.all(
                                                      color: groupUtils()
                                                          .getGroupColor(widget.groupInfo.color),
                                                      width: 2, // Border width
                                                    ),
                                                    borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Center(
                                                      child: Text(
                                                        double.parse(group!
                                                                .averageCo2!)
                                                            .round()
                                                            .toStringAsFixed(2),
                                                        style:
                                                            GoogleFonts.getFont(
                                                          'Fjalla One',
                                                          textStyle: TextStyle(
                                                            color: groupUtils()
                                                                .getGroupColor(
                                                                    widget
                                                                        .groupInfo
                                                                        .color)
                                                                .withOpacity(
                                                                    0.8), // This color will be masked by the gradient
                                                            fontSize: 70,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                top: 30,
                                                left: 490,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Average Footprint:',
                                                      style:
                                                      GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color)
                                                              .withOpacity(0.8),
                                                          fontSize: 30,
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
                                                left: 450,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Mobility: ',
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                                  widget
                                                                      .groupInfo
                                                                      .color)
                                                              .withOpacity(0.8),
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "${double.parse(group!.fuelCo2!).round().toStringAsFixed(2)}kg Co2",
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                                  widget
                                                                      .groupInfo
                                                                      .color),
                                                          fontSize: 20,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor: groupUtils()
                                                              .getGroupColor(
                                                                  widget
                                                                      .groupInfo
                                                                      .color),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 20),
                                                    Text(
                                                      'Food: ',
                                                      style:
                                                      GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color)
                                                              .withOpacity(0.8),
                                                          fontSize: 24,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "${double.parse(group!.foodCo2!).round().toStringAsFixed(2)}kg Co2",
                                                      style:
                                                      GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color),
                                                          fontSize: 20,
                                                          decoration:
                                                          TextDecoration
                                                              .underline,
                                                          decorationColor: groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color),
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 130,
                                                left: 420,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Electricity: ',
                                                      style:
                                                      GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color)
                                                              .withOpacity(0.8),
                                                          fontSize: 24,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "${double.parse(group!.electricityCo2!).round().toStringAsFixed(2)}kg Co2",
                                                      style:
                                                      GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color),
                                                          fontSize: 20,
                                                          decoration:
                                                          TextDecoration
                                                              .underline,
                                                          decorationColor:
                                                          groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color)
                                                              .withOpacity(
                                                              0.8),
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 20),
                                                    Text(
                                                      'Water: ',
                                                      style:
                                                      GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color)
                                                              .withOpacity(0.8),
                                                          fontSize: 24,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "${double.parse(group!.tapCo2!).round().toStringAsFixed(2)}kg Co2",
                                                      style:
                                                      GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color),
                                                          fontSize: 20,
                                                          decoration:
                                                          TextDecoration
                                                              .underline,
                                                          decorationColor: groupUtils()
                                                              .getGroupColor(
                                                              widget
                                                                  .groupInfo
                                                                  .color),
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
//SEGUNDO PAINEL -----------------------------------------------------------
                                        Row(children: [
                                          Container(
                                            width: 445,
                                            height: 200,
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
                                                            color: groupUtils().getGroupColor(widget.groupInfo.color).withOpacity(0.8),
                                                            fontSize: 28,
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
                                                        'Electricity',
                                                        style: GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle: TextStyle(
                                                            color:groupUtils().getGroupColor(widget.groupInfo.color).withOpacity(0.8),
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.normal,
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
                                                        /*double.parse(widget.group!.foodValues!).round().toString(),*/
                                                        "${group!.averageElectricity!}kWh/month",
                                                        style: GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle: TextStyle(
                                                            color: groupUtils().getGroupColor(widget.groupInfo.color),
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
                                                        'Water',
                                                        style: GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle: TextStyle(
                                                            color: groupUtils().getGroupColor(widget.groupInfo.color).withOpacity(0.8),
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.normal,
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
                                                        'Tap: ',
                                                        style: GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle: TextStyle(
                                                            color: groupUtils().getGroupColor(widget.groupInfo.color).withOpacity(0.8),
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.normal,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${group!.averageTapWater!}l/month",
                                                        style: GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle: TextStyle(
                                                            color: groupUtils().getGroupColor(widget.groupInfo.color),
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
                                                            color: groupUtils().getGroupColor(widget.groupInfo.color).withOpacity(0.8),
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.normal,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${group!.averageBottleWater!}l/week",
                                                        style: GoogleFonts.getFont(
                                                          'Inter',
                                                          textStyle: TextStyle(
                                                            color: groupUtils().getGroupColor(widget.groupInfo.color),
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
//SEGUNDO PAINEL - Info-------------------------------------------------------------------------------
                                          const SizedBox(width: 10.0),
                                          Container(
                                            width: 445,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color.fromRGBO(
                                                      248, 237, 227, 0.6),
                                                  Color.fromRGBO(
                                                      248, 237, 227, 1.0),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                      'Footprint information: ',
                                                      style: GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils().getGroupColor(widget.groupInfo.color).withOpacity(0.8),
                                                          fontSize: 28,
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
                                                      textAlign:
                                                          TextAlign.center,
                                                          "The Average Footprint is calculated from "
                                                          "\nthe values the users of this group \nenter, "
                                                          "to give you an idea of how good\n"
                                                          "their footprint is.",
                                                      style:
                                                          GoogleFonts.getFont(
                                                        'Inter',
                                                        textStyle: TextStyle(
                                                          color: groupUtils()
                                                              .getGroupColor(
                                                                  widget
                                                                      .groupInfo
                                                                      .color),
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ]),
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
              backgroundColor:
                  groupUtils().getGroupColor(widget.groupInfo.color),
            ),
    );
  }

  Widget menu() {
    return ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 100, // Set the desired height here
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: groupUtils().getGroupColor(widget.groupInfo.color),
              ),
              child: Center(
                // Center the child content if needed
                child: Text(
                  'Menu',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: TextStyle(
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
          if (showUserList)
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  100.0, // Adjust this if necessary
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: ListView(
                      children: _buildUserList(),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Back',
                      style: GoogleFonts.getFont(
                        'Inter',
                        textStyle: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: _toggleUserList,
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  100.0, // Adjust this if necessary
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: ListView(
                      children: _buildMainMenuWithoutTopUsersWeb(),
                    ),
                  ),
                  if (!isSysAdminManager() &&
                      !isSysAdmin() &&
                      usernameLog != owner)
                    ListTile(
                      leading:
                          const Icon(Icons.exit_to_app), // Icon for LeaveGroup
                      title: Text(
                        'Leave Group',
                        style: GoogleFonts.getFont(
                          'Inter',
                          textStyle: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showLeaveGroupConfirmationDialog(group!);
                      },
                    ),
                  if (usernameLog == owner)
                    ListTile(
                      leading:
                          const Icon(Icons.exit_to_app), // Icon for LeaveGroup
                      title: Text(
                        'Delete Group',
                        style: GoogleFonts.getFont(
                          'Inter',
                          textStyle: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        showDeleteGroupConfirmationDialog(
                            groupUtils().getGroupColor(widget.groupInfo.color),
                            group!);
                      },
                    ),
                ],
              ),
            )
        ]);
  }

  List<Widget> _buildUserList() {
    return [
      ExpansionTile(
        leading: Icon(
          Icons.person_3,
          color: _isExpandedOwner
              ? groupUtils().getGroupColor(widget.groupInfo.color)
              : Colors.grey.shade800,
        ),
        title: Text(
          'Owner',
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: Icon(
          _isExpandedOwner ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: _isExpandedOwner ? groupUtils().getGroupColor(widget.groupInfo.color) : Colors.grey.shade800,
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpandedOwner = expanded; // Update state when expansion changes
          });
        },
        children: [
          ListTile(
            title: Text(
              owner!,
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _showUserInformation(owner!);
            },
          ),
        ],
      ),
      ExpansionTile(
        leading: Icon(
          Icons.person_4,
          color: _isExpandedAdmins
              ? groupUtils().getGroupColor(widget.groupInfo.color)
              : Colors.grey.shade800,
        ),
        title: Text(
          'Admins',
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: Icon(
          _isExpandedAdmins ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: _isExpandedAdmins ? groupUtils().getGroupColor(widget.groupInfo.color) : Colors.grey.shade800,
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpandedAdmins = expanded; // Update state when expansion changes
          });
        },
        children: admins!.map((admin) {
          return ListTile(
            title: Text(
              admin,
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _showUserInformation(admin);
            },
          );
        }).toList(),
      ),
      ExpansionTile(
        leading: Icon(
          Icons.person_2,
          color: _isExpandedUsers
              ? groupUtils().getGroupColor(widget.groupInfo.color)
              : Colors.grey.shade800,
        ),
        title: Text(
          'Users',
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: Icon(
          _isExpandedUsers ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: _isExpandedUsers ? groupUtils().getGroupColor(widget.groupInfo.color) : Colors.grey.shade800,
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpandedUsers = expanded; // Update state when expansion changes
          });
        },
        children: users!.map((user) {
          return ListTile(
            title: Text(
              user,
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _showUserInformation(user);
            },
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildUserListWeb() {
    return [
      ExpansionTile(
        leading: Icon(
          Icons.person_3,
          color: _isExpandedOwner ? Colors.grey.shade800 : Color.fromRGBO(248, 237, 227, 1),
      ),
        title: Text(
          'Owner',
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: TextStyle(
              color: Color.fromRGBO(248, 237, 227, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: Icon(
          _isExpandedOwner ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: _isExpandedOwner ? Colors.grey.shade800 : Color.fromRGBO(248, 237, 227, 1),
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpandedOwner = expanded; // Update state when expansion changes
          });
        },
        children: [
          ListTile(
            title: Text(
              owner!,
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Color.fromRGBO(248, 237, 227, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _showUserInformation(owner!);
            },
          ),
        ],
      ),
      ExpansionTile(
        leading: Icon(
          Icons.person_4,
          color: _isExpandedAdmins ? Colors.grey.shade800 : Color.fromRGBO(248, 237, 227, 1),
        ),
        title: Text(
          'Admins',
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: TextStyle(
              color: Color.fromRGBO(248, 237, 227, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: Icon(
          _isExpandedAdmins ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: _isExpandedAdmins ? Colors.grey.shade800 : Color.fromRGBO(248, 237, 227, 1),
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpandedAdmins = expanded; // Update state when expansion changes
          });
        },
        children: admins!.map((admin) {
          return ListTile(
            title: Text(
              admin,
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Color.fromRGBO(248, 237, 227, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _showUserInformation(admin);
            },
          );
        }).toList(),
      ),
      ExpansionTile(
        leading: Icon(
          Icons.person_2,
          color: _isExpandedUsers ? Colors.grey.shade800 : Color.fromRGBO(248, 237, 227, 1),
        ),
        title: Text(
          'Users',
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: TextStyle(
              color: Color.fromRGBO(248, 237, 227, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: Icon(
          _isExpandedUsers ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: _isExpandedUsers ? Colors.grey.shade800 : Color.fromRGBO(248, 237, 227, 1),
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpandedUsers = expanded; // Update state when expansion changes
          });
        },
        children: users!.map((user) {
          return ListTile(
            title: Text(
              user,
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Color.fromRGBO(248, 237, 227, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _showUserInformation(user);
            },
          );
        }).toList(),
      ),
    ];
  }

  void _showUserInformation(String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title: Text(
            'User Information',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                color: groupUtils().getGroupColor(widget.groupInfo.color),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Username: $username',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                // TODO add more user information here as needed
              ],
            ),
          ),
          actions: <Widget>[
            if (canRemoveUser(username) || isSysAdmin())
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  showRemoveUserConfirmation(username);
                  // Add logic to remove user from group here
                },
                child: Text(
                  'Remove user',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            if (usernameLog == owner && users!.contains(username) ||
                isSysAdmin())
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  'Promote to admin',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                onPressed: () {
                  groupDialogs().showTransiteUserConfirmation(username, true,
                      group!, context, widget.groupInfo); // Close the dialog
                },
              ),
            if (usernameLog == owner && admins!.contains(username) ||
                isSysAdmin())
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  'Demote to user',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                onPressed: () {
                  showTransiteUserConfirmation(username, false);
                },
              ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                'Close',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
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


  List<Widget> _buildMainMenuWithoutTopUsers() {
    return [
      ListTile(
        leading: const Icon(Icons.people, color: Color.fromRGBO(248, 237, 227, 1.0)), // Icon for Users
        title: Text(
          'Users',
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: TextStyle(
              color: Color.fromRGBO(248, 237, 227, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: _toggleUserList,
      ),
      if (canSeeRequests())
        ListTile(
          leading: const Icon(Icons.mail), // Icon for Item 2
          title: Text(
            'Requests',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                color: Color.fromRGBO(248, 237, 227, 1),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupRequestsPage(group: group),
              ),
            );
          },
        ),
    ];
  }

  List<Widget> _buildMainMenuWithoutTopUsersWeb() {
    return [
      ListTile(
        leading:  Icon(Icons.people, color:Colors.grey.shade800,), // Icon for Users
        title: Text(
          'Users',
          style: GoogleFonts.getFont(
            'Inter',
            textStyle: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: _toggleUserList,
      ),
      if (canSeeRequests())
        ListTile(
          leading: Icon(Icons.mail, color:Colors.grey.shade800,), // Icon for Item 2
          title: Text(
            'Requests',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
              color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupRequestsPage(group: group),
              ),
            );
          },
        ),
    ];
  }

  Future<void> leaveGroup(Group group) async {
    try {
      bool res = await AuthenticationGroup().leaveGroup(group);

      if (res) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AppPage(initialTabIndex: 1)),
          );
        }
      }
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  void _showLeaveGroupConfirmationDialog(Group group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title: Text(
            'Leave Group',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                color: groupUtils().getGroupColor(widget.groupInfo.color),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'Are you sure you want to leave this group?',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // Green background
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Red background
              ),
              child: Text(
                'Leave',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                leaveGroup(group);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteGroup(Group group) async {
    try {
      bool res = await adminAuth.removeGroup(group.groupName);

      if (res) {
        await AuthenticationGroup().removeUserFromGroup(group);
      }
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  void showDeleteGroupConfirmationDialog(Color color, Group group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title: Text(
            'Delete Group',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'Are you sure you want to delete this group?',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // Green background
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Red background
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              onPressed: () async {
                await deleteGroup(group);
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AppPage(initialTabIndex: 1)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> removeUser(String username) async {
    try{
      print("GROUP NO REMOVE USER: $group");

      bool res = await AuthenticationGroup().removeUser(group!, username);

      if (res) {
        _userRemovedDialog(username);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GroupScreen(
                    groupInfo: widget.groupInfo,
                  )),
        );
      }
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  _userRemovedDialog(String userRemoved) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title: Text(
            '$userRemoved removed',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                color: groupUtils().getGroupColor(widget.groupInfo.color),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'The user has been successfully removed from the group.',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    groupUtils().getGroupColor(widget.groupInfo.color),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the user removed confirmation dialog
              },
              child: Text(
                'Close',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  showRemoveUserConfirmation(String userToRemove) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            title: Text(
              'Confirm Removal',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: groupUtils().getGroupColor(widget.groupInfo.color),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Text(
              'Are you sure you want to remove this user?',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  print('Removing user: $userToRemove');
                  removeUser(userToRemove);
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  Navigator.of(context)
                      .pop(); // Close the user information dialog
                },
                child: Text(
                  'Remove',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  userTransition(String userToTransition, bool isPromotion) async {
    try {
      bool res = await AuthenticationGroup()
          .roleTransition(group!, userToTransition, isPromotion);

      if (res) {
        userTransitionDialog(userToTransition, isPromotion);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GroupScreen(
                    groupInfo: widget.groupInfo,
                  )),
        );
      }
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  userTransitionDialog(String userTransition, bool isPromotion) {
    String transition;
    if (isPromotion) {
      transition = "promoted.";
    } else {
      transition = "demoted.";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title: Text(
            '$userTransition $transition',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                color: groupUtils().getGroupColor(widget.groupInfo.color),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'The user has been successfully $transition.«',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the user removed confirmation dialog
              },
              child: Text(
                'Close',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  showTransiteUserConfirmation(String userToTransite, bool isPromotion) {
    String transition;
    String transition2;

    if (isPromotion) {
      transition = "Promotion";
      transition2 = "promote";
    } else {
      transition = "Demotion";
      transition2 = "demote";
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            title: Text(
              'Confirm $transition',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: groupUtils().getGroupColor(widget.groupInfo.color),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Text(
              'Are you sure you want to $transition2 this user?',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  print(userToTransite);
                  userTransition(userToTransite, isPromotion);
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  Navigator.of(context)
                      .pop(); // Close the user information dialog
                },
                child: Text(
                  transition2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Container buildUserWidget(double width, int index, String user, Color color) {

    return Container(
      width: width,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(
                248, 237, 227, 0.8),
            Color.fromRGBO(248, 237, 227, 1.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: [
          Row(
            children: [
              if (index <= 3)
                Container(
                  width: 35, // Set the width of the square
                  height: 35,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6.0),
                  ), // Background color of the square
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: GoogleFonts.getFont(
                        'Inter',
                        textStyle: TextStyle(
                          color: Color.fromRGBO(248, 237, 227, 1),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Center(
                  child: Text(
                    '  $index |',
                    style: GoogleFonts.getFont(
                      'Inter',
                      textStyle: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              SizedBox(width: 10),
              Center(
                child: Text(
                  user,
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Center(
            child: Text(
              '86',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
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
