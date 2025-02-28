import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../login/data/users_local_storage.dart';
import '../../exceptions/invalid_token.dart';
import '../../login/domain/Group.dart';
import '../../login/domain/Requests.dart';
import '../application/auth.dart';
import 'group_screen.dart';
import '../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

class GroupRequestsPage extends StatefulWidget {
  final Group? group;

  const GroupRequestsPage({required this.group, super.key});

  @override
  State<GroupRequestsPage> createState() => _GroupRequestsPage();
}

class _GroupRequestsPage extends State<GroupRequestsPage> {

  List<Request> requests = [];

  String groupName = "";

  AuthenticationGroup authGroup = AuthenticationGroup();

  userUtils uUtils = userUtils();

  String? username;

  bool isLoading = true;

  Color getGroupColor(String color) {
    int colorValue = int.parse(color, radix: 16);
    return Color(colorValue);
  }

  @override
  void initState() {
    super.initState();
    groupName = widget.group!.groupName;
    getGroupRequests(groupName);

  }

  Future<void> getUsername() async {
    String? res = await userUtils().getUsername();
    setState(() {
      username = res;
    });
  }

  void getGroupRequests(String groupName) async {
    getUsername();
    LocalDB db = LocalDB(localDatabaseName);
    List<Request> req = await db.getGroupRequests(groupName);

    setState(() {
      requests = req;
      isLoading = false;
    });

  }

  Future<void> acceptRequest(String request, String id) async {
    try{
      setState(() {
        isLoading = true;
      });
      print("USER NO REQUEST: $request");
      await authGroup.requestResponse(groupName, request, id, true);
      setState(() {
        requests.removeWhere((request) => request.id == id);
        isLoading = false;
      });

      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.deleteRequest(id);
      }

      //getGroupRequests(groupName);
      print('Accepted: $request');
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  Future<void> declineRequest(String request, String id) async {
    try{
      setState(() {
        isLoading = true;
      });
      print("USER NO REQUEST: $request");
      await authGroup.requestResponse(groupName, request, id,  false);
      setState(() {
        requests.removeWhere((request) => request.id == id);
        isLoading = false;
      });

      if (!kIsWeb) {
        LocalDB db = LocalDB(localDatabaseName);
        db.deleteRequest(id);
      }
      //getGroupRequests(groupName);
      print('Declined: $request');
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
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
                "$groupName's requests to join",
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Arial',
                  color: Colors.white,
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
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              :Center(
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                Request request = requests[index];
                return Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.username,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => acceptRequest(request.username, request.id),
                              child: const Text(
                                'Accept',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            TextButton(
                              onPressed: () => declineRequest(request.username, request.id),
                              child: const Text(
                                'Decline',
                                style: TextStyle(color: Colors.red),
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
          )

      ),
    );
  }


}