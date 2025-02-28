import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopUsersScreen extends StatefulWidget {
  final GroupInfo groupInfo;

  const TopUsersScreen({required this.groupInfo, super.key});

  @override
  State<TopUsersScreen> createState() => _TopUsersScreen();
}

class _TopUsersScreen extends State<TopUsersScreen> {
  String groupName = "";

  Color getGroupColor(String color) {
    int colorValue = int.parse(color, radix: 16);
    return Color(colorValue);
  }

  @override
  void initState() {
    super.initState();
    groupName = widget.groupInfo.groupName;
  }

  @override
  Widget build(BuildContext context) {
    List<String> topUsers = ["User 1", "User 2", "User 3", "User 4", "User 5"];

    return MaterialApp(
      title: 'Green Life',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: getGroupColor(widget.groupInfo.color),
        appBar: AppBar(
            backgroundColor: getGroupColor(widget.groupInfo.color),
            title: Center(
              child: Text(
                "Top users of $groupName",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: const TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: const Color.fromRGBO(248, 237, 227, 1),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: const [
              SizedBox(width: 40.0),
            ],
          ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 900,
              height: 570,
              child: Column(children: [
                Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: getGroupColor(widget.groupInfo.color),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Ranking',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont(
                        'Inter',
                        textStyle: TextStyle(
                          color: Color.fromRGBO(248, 237, 227, 1.0),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                buildUserWidget(300, 1, topUsers[0], Colors.amber),
                buildUserWidget(275, 2, topUsers[1], Color.fromRGBO(214, 214, 214, 1)),
                buildUserWidget(250, 3, topUsers[2], Color.fromRGBO(205, 127, 50, 1)),
                buildUserWidget(225, 4, topUsers[3], Colors.grey.shade400),
                buildUserWidget(225, 5, topUsers[4], Colors.grey.shade400),
                buildUserWidget(225, 6, topUsers[3], Colors.grey.shade400),
                buildUserWidget(225, 7, topUsers[3], Colors.grey.shade400),
                buildUserWidget(225, 8, topUsers[3], Colors.grey.shade400),
                buildUserWidget(225, 9, topUsers[3], Colors.grey.shade400),
                buildUserWidget(225, 10, topUsers[3], Colors.grey.shade400),

              ]),
            ),
          ),
        ),
      ),
    );
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
            Color.fromRGBO(248, 237, 227, 0.8),
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
                          fontSize: 18,
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
                        fontSize: 18,
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
                      fontSize: 18,
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
                  fontSize: 18,
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
