import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../login/data/users_local_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:localstorage/localstorage.dart';

import '../login/domain/User.dart';
import '../../Utils/constants.dart' as constants;
import '../login/presentation/login_screen.dart';

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

const String SYSTEM_ADMIN = constants.SYSTEM_ADMIN;
const String SYSTEM_MANAGER = constants.SYSTEM_ADMIN_MANAGER;

class userUtils {

  Future<String?> getToken() async {
    String? token;
    if (kIsWeb) {
      await initLocalStorage();
      WidgetsFlutterBinding.ensureInitialized();
      token = localStorage.getItem("token");
    } else {
      LocalDB db = LocalDB(localDatabaseName);
      token = await db.getToken();
    }
    return token;
  }

  Future<String?> getUsername() async {
    String? token = await getToken();
    return token?.split(".")[0];
  }

  Future<String?> getUserRole() async {
    String? token = await getToken();
    return token?.split(".")[2];
  }

  Future<User> getUser() async {
    User user;

    if(kIsWeb){
      await initLocalStorage();
      WidgetsFlutterBinding.ensureInitialized();
      final userjson = localStorage.getItem("user");
      print(userjson);
      user = User.fromJsonLocalStorage(jsonDecode(userjson!));

    } else {
      LocalDB db = LocalDB(localDatabaseName);
      final userMap = await db.getUsers();
      print("USER MAP$userMap");
      user = User.fromMap(userMap.first);
      print("USER: $user");
    }

    return user;
  }

  Future<void> addUser(User user) async {
    if (kIsWeb) {
      await initLocalStorage();
      WidgetsFlutterBinding.ensureInitialized();
      localStorage.setItem('user', jsonEncode(user.toJson()));
    } else {
      LocalDB db = LocalDB(localDatabaseName);
      //FAZ MAIS SENTIDO REMOVER A TABLE DOS USERS QUANDO É FEITO OUTRO LOGIN OU QUANDO E INICIADA A APP NO MAIS DART?
      //TODO AINDA SO PARA TESTES TEMOS A BASE DE DADOS A RENICIAR
      //await db.initDB();
      await db.addUser(user);
      print("INICIOU");
      await db.getUsers();
    }
  }

  Future<User> getUserInfo() async {
    User? user;
    if(kIsWeb){
      await initLocalStorage();
      WidgetsFlutterBinding.ensureInitialized();
      final userjson = localStorage.getItem("user");
      print(userjson);
      User? u = User.fromJsonLocalStorage(jsonDecode(userjson!));
      user = u;

    } else {
      LocalDB db = LocalDB(localDatabaseName);
      final userMap = await db.getUsers();
      User? user1 = User.fromMap(userMap.first);
      print(user);

      user = user1;
    }
    return user;
  }

  Future<bool> isAdmin() async {
    String? role = await getUserRole();
    return role == SYSTEM_ADMIN || role == SYSTEM_MANAGER;
  }

  Future<bool> isSysAdmin() async {
    String? role = await getUserRole();
    return role == SYSTEM_ADMIN;
  }

  Future<bool> isSysAdminManager() async {
    String? role = await getUserRole();
    return role == SYSTEM_MANAGER;
  }

  String calculateAverage(User profile) {
    return ((double.parse(profile.waterPoints) + double.parse(profile.foodPoints) + double.parse(profile.fuelPoints) + double.parse(profile.energyPoints)) / 4).toString();
  }



  List<String> getUserTrophies(User user){
    List<String> trophies = [];

    double TotalPoints = double.parse(calculateAverage(user));
    switch(TotalPoints){
      case >= 70:
        trophies.add("assets/bronze_total.png");
        break;
      case >= 80:
        trophies.add("assets/silver_total.png");
        break;
      case >= 90:
        trophies.add("assets/gold_total.png");
        break;
    }
    /*
    int waterPoints = int.parse(user.waterPoints);
    switch(waterPoints){
      case >= 70:
        trophies.add("assets/bronze_water.png");
        break;
      case >= 80:
        trophies.add("assets/silver_water.png");
        break;
      case >= 90:
        trophies.add("assets/gold_water.png");
        break;
    }

    int fuelPoints = int.parse(user.fuelPoints);
    switch(fuelPoints){
      case >= 70:
        trophies.add("assets/bronze_fuel.png");
        break;
      case >= 80:
        trophies.add("assets/silver_fuel.png");
        break;
      case >= 90:
        trophies.add("assets/gold_fuel.png");
        break;
    }

    int energyPoints = int.parse(user.energyPoints);
    switch(energyPoints){
      case >= 70:
        trophies.add("assets/bronze_energy.png");
        break;
      case >= 80:
        trophies.add("assets/silver_energy.png");
        break;
      case >= 90:
        trophies.add("assets/gold_energy.png");
        break;
    }

    int foodPoints = int.parse(user.foodPoints);
    switch(foodPoints){
      case >= 70:
        trophies.add("assets/bronze_food.png");
        break;
      case >= 80:
        trophies.add("assets/silver_food.png");
        break;
      case >= 90:
        trophies.add("assets/gold_food.png");
        break;
    }*/

    return trophies;
  }


  void invalidSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Invalid session'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                      (route) => false, //remove tudo do stack
                );
              },
            ),
          ],
        );
      },
    );
  }


}