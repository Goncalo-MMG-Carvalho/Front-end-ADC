import 'package:flutter/widgets.dart';
import 'package:adc_handson_session/login/domain/User.dart';
import 'package:adc_handson_session/login/domain/Group.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String localDatabaseName = "app.db";

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
      await txn.execute('CREATE TABLE users (username TEXT PRIMARY KEY, token TEXT)');
      await txn.execute('CREATE TABLE groups (groupCode TEXT PRIMARY KEY, groupName TEXT, owner TEXT, color TEXT)');
    });
  }

  // TODO: Draft function. You should adapt after extending the user table
  // with its last position
  Future<void> addUser(final User u) async {
    // The `conflictAlgorithm` is used to select the strategy to be used in case
    // the user already exists. In this case, replace any previous data.
    await db.insert(
      'users',
      u.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(u.toString());

  }

  Future<void> addGroup(final Group g) async {

    await db.insert(
      'groups',
      g.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(g.toString());

  }

  Future<String> getUsername() async {
    final db = await initDB();
    List<Map<String, Object?>> usernameQuery = await db.rawQuery('SELECT username FROM users');
    final username = usernameQuery.first.values.first.toString();
    print(username);
    return username;
  }

  Future<String> getToken() async {
    final db = await initDB();
    List<Map<String, Object?>> usernameQuery = await db.rawQuery('SELECT token FROM users');
    final token = usernameQuery.first.values.first.toString();
    print(token);
    return token;
  }

  Future<List<Map<String, Object?>>> getGroups() async {
    final db = await initDB();
    List<Map<String, Object?>> groups = await db.rawQuery('SELECT * FROM groups');
    print(groups);
    return groups;
  }


  Future<int> countUsers() async {
    final db = await initDB();
    List<Map> list = await db.rawQuery('SELECT * FROM users');
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

  //É PREFERIVEL FAZER DELETE DA DB EM VEZ DE DAR SO DROP TABLE
 // Future<void> restartDB() async {
 //   final db = await initDB();
 //   await db.execute('DROP TABLE IF EXISTS users');
 // }
}
