import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../group/application/auth.dart';
import '../../Utils/userUtils.dart';
import '../../login/data/users_local_storage.dart';
import '../../login/domain/ClosedPoll.dart';
import '../../login/domain/Group.dart';
import '../../login/domain/GroupInfo.dart';
import '../../login/domain/OpenPolls.dart';
import 'group_screen.dart';
import '../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

class ClosedPollsPage extends StatefulWidget {
  final Group? group;

  const ClosedPollsPage({super.key, required this.group});
  @override
  State<ClosedPollsPage> createState() => _ClosedPollsPage();
}


class _ClosedPollsPage extends State<ClosedPollsPage> with SingleTickerProviderStateMixin {

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
    getClosedPolls(groupName);
  }

  Future<void> getClosedPolls(String groupName) async {
    await getUsername();
    if(!kIsWeb){
      LocalDB db = LocalDB(localDatabaseName);
      var op = await db.getClosedPolls(groupName);
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
              "$groupName's Polls Results",
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
              Closedpoll poll = polls[index];
              List<String> fields = poll.fields.split('|');
              int totalVotes = int.parse(poll.totalVotes);

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


}