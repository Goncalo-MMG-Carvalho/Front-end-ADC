import 'package:adc_handson_session/AppPage/application/admin_auth.dart';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/profile/presentation/userInfoPage.dart';
import 'package:flutter/material.dart';

import '../../exceptions/invalid_token.dart';
import '../../group/presentation/group_screen.dart';
import '../../login/domain/GroupInfo.dart';
import '../../login/domain/User.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

const String SYSTEM_ADMIN = "SYS_ADMIN";

class _AdminPageState extends State<AdminPage> {
  AdminAuthentication admAuth = AdminAuthentication();

  bool? isSysAdmin;
  bool isLoading = true;

  @override
  void initState() {
    isSysAdm();
    super.initState();
  }

  Future<void> isSysAdm() async {
    String? role = await userUtils().getUserRole();
    bool isAdm = role == SYSTEM_ADMIN;
    setState(() {
      isSysAdmin = isAdm;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : Scaffold(
      backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
        title: Center(
          child: Text(
            'Admin Operations',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: const TextStyle(
                color: Color.fromRGBO(82, 130, 103, 1.0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildAdminButton('Access Group', Icons.groups, _accessGroupInfo),
          _buildAdminButton('Access User', Icons.perm_contact_cal_rounded, _accessUserInfo),

          if (isSysAdmin!)
            _buildAdminButton('Change Roles', Icons.person, _changeRoles),
          if (isSysAdmin!)
            _buildAdminButton('Remove Groups', Icons.group_remove, _removeGroups),
          if (isSysAdmin!)
            _buildAdminButton('Remove Users', Icons.person_remove, _removeUsers),
        ],
      ),
    );
  }

  Widget _buildAdminButton(
      String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color.fromRGBO(248, 237, 227, 1),
        backgroundColor: const Color.fromRGBO(82, 130, 103, 1.0),
        padding: const EdgeInsets.all(16.0),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 30),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _changeRoles() {
    _showDialog(
      'Change Roles',
      'Enter the username and new role:',
      'Username',
      'New Role',
      (String username, String newRole) {
        print('Changed roles for $username to $newRole');
      },
    );
  }

  void _removeGroups() {
    _showDialog(
      'Remove Groups',
      'Enter the group name to remove:',
      'Group Name',
      'Remove Group',
      (String groupId, String _) {
        print('Removed group with ID $groupId');
      },
    );
  }

  void _removeUsers() {
    _showDialog(
      'Remove Users',
      'Enter the username to remove:',
      'Username',
      'Remove User',
      (String username, String _) {
        print('Removed user $username');
      },
    );
  }

  void _accessGroupInfo() {
    _showDialog(
      'Access Group',
      'Enter the group name to access it:',
      'Group Name',
      'Access Group',
      (String groupId, String _) {
        print('Access group');
      },
    );
  }

  void _accessUserInfo() {
    _showDialog(
      'Access User',
      'Enter the username to access it:',
      'Username',
      'Access User',
      (String groupId, String _) {
        print('Access user');
      },
    );
  }


  void _showDialog(
    String title,
    String hintText,
    String labelText,
    String buttonText,
    void Function(String, String) onConfirm,
  ) {
    final TextEditingController firstController = TextEditingController();
    final TextEditingController secondController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title: Text(
            title,
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstController,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.getFont('Inter',
                      textStyle: TextStyle(color: Colors.grey.shade800)),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(82, 130, 103, 1.0),
                    ),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(
                          82, 130, 103, 1.0),
                    ),
                  ),
                  labelText: labelText,
                  labelStyle: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(82, 130, 103, 0.8),
                    ),
                  ),
                ),
                cursorColor: const Color.fromRGBO(82, 130, 103, 1.0),
              ),
              const SizedBox(height: 8),
              if (title != 'Remove Groups' &&
                  title != 'Remove Users' &&
                  title != 'Access Group' &&
                  title != 'Access User')
                TextField(
                  controller: secondController,
                  decoration: InputDecoration(
                    hintText: 'Second Field',
                    hintStyle: GoogleFonts.getFont('Inter',
                        textStyle: TextStyle(color: Colors.grey.shade800)),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(82, 130, 103, 1.0),
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(
                            82, 130, 103, 1.0),
                      ),
                    ),
                    labelText: 'Role',
                    labelStyle: GoogleFonts.getFont(
                      'Inter',
                      textStyle: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(82, 130, 103, 0.8),
                      ),
                    ),
                  ),
                  cursorColor: const Color.fromRGBO(82, 130, 103, 1.0),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
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
            ElevatedButton(
              onPressed: () {
                switch (title) {
                  case 'Access Group':
                    adminAccessGroup(firstController.text);
                    break;
                  case 'Access User':
                    adminAccessUser(firstController.text);
                    break;
                  case 'Change Roles':
                    changeUserRoles(
                        firstController.text, secondController.text);
                    break;
                  case 'Remove Groups':
                    removeGroup(firstController.text);
                    break;
                  case 'Remove Users':
                    removeUser(firstController.text);
                    break;
                }
                onConfirm(firstController.text, secondController.text);
                Navigator.of(context).pop();
              },
              child: Text(
                buttonText,
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
      },
    );
  }

  Future<void> adminAccessGroup(String groupName) async {
    String? username = await userUtils().getUsername();
    String color = Colors.green.value.toRadixString(16).padLeft(8, '0');
    GroupInfo groupInfo =
        GroupInfo(username: username!, groupName: groupName, color: color);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroupScreen(
                  groupInfo: groupInfo,
                )));
  }

  Future<void> adminAccessUser(String username) async {
    try {
      User? user = await admAuth.getUserAdm(username);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserInfoPage(user: user!)));
    } on TokenInvalidoException catch (e) {
        print('Erro ao carregar grupos: $e');
        userUtils().invalidSessionDialog(context);
    }
  }

  Future<void> changeUserRoles(String username, String newRole) async {
    try{
    bool res = await admAuth.changeUserRoles(username, newRole);
    if (res) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            title: Text(
              "Success",
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  color: Color.fromRGBO(82, 130, 103, 1.0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Text(
              "User role changed successfully.",
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
                      const Color.fromRGBO(82, 130, 103, 1.0),
                ),
                child: Text(
                  'Ok',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
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

  Future<void> removeGroup(String groupName) async {
    try{
    bool res = await admAuth.removeGroup(groupName);
    if (res) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            title: Text(
              "Success",
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: const TextStyle(
                  color: Color.fromRGBO(82, 130, 103, 1.0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Text(
              "Group removed successfully.",
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
                      const Color.fromRGBO(82, 130, 103, 1.0),
                ),
                child: Text(
                  'Ok',
                  style: GoogleFonts.getFont(
                    'Inter',
                    textStyle: const TextStyle(
                      color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
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

  Future<void> removeUser(String username) async {
    try {
      bool res = await admAuth.removeUser(username);
      if (res) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
              title: Text(
                "Success",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(82, 130, 103, 1.0),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Text(
                "User removed successfully.",
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
                    const Color.fromRGBO(82, 130, 103, 1.0),
                  ),
                  child: Text(
                    'Ok',
                    style: GoogleFonts.getFont(
                      'Inter',
                      textStyle: const TextStyle(
                        color: Color.fromRGBO(248, 237, 227, 1),
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
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

void main() {
  runApp(MaterialApp(
    home: const AdminPage(),
    theme: ThemeData(primarySwatch: Colors.blue),
  ));
}
