import 'package:adc_handson_session/login/domain/PollToVote.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../exceptions/invalid_token.dart';
import '../../group/application/auth.dart';
import '../../Utils/userUtils.dart';
import '../../login/data/users_local_storage.dart';
import '../../login/domain/Group.dart';
import '../../login/domain/GroupInfo.dart';
import '../../login/domain/OpenPolls.dart';
import 'group_screen.dart';
import '../../Utils/constants.dart' as constants;


const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

class VotePage extends StatefulWidget {
  Group? group;

  VotePage({super.key, required this.group});

  @override
  State<VotePage> createState() => _VotePage();
}

class _VotePage extends State<VotePage> with SingleTickerProviderStateMixin {
  var pollsToVote = [];

  String groupName = "";

  userUtils uUtils = userUtils();

  String? username;

  Color getGroupColor(String color) {
    int colorValue = int.parse(color, radix: 16);
    return Color(colorValue);
  }

  @override
  void initState() {
    super.initState();
    groupName = widget.group!.groupName;
    getPollsToVote(groupName);
  }

  Future<void> getPollsToVote(String groupName) async {
    await getUsername();
    if (!kIsWeb) {
      LocalDB db = LocalDB(localDatabaseName);
      var op = await db.getPullsToVote(groupName);
      List<PolltoVote> list = [];
      for(var s in op){
        list.add(PolltoVote.fromMap(s));
      }
      setState(() {
        pollsToVote = list;
      });
    }
  }

  Future<void> getUsername() async {
    String? res = await userUtils().getUsername();
    setState(() {
      username = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Life',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: getGroupColor(widget.group!.color),
          title: Center(
            child: Text(
              "$groupName's Polls",
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GroupScreen(groupInfo: GroupInfo(username: username!, groupName: groupName, color: widget.group!.color),))
              );
            },
          ),
          actions: const [
            SizedBox(width: 40.0),
          ],
        ),
        backgroundColor: getGroupColor(widget.group!.color),
        body: Center(
          child: ListView.builder(
            itemCount: pollsToVote.length,
            itemBuilder: (context, index) {
              PolltoVote poll = pollsToVote[index];
              List<String> fields = poll.fields.split('|');

              return Card(
                color: Color.fromRGBO(248, 237, 227, 1),
                margin: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        poll.title,
                        style: GoogleFonts.getFont(
                          'Inter',
                          textStyle: TextStyle(
                            color: getGroupColor(widget.group!.color),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ),
                      ...fields.map((field) {
                        int index = fields.indexOf(field);
                        return ElevatedButton(
                          style: TextButton.styleFrom(
                              backgroundColor: getGroupColor(widget.group!.color),
                          ),
                          onPressed: () async {
                            bool? confirmed = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                                  title: Text('Confirm Vote',
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      textStyle: TextStyle(
                                        color: getGroupColor(widget.group!.color),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  content: Text('Are you sure you want to vote on "$field"?',
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
                                            backgroundColor: getGroupColor(widget.group!.color)
                                        ),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child:  Text('Cancel',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      )
                                    ),
                                    TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor: getGroupColor(widget.group!.color)
                                        ),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child:  Text('Confirm',
                                        style: GoogleFonts.getFont(
                                          'Inter',
                                          textStyle: const TextStyle(
                                            color: Color.fromRGBO(248, 237, 227, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      )
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed == true) {
                              await castVote(context, poll, index.toString());
                            }
                          },
                          child: Center(
                          child: Text(
                            field,
                            style: GoogleFonts.getFont(
                              'Inter',
                              textStyle: TextStyle(
                                color: Color.fromRGBO(248, 237, 227, 1),
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                height: 1.5,
                              ),
                            ),
                          ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> castVote(BuildContext context, PolltoVote poll, String field) async {
    try {
      bool res = await AuthenticationGroup().castVote(poll.pollId, field);

      if (res) {
        _showAlertDialog(context, "Vote Sent", "Your vote has been successfully sent.");
      } else {
        _showAlertDialog(context, "Poll Closed", "The poll is already closed.");
      }

      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.removePollsToVote(poll);
        setState(() {
          pollsToVote.remove(poll);
        });
      }
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title: Text(title,
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
          content: Text(message,
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
              child: Text("OK",
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
  }
}