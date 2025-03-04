import 'package:adc_handson_session/login/domain/ClosedPoll.dart';
import 'package:adc_handson_session/login/domain/Messages.dart';
import 'package:flutter/widgets.dart';
import 'package:adc_handson_session/login/domain/UserToken.dart';
import 'package:adc_handson_session/login/domain/Group.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/OpenPolls.dart';
import '../domain/PollToVote.dart';
import '../domain/Requests.dart';
import '../domain/User.dart';
import '../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

class LocalDB {
  late final String databaseName;
  late Database db;

  LocalDB(this.databaseName);

  Future<Database> initDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    print("ENTRAMOS NO INIT");
    String path = await getDatabasesPath();

    db = await openDatabase(
      join(path, databaseName),
      onCreate: _onCreate,
      version: 1,
    );

    return db;
  }


  Future<void> _onCreate(Database db, int version) async {
    print('onCreate');
    await db.transaction((txn) async {
      await txn.execute('CREATE TABLE tokens (username TEXT PRIMARY KEY, token TEXT)');
      await txn.execute('CREATE TABLE requests (id TEXT PRIMARY KEY, username TEXT, groupName TEXT)');
      await txn.execute('CREATE TABLE IF NOT EXISTS openPolls (pollId TEXT PRIMARY KEY, title TEXT, fields TEXT, totalVotes TEXT, username TEXT, groups TEXT)');
      await txn.execute('CREATE TABLE closedPolls (pollId TEXT PRIMARY KEY, title TEXT, fields TEXT, totalVotes TEXT, groups TEXT)');
      await txn.execute('CREATE TABLE pollToVote (pollId TEXT PRIMARY KEY, title TEXT, fields TEXT, groups TEXT)');
      await txn.execute('CREATE TABLE groupsInfo (groupName TEXT PRIMARY KEY, username TEXT, color TEXT)');
      await txn.execute('CREATE TABLE messages (messageId TEXT PRIMARY KEY, sender TEXT, message TEXT, groupName TEXT, timestamp INTEGER)');
      await txn.execute('CREATE TABLE groups (groupName TEXT PRIMARY KEY, groupOwner TEXT, color TEXT, adminNames TEXT, access INTEGER, members TEXT, type INTEGER, averageFood TEXT, averageFuel TEXT, averageWater TEXT, averageElectricity TEXT, electricityCo2 TEXT, foodCo2 TEXT, fuelCo2 TEXT, waterCo2 TEXT, bottleCo2 TEXT, averageBottleWater TEXT, averageCo2 TEXT, averageTapWater TEXT, electricityValues TEXT, foodValues TEXT, fuelValues TEXT, bottleValues TEXT, tapCo2 TEXT, tapValues TEXT)');
      await txn.execute('CREATE TABLE users (username TEXT PRIMARY KEY, averagePoints TEXT, activationState INTEGER, age TEXT, creationTime INTEGER, email TEXT, energyConsumption TEXT, fuelType TEXT, name TEXT, password TEXT, role TEXT, userGroups TEXT, bottleConsumption TEXT, tapConsumption TEXT, energyCo2 TEXT, bottleCo2 TEXT, tapCo2 TEXT, fuelCo2 TEXT, averageCo2 TEXT, foodCo2 TEXT, energyHistory TEXT, energyPoints TEXT, foodHistory TEXT, foodPoints TEXT, fuelHistory TEXT, fuelPoints TEXT, waterHistory TEXT, waterPoints TEXT)');
    });
  }


  Future<void> addUserToken(final UserToken u) async {

    final db = await initDB();
    await db.insert(
      'tokens',
      u.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(u.toString());

  }

  Future<void> addOpenPoll(final OpenPoll p) async {

    final db = await initDB();
    await db.insert(
      'openPolls',
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(p.toString());

  }

  Future<void> addRequest(final Request r) async {

    final db = await initDB();
    await db.insert(
      'requests',
      r.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(r.toString());

  }

  Future<void> deleteRequest(final String id) async {

    final db = await initDB();
    await db.delete(
      'requests',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Removed: ${id.toString()}');

  }

  Future<List<Request>> getGroupRequests(String groupName) async {
    final db = await initDB();
    List<Map<String, Object?>> requests = await db.rawQuery("SELECT * FROM requests where groupName LIKE '$groupName'");
    List<Request> reqs = requests.map((group) => Request.fromMap(group)).toList();
    print(reqs);
    return reqs;
  }


  Future<void> addClosedPoll(final Closedpoll p) async {

    final db = await initDB();
    await db.insert(
      'closedPolls',
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(p.toString());

  }

  Future<void> addPullToVote(final PolltoVote p) async {

    final db = await initDB();
    await db.insert(
      'pollToVote',
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(p.toString());

  }

  Future<void> addMessage(final Message m) async {

    final db = await initDB();
    await db.insert(
      'messages',
      m.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(m.toString());

  }

  Future<void> addUser(final User u) async {

    final db = await initDB();
    await db.insert(
      'users',
      u.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(u.toString());

  }

  Future<void> addGroup(final Group g) async {
    final db = await initDB();
    await db.insert(
      'groups',
      g.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(g.toString());

  }

  Future<void> addGroupInfo(final GroupInfo gi) async {
    final db = await initDB();
    await db.insert(
      'groupsInfo',
      gi.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(gi.toString());

  }

  Future<void> removeOpenPoll(final String id) async {
    final db = await initDB();
    await db.delete(
      'openPolls',
      where: 'pollId = ?',
      whereArgs: [id],
    );
    print('Removed: ${id.toString()}');
  }

  Future<void> removeGroupInfo(final GroupInfo gi) async {
    final db = await initDB();
    await db.delete(
      'groupsInfo',
      where: 'groupName = ? AND username = ?',
      whereArgs: [gi.groupName, gi.username],
    );
    print('Removed: ${gi.toString()}');
  }

  Future<void> removeGroupInfoByUsername(String groupName, String username) async {
    final db = await initDB();
    await db.delete(
      'groupsInfo',
      where: 'groupName = ? AND username = ?',
      whereArgs: [groupName, username],
    );
    print('Removed: $groupName');
  }

  Future<void> removePollsToVote(final PolltoVote po) async {
    final db = await initDB();
    await db.delete(
      'pollToVote',
      where: 'pollId = ?',
      whereArgs: [po.pollId],
    );
    print('Removed: ${po.toString()}');
  }

  Future<void> removePollsToVoteById(final String id) async {
    final db = await initDB();
    await db.delete(
      'pollToVote',
      where: 'pollId = ?',
      whereArgs: [id],
    );
    print('Removed: $id');
  }


  Future<List<Message>> queryMessages(String groupName, int limit, int offset) async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'groupName = ?',
      whereArgs: [groupName],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    });
  }

  Future<String> getUsername() async {
    final db = await initDB();
    List<Map<String, Object?>> usernameQuery = await db.rawQuery('SELECT username FROM tokens');
    final username = usernameQuery.first.values.first.toString();
    print(username);
    return username;
  }

  Future<List<Map<String, Object?>>> getGroupMessages(String groupName) async {
    final db = await initDB();
    try {
      List<Map<String, Object?>> usernameQuery = await db.rawQuery("SELECT * FROM messages WHERE groupName LIKE '$groupName'");
      return usernameQuery;
    } catch (e) {
      print('Error retrieving messages: $e');
      return []; // Return an empty list or handle the error in another way
    }
  }

  Future<String> getToken() async {
    final db = await initDB();
    List<Map<String, Object?>> usernameQuery = await db.rawQuery('SELECT token FROM tokens');
    final token = usernameQuery.first.values.first.toString();
    print(token);
    return token;
  }

  Future<void> deleteToken() async {
    final db = await initDB();
    await db.rawDelete('DELETE FROM users');
    print('Token deleted');
  }

  Future<List<Map<String, Object?>>> getGroups() async {
    final db = await initDB();
    List<Map<String, Object?>> groups = await db.rawQuery('SELECT * FROM groups');
    print(groups);
    return groups;
  }

  Future<List<Map<String, Object?>>> getGroup(String groupName) async {
    final db = await initDB();
    List<Map<String, Object?>> groups = await db.rawQuery("SELECT * FROM groups where groupName LIKE '$groupName'");
    print(groups);
    return groups;
  }

  Future<OpenPoll> getOpenPoll(String pollId) async {
    final db = await initDB();
    List<Map<String, Object?>> polls = await db.rawQuery("SELECT * FROM openPolls where pollId LIKE '$pollId'");
    OpenPoll op = OpenPoll.fromMap(polls.first);
    print(polls);
    return op;
  }

  Future<List<OpenPoll>> getOpenUsersPolls(String username) async {
    final db = await initDB();
    List<Map<String, Object?>> polls = await db.rawQuery("SELECT * FROM openPolls WHERE username LIKE ?", [username]);
    print(polls);
    return polls.map((pollMap) => OpenPoll.fromMap(pollMap)).toList();
  }

  Future<List<Closedpoll>> getClosedPolls(String groupName) async {
    final db = await initDB();
    List<Map<String, Object?>> polls = await db.rawQuery("SELECT * FROM closedPolls");

    var res = polls.where((poll) {
      List<String> groups = poll['groups'].toString().split('|');
      return groups.contains(groupName);
    }).toList();

    return res.map((pollMap) => Closedpoll.fromMap(pollMap)).toList();
  }

  Future<List<Map<String, dynamic>>> getPullsToVote(String groupName) async {
    final db = await initDB();
    List<Map<String, Object?>> polls = await db.rawQuery("SELECT * FROM pollToVote");

    return polls.where((poll) {
      PolltoVote polls = PolltoVote.fromMap(poll);
      List<String> groups = polls.groups.toString().split('|');
      return groups.contains(groupName);
    }).toList();
  }

  Future<List<String>> getGroupsOfOwner(String username) async {
    final db = await initDB();
    List<Map<String, Object?>> groups = await db.rawQuery("SELECT groupName FROM groups where groupOwner LIKE '$username'");
    List<String> groupNames = groups.map((group) => group['groupName'] as String).toList();
    print(groupNames);
    return groupNames;
  }

  Future<void> deleteGroup(String groupName) async {
    final db = await initDB();
    await db.delete(
      'groups',
      where: 'groupName = ?',
      whereArgs: [groupName],
    );
    print('Group $groupName deleted successfully');
  }

  Future<List<Map<String, Object?>>> getUsers() async {
    final db = await initDB();
    List<Map<String, Object?>> users = await db.rawQuery('SELECT * FROM users');
    print(users);
    return users;
  }

  Future<List<Map<String, Object?>>> getGroupsInfo(username) async {
    final db = await initDB();
    List<Map<String, Object?>> groupsInfo = await db.rawQuery("SELECT * FROM groupsInfo WHERE username LIKE '$username'");
    print(groupsInfo);
    return groupsInfo;
  }

  Future<int> countGroupInfos() async {
    final db = await initDB();
    List<Map> list = await db.rawQuery('SELECT * FROM groupsInfo');
    print("Number of GroupsInfo: ${list.length}");

    return list.length;
  }

  Future<bool> groupExists(String groupName) async {
    final db = await initDB();
    List<Map> list = await db.rawQuery("SELECT groupName FROM groups where groupName LIKE '$groupName'");
    return list.isNotEmpty;
  }

  Future<int> countUsers() async {
    final db = await initDB();
    List<Map> list = await db.rawQuery('SELECT * FROM tokens');
    print("Number of users: ${list.length}");

    return list.length;
  }

  Future<void> listAllTables() async {
    final db = await initDB();
    final tables = await db.rawQuery('SELECT * FROM sqlite_master ORDER BY name;');
    print(tables);
  }

  Future<void> deleteDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    String path = await getDatabasesPath();
    await deleteDatabase(join(path, databaseName));
  }

  /*Future<void> deleteUsersAndTokensTables() async {
    final db = await initDB();

    // Verifica se as tabelas existem
    List<Map<String, Object?>> tableList = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table" AND name IN ("users", "tokens", "groups", "groupsInfo")');

    // Cria um set de tabelas existentes
    Set<String> existingTables = tableList.map((table) => table['name'].toString()).toSet();

    await db.transaction((txn) async {
      // Deleta registros apenas se a tabela existir
      if (existingTables.contains('users')) {
        await txn.delete('users');
      }
      if (existingTables.contains('tokens')) {
        await txn.delete('tokens');
      }
      if (existingTables.contains('groups')) {
        await txn.delete('groups');
      }
      if (existingTables.contains('groupsInfo')) {
        await txn.delete('groupsInfo');
      }
    });
    print('Tables users and tokens deleted');
  }*/

  Future<void> deleteUsersAndTokensTables() async {
    final db = await initDB();

    // Verifica se as tabelas existem
    List<Map<String, Object?>> tableList = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table" AND name IN ("users", "tokens", "groups", "groupsInfo")');

    // Cria um set de tabelas existentes
    Set<String> existingTables = tableList.map((table) => table['name'].toString()).toSet();

    await db.transaction((txn) async {
      // Deleta registros apenas se a tabela existir
      if (existingTables.contains('users')) {
        await txn.delete('users');
      }
      if (existingTables.contains('tokens')) {
        await txn.delete('tokens');
      }
      if (existingTables.contains('groups')) {
        await txn.delete('groups');
      }
      if (existingTables.contains('groupsInfo')) {
        await txn.delete('groupsInfo');
      }
    //  await txn.delete('openPolls');
    //   await txn.delete('closedPolls');
    //  await txn.delete('pollToVote');
    });

    print('Tables users, tokens, groups, and groupsInfo deleted');
  }


}
