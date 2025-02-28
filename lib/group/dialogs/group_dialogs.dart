import 'dart:async';

import 'package:adc_handson_session/AppPage/application/admin_auth.dart';
import 'package:adc_handson_session/AppPage/presentation/appPage_screen.dart';
import 'package:adc_handson_session/group/application/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/groupUtils.dart';
import '../../login/domain/Group.dart';
import '../../login/domain/GroupInfo.dart';
import '../presentation/group_screen.dart';


class groupDialogs {

  AdminAuthentication adminAuth = AdminAuthentication();
  AuthenticationGroup authGroup = AuthenticationGroup();

  
  Future<void> deleteGroup(context, Group group) async {
    bool res = await adminAuth.removeGroup(group.groupName);

    if (res) {
      await AuthenticationGroup().removeUserFromGroup(group);
    }
  }

  void showDeleteGroupConfirmationDialog(context, Color color, Group group) {
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
                await deleteGroup(context, group);
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


  Future<void> leaveGroup(Group group, context) async {
    bool res = await authGroup.leaveGroup(group);

    if (res) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const AppPage(initialTabIndex: 1)),
      );
    }
  }

  void showLeaveGroupConfirmationDialog(context, GroupInfo groupInfo, Group group) {
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
                color: groupUtils().getGroupColor(groupInfo.color),
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
                leaveGroup(group, context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> removeUser(String username, context, Group group, GroupInfo groupInfo) async {
    print("GROUP NO REMOVE USER: $group");

    bool res = await authGroup.removeUser(group, username);

    if (res) {
      _userRemovedDialog(username, context, group, groupInfo);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GroupScreen(
              groupInfo: groupInfo,
            )),
      );
    }
  }

  _userRemovedDialog(String userRemoved, context, Group group, GroupInfo groupInfo) {
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
                color: groupUtils().getGroupColor(groupInfo.color),
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
                color:  Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: groupUtils().getGroupColor(groupInfo.color),
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

  showRemoveUserConfirmation(String userToRemove, context, Group group, GroupInfo groupInfo) {
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
                  color: groupUtils().getGroupColor(groupInfo.color),
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
                  groupDialogs().removeUser(userToRemove, context, group, groupInfo);
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  Navigator.of(context).pop(); // Close the user information dialog
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


  userTransition(String userToTransition, bool isPromotion, Group group, context, GroupInfo groupInfo) async {
    bool res = await authGroup.roleTransition(group, userToTransition, isPromotion);

    if (res) {
      userTransitionDialog(userToTransition, isPromotion, group, context, groupInfo);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GroupScreen(
              groupInfo: groupInfo,
            )),
      );
    }
  }

  userTransitionDialog(String userTransition, bool isPromotion, Group group, context, GroupInfo groupInfo) {
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
          title: Text('$userTransition $transition',
            style: GoogleFonts.getFont(
              'Inter',
              textStyle: TextStyle(
                color: groupUtils().getGroupColor(groupInfo.color),
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

  showTransiteUserConfirmation(String userToTransite, bool isPromotion, Group group, context, GroupInfo groupInfo) {
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
            title: Text('Confirm $transition',
              style: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: groupUtils().getGroupColor(groupInfo.color),
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
                  userTransition(userToTransite, isPromotion, group, context, groupInfo);
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




}