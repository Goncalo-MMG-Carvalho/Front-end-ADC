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

class OnGoingPollsPage extends StatefulWidget {
  Group? group;

  OnGoingPollsPage({super.key, required this.group});
  @override
  State<OnGoingPollsPage> createState() => _OnGoingPollsPage();
}


class _OnGoingPollsPage extends State<OnGoingPollsPage> with SingleTickerProviderStateMixin {

  var polls = [];

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
    getOnGoingPolls(groupName);
  }

  Future<void> getOnGoingPolls(String groupName) async {
    await getUsername();
    if(!kIsWeb){
      LocalDB db = LocalDB(localDatabaseName);
      var op = await db.getOpenUsersPolls(username!);
      setState(() {
        polls = op;
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
              "$groupName's On Going Polls",
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
            itemCount: polls.length,
            itemBuilder: (context, index) {
              OpenPoll poll = polls[index];
              List<String> fields = poll.fields.split('|');
              int totalVotes = int.parse(poll.totalVotes);

              for (String field in fields) {
                List<String> parts = field.split(':');
              }

              return Card(
                color: Color.fromRGBO(248, 237, 227, 1),
                margin: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                      SizedBox(height: 10),
                      ...fields.map((field) {
                        List<String> parts = field.split(':');
                        String fieldName = parts[0];
                        int votes = int.parse(parts[1]);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${fieldName} - ',
                              style: GoogleFonts.getFont(
                                'Inter',
                                textStyle: TextStyle(
                                  color: getGroupColor(widget.group!.color),
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            Text('$votes votes (${(votes / totalVotes * 100).toStringAsFixed(2)}%)',
                              style: GoogleFonts.getFont(
                                'Inter',
                                textStyle: TextStyle(
                                  color: getGroupColor(widget.group!.color),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      SizedBox(height: 10),
                      Text('Total votes: $totalVotes',
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: getGroupColor(widget.group!.color)
                            ),
                            onPressed: () => endPoll(poll),
                            child:  Text(
                              'End Poll',
                              style: GoogleFonts.getFont(
                                'Inter',
                                textStyle: const TextStyle(
                                  color: Color.fromRGBO(248, 237, 227, 1),
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  endPoll(OpenPoll poll) async {
    try {
      bool res = await AuthenticationGroup().endPoll(poll);

      if (res) {
        setState(() {
          polls.remove(poll);
        });
      }

      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.removeOpenPoll(poll.pollId);
      }
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }


}