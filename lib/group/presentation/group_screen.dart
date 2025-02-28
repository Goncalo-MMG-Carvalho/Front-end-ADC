import 'dart:async';
import 'dart:convert';

import 'package:adc_handson_session/AppPage/application/admin_auth.dart';
import 'package:adc_handson_session/AppPage/presentation/appPage_screen.dart';
import 'package:adc_handson_session/Utils/firebaseUtils.dart';
import 'package:adc_handson_session/Utils/groupUtils.dart';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/group/application/auth.dart';
import 'package:adc_handson_session/group/presentation/closedPolls_screen.dart';
import 'package:adc_handson_session/group/presentation/onGoingPolls_screen.dart';
import 'package:adc_handson_session/group/presentation/pollsToVote_screen.dart';
import 'package:adc_handson_session/group/presentation/requests_screen.dart';
import 'package:adc_handson_session/group/presentation/top_users_screen.dart';
import 'package:adc_handson_session/login/domain/ClosedPoll.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../AppPage/application/auth.dart';

import '../../exceptions/invalid_token.dart';
import '../../login/data/users_local_storage.dart';
import '../../login/domain/Group.dart';
import '../../login/domain/Messages.dart';
import '../../login/domain/OpenPolls.dart';
import '../../login/domain/PollToVote.dart';
import '../../login/domain/Requests.dart';
import '../dialogs/group_dialogs.dart';
import 'group_statistics_screen.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import '../../Utils/constants.dart' as constants;

const String SYSTEM_ADMIN = constants.SYSTEM_ADMIN;
const String SYSTEM_ADMIN_MANAGER = constants.SYSTEM_ADMIN_MANAGER;
const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

const double _scrollThreshold = 2000.0;

class GroupScreen extends StatefulWidget {
  final GroupInfo groupInfo;

  const GroupScreen({required this.groupInfo, super.key});

  @override
  State<GroupScreen> createState() => _GroupScreen();
}

class _GroupScreen extends State<GroupScreen> {
  AdminAuthentication adminAuth = AdminAuthentication();
  AuthenticationGroup auth = AuthenticationGroup();
  AuthenticationAppPage authApp = AuthenticationAppPage();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final ScrollController _scrollController = ScrollController();
  final AutoScrollController _autoScrollController = AutoScrollController();
  final StreamController<List<Message>> _streamController =
  StreamController<List<Message>>();

  late TextEditingController messageController = TextEditingController();

  bool _isLoading = true;
  bool _isDisposed = false;
  bool _hasMore = true;
  Timer? _debounceTimer;

  final int _pageSize = 20;

  List<Message> _messages = [];
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
    super.initState();
    getGroup();

    _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida: ${message.data}');
      String type = message.data['type'];

      if (type == 'message') {
        Message message1 = Message.fromJson(message.data);
        if (!_isDisposed && mounted) {
          setState(() {
            _messages.add(message1);
          });
        }
        groupUtils().addMessageToGroup(message1);
      }
      if (type == 'update') {
        Group g =
        Group.fromJson2(jsonDecode(message.data["GROUP"])['properties']);
        if (!_isDisposed && mounted) {
          setState(() {
            group = g;
          });
        }
        if (!kIsWeb) {
          LocalDB db = LocalDB(localDatabaseName);
          db.addGroup(g);
        }
      }
      if (type == 'delete') {
        if (!kIsWeb) {
          LocalDB db = LocalDB(localDatabaseName);
          db.deleteGroup(message.data['group_name']);
          db.removeGroupInfoByUsername(
              message.data['group_name'], usernameLog!);
        }

        if (message.data['group_name'] == group!.groupName) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  AppPage(initialTabIndex: 1)),
          );
        }
      }
      if (type == 'responsePoll') {
        if (!kIsWeb) {
          updatePoll(message.data['pollId'], message.data['index']);
        }
      }
      if (type == 'closedPoll') {
        print("IMPORTANTE CLOSED POLL ${message.data}");
        Closedpoll p = Closedpoll.fromJson(message.data);
        if (!kIsWeb) {
          LocalDB db = LocalDB(localDatabaseName);
          db.addClosedPoll(p);
          db.removePollsToVoteById(p.pollId);
        }
      }
      if (type == 'pollToVote') {
        PolltoVote p = PolltoVote.fromJson(jsonDecode(message.data["POLL"]));
        if (!kIsWeb) {
          LocalDB db = LocalDB(localDatabaseName);
          db.addPullToVote(p);
        }
      }
      if(type == 'request') {
        Request r = Request.fromJson(message.data);
        if (!kIsWeb) {
          LocalDB db = LocalDB(localDatabaseName);
          db.addRequest(r);
        }
      }
      if(type == 'request_delete') {
        if (!kIsWeb) {
          LocalDB db = LocalDB(localDatabaseName);
          db.deleteRequest(message.data['requestId']);
        }
      }

    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    _scrollController.addListener(_scrollListener);
  }

  void _loadInitialMessages() async {
    LocalDB db = LocalDB(localDatabaseName);
    final List<Message> initialMessages = await db.queryMessages(
      widget.groupInfo.groupName,
      _pageSize,
      0,
    );

    setState(() {
      _messages.addAll(initialMessages);
      if (initialMessages.length < _pageSize) {
        _hasMore = false;
      }
    });
  }

  Future<void> updatePoll(String pollId, String index) async {
    LocalDB db = LocalDB(localDatabaseName);
    OpenPoll op = await db.getOpenPoll(pollId);

    int updatesVotes = int.parse(op.totalVotes) + 1;

    op.totalVotes = updatesVotes.toString();

    int i = int.parse(index);

    List<String> elements = op.fields.split('|');
    List<String> parts = elements[i].split(':');
    int value = int.parse(parts[1]) + 1;
    elements[i] = '${parts[0]}:$value';
    String updatedFields = elements.join('|');

    op.fields = updatedFields;
    db.addOpenPoll(op);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollListener() {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100.0 &&
          !_isLoading &&
          _hasMore) {
        _loadMoreMessages();
      }
    });
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
    try {
      await getUserNameAndRole();
      Group? groupR = await auth.getGroup(widget.groupInfo.groupName);
      setState(() {
        group = groupR;
      });
      createUsersList();
      _loadInitialMessages();
      await isAdmin(group!);
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
    _streamController.close();
    _scrollController.dispose();
    _autoScrollController.dispose();
    _isDisposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMoreMessages() async {
    if (!_hasMore || _isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      LocalDB db = LocalDB(localDatabaseName);
      final List<Message> newMessages = await db.queryMessages(
          widget.groupInfo.groupName, _pageSize, _messages.length);

      setState(() {
        _messages.addAll(newMessages);
        if (newMessages.length < _pageSize) {
          _hasMore = false;
        }
      });
    } catch (e) {
      print('Error loading more messages: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void sendMessage(String message, Group group) {
    try{
      messageController.text = "";
      auth.sendMessage(message, group);
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
      home: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
        length: 2,
        child: Scaffold(
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
          body: SafeArea(
            child: Column(
              children: [
                Expanded(child: messages()),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  color: const Color.fromRGBO(248, 237, 227, 1),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          cursorColor:
                          const Color.fromRGBO(121, 135, 119, 1),
                          controller: messageController,
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            backgroundColor:
                            Color.fromRGBO(248, 237, 227, 1),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            hintStyle: GoogleFonts.getFont('Inter',
                                textStyle: TextStyle(
                                    fontSize: 20.0,
                                    color: groupUtils().getGroupColor(
                                        widget.groupInfo.color))),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: groupUtils()
                            .getGroupColor(widget.groupInfo.color),
                        child: IconButton(
                          icon: const Icon(Icons.send,
                              color: Color.fromRGBO(248, 237, 227, 1)),
                          onPressed: () {
                            if (messageController.text != "") {
                              sendMessage(messageController.text, group!);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
        ),
      ),
    );
  }

  Widget messages() {
    if (isSysAdminManager() || isSysAdminManager()) {
      return const Center(
        child: Text(
          "For our users' privacy, system admins can't have access to the group messages",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + (_hasMore ? 1 : 0),
        reverse: true,
        itemBuilder: (context, index) {
          if (index == _messages.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return Container(
            padding: const EdgeInsets.all(15.0),
            alignment: _messages[index].sender == usernameLog
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: _messages[index].sender == usernameLog
                    ? groupUtils().getGroupColor(group!.color).withOpacity(0.8)
                    : groupUtils().getGroupColor(group!.color),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _messages[index].sender,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(_messages[index].message),
                  const SizedBox(height: 4.0),
                  Text(
                    groupUtils().formatTimestamp(_messages[index].timestamp),
                    style:
                    const TextStyle(fontSize: 12.0, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget menu() {
    return ListView(padding: EdgeInsets.zero, children: [
      Container(
        height: 100, // Set your desired height here
        decoration: BoxDecoration(
            color: groupUtils().getGroupColor(widget.groupInfo.color)),
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
      if (showUserList)
        SizedBox(
          height: MediaQuery.of(context).size.height - 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListView(
                  padding: EdgeInsets.zero,
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
          height: MediaQuery.of(context).size.height - 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _buildMainMenu(),
                ),
              ),
              if (!isSysAdminManager() && !isSysAdmin() && usernameLog != owner)
                ListTile(
                  leading: const Icon(Icons.exit_to_app), // Icon for LeaveGroup
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
                  leading: const Icon(Icons.exit_to_app), // Icon for LeaveGroup
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
                  showTransiteUserConfirmation(
                      username, true); // Close the dialog
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

  List<Widget> _buildMainMenu() {
    return [
      ListTile(
        leading: const Icon(Icons.people), // Icon for Users
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
      /*ListTile(
        leading: const Icon(Icons.star), // Icon for Top users
        title: Text(
          'Top users',
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
              builder: (context) => TopUsersScreen(groupInfo: widget.groupInfo),
            ),
          );
        },
      ),*/
      ListTile(
        leading: const Icon(Icons.bar_chart), // Icon for Group statistics
        title: Text(
          'Group statistics',
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
              builder: (context) => GroupStatisticsPage(group: group),
            ),
          );
        },
      ),
      if (usernameLog == owner)
        ListTile(
          leading: const Icon(Icons.poll), // Icon for LeaveGroup
          title: Text(
            'Create Poll',
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
            showCreatePoll(context);
          },
        ),
      if (usernameLog == owner)
        ListTile(
          leading: const Icon(Icons.poll_outlined), // Icon for LeaveGroup
          title: Text(
            'On Going Poll',
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
                builder: (context) => OnGoingPollsPage(group: group),
              ),
            );
          },
        ),
      //TODO AINDA A MUDAR
      ListTile(
        leading: const Icon(Icons.poll_rounded), // Icon for LeaveGroup
        title: Text(
          "Poll's Results",
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
              builder: (context) => ClosedPollsPage(group: group),
            ),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.how_to_vote), // Icon for LeaveGroup
        title: Text(
          "Votes",
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
              builder: (context) => VotePage(group: group),
            ),
          );
        },
      ),
      if (canSeeRequests())
        ListTile(
          leading: const Icon(Icons.mail), // Icon for Item 2
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
    try{
      bool res = await AuthenticationGroup().leaveGroup(group);

      if (res) {
        if(mounted) {
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
    try{
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
    try {
      print("GROUP NO REMOVE USER: $group");

      bool res = await AuthenticationGroup().removeUser(group!, username);

      if (res) {
        _userRemovedDialog(username);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GroupScreen(
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
    try{
      bool res = await AuthenticationGroup().roleTransition(group!, userToTransition, isPromotion);

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

  createPoll(String title, List<String> fields, String groups) async {
    try{
      List<String> groupsTo = [];
      if(groups == "This"){
        groupsTo.add(group!.groupName);
      }else{
        LocalDB db = LocalDB(localDatabaseName);
        List<String> g = await db.getGroupsOfOwner(usernameLog!);
        print("LISTA DOS GRUPOS DO OWNER + $g");
        groupsTo = g;
      }
      String groupsToSend = groupsTo.join("|");
      print("GROUPS TO SEND $groupsToSend");
      print("FIELDSSSSS $fields");

      bool res = await AuthenticationGroup().createPoll(title, fields, groupsToSend);

      if(res){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
              title:  Text("Poll Created Successfully!",
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: TextStyle(
                    color: groupUtils().getGroupColor(widget.groupInfo.color),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Text("Your poll has been created successfully.",
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK",
                    style: GoogleFonts.getFont(
                      'Inter',
                      textStyle:  TextStyle(
                        color: groupUtils().getGroupColor(widget.groupInfo.color),
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
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  void showCreatePoll(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    int numberOfOptions = 2;
    String scope = 'This';

    List<TextEditingController> optionControllers = [];
    List<Widget> optionFields = [];

    for (int i = 0; i < numberOfOptions; i++) {
      TextEditingController controller = TextEditingController();
      optionControllers.add(controller);
      optionFields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Option ${i + 1}',
              labelStyle: GoogleFonts.getFont(
                'Inter',
                textStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: groupUtils().getGroupColor(widget.groupInfo.color),
                    width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: groupUtils().getGroupColor(widget.groupInfo.color),
                    width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Create Poll',
                style: GoogleFonts.getFont(
                  'Inter',
                  textStyle: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Poll's title",
                        labelStyle: GoogleFonts.getFont(
                          'Inter',
                          textStyle: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: groupUtils()
                                  .getGroupColor(widget.groupInfo.color),
                              width: 2.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: groupUtils()
                                  .getGroupColor(widget.groupInfo.color),
                              width: 2.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (group!.type)
                      DropdownButton(
                        value: scope,
                        items: const [
                          DropdownMenuItem(
                              child: Text('Only This Group'), value: 'This'),
                          DropdownMenuItem(
                              child: Text('All Your Groups'), value: 'All'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            scope = value!;
                          });
                          print("##################scope: $scope");
                        },
                      ),
                    const SizedBox(height: 10),
                    DropdownButton<int>(
                      dropdownColor: Color.fromRGBO(248, 237, 227, 1),
                      value: numberOfOptions,
                      items: [
                        DropdownMenuItem(
                            child: Text(
                              '2',
                              style: GoogleFonts.getFont(
                                'Inter',
                                textStyle: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            value: 2),
                        DropdownMenuItem(
                            child: Text(
                              '3',
                              style: GoogleFonts.getFont(
                                'Inter',
                                textStyle: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            value: 3),
                        DropdownMenuItem(
                            child: Text(
                              '4',
                              style: GoogleFonts.getFont(
                                'Inter',
                                textStyle: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            value: 4),
                        DropdownMenuItem(
                            child: Text(
                              '5',
                              style: GoogleFonts.getFont(
                                'Inter',
                                textStyle: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            value: 5),
                      ],
                      onChanged: (value) {
                        setState(() {
                          numberOfOptions = value!;
                          optionControllers.clear();
                          optionFields.clear();
                          for (int i = 0; i < numberOfOptions; i++) {
                            TextEditingController controller =
                            TextEditingController();
                            optionControllers.add(controller);
                            optionFields.add(
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 10.0),
                                child: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: 'Option ${i + 1}',
                                    labelStyle: GoogleFonts.getFont(
                                      'Inter',
                                      textStyle: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: groupUtils().getGroupColor(
                                              widget.groupInfo.color),
                                          width: 2.0),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: groupUtils().getGroupColor(
                                              widget.groupInfo.color),
                                          width: 2.0),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: optionFields,
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Create',
                    style: GoogleFonts.getFont(
                      'Inter',
                      textStyle: const TextStyle(
                        color: Color.fromRGBO(248, 237, 227, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    List<String> options = optionControllers
                        .map((controller) => controller.text)
                        .toList();
                    createPoll(titleController.text, options, scope);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
