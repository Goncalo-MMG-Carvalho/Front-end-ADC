import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../Utils/constants.dart' as constants;

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

class Group {
  final int id; // Auto-incremented primary key
  final String groupName;
  final String companyName;
  final int color; // Store color as integer

  Group({
    required this.id,
    required this.groupName,
    required this.companyName,
    required this.color,
  });

  // Convert a Group object into a Map object for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupName': groupName,
      'companyName': companyName,
      'color': color,
    };
  }

  // Convert a Map object from the database into a Group object
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      groupName: map['groupName'],
      companyName: map['companyName'],
      color: map['color'],
    );
  }

  // Method to create a copy of the Group object with new values
  Group copyWith({
    int? id,
    String? groupName,
    String? companyName,
    int? color,
  }) {
    return Group(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      companyName: companyName ?? this.companyName,
      color: color ?? this.color,
    );
  }
}

class LocalDB {
  late final String databaseName;
  late Database db;

  LocalDB(this.databaseName);

  Future<Database> initDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    String path = await getDatabasesPath();

    db = await openDatabase(
      join(path, databaseName),
      onCreate: _onCreate,
      version: 1,
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupName TEXT,
        companyName TEXT,
        color INTEGER
      )
    ''');
  }

  Future<void> addGroup(Group group) async {
    await db.insert(
      'groups',
      group.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Group>> getAllGroups() async {
    final List<Map<String, dynamic>> maps = await db.query('groups');

    return List.generate(maps.length, (i) {
      return Group(
        id: maps[i]['id'],
        groupName: maps[i]['groupName'],
        companyName: maps[i]['companyName'],
        color: maps[i]['color'],
      );
    });
  }

  Future<void> updateGroup(Group group) async {
    await db.update(
      'groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<void> deleteGroup(int id) async {
    await db.delete(
      'groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> closeDB() async {
    await db.close();
  }
}

void main() async {
  final localDB = LocalDB(localDatabaseName);
  await localDB.initDB();

  Group newGroup = Group(
    id: 1,
    groupName: 'Flutter Enthusiasts',
    companyName: 'XYZ Inc.',
    color: 0xFF42A5F5,
  );
  await localDB.addGroup(newGroup);

  // Retrieving all groups
  List<Group> groups = await localDB.getAllGroups();
  for (var group in groups) {
    print('Group: ${group.groupName}, Company: ${group.companyName}');
  }

  // Updating a group
  Group updatedGroup = groups.first.copyWith(companyName: 'Updated Company');
  await localDB.updateGroup(updatedGroup);

  // Deleting a group
  await localDB.deleteGroup(updatedGroup.id);

  // Closing the database
  await localDB.closeDB();
}
