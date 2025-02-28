import 'dart:convert';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:http/http.dart' as http;

import '../../exceptions/invalid_token.dart';
import '../../login/domain/User.dart';
import '../../Utils/constants.dart' as constants;
import '../../profile/application/auth.dart';

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

const String ENERGY_CONSUMPTION = "energy_consumption";
const String BOTTLE_CONSUMPTION = "bottle_consumption";
const String TAP_CONSUMPTION = "tap_consumption";
const String FUEL_TYPE = "fuel_type";


class Authentication {

  userUtils uUtils = userUtils();


  Future<User?> updateElectricityValues(String electricityVal) {
    try {
      return fetchAuthenticateUpdateElectricityValues(electricityVal);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<User?> fetchAuthenticateUpdateElectricityValues(String electricityVal) async {
    String? token = await uUtils.getToken();

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/update_user_statistics/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'fieldName': ENERGY_CONSUMPTION,
        'value': electricityVal,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> responseData = jsonDecode(response.body);

      Map<String, dynamic> properties = responseData['properties'];

      print(properties);

      User user = User.fromJson(properties);
      print(user.role);
      print(user);

      userUtils().addUser(user);
      // Extract cookie from response headers
      return user;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print("ERRO NO ELETRICITY: ${response.statusCode}");
      return null;
    }
  }


  Future<User?> updateWaterValues(String waterVal, String type) {
    try {
      return fetchAuthenticateUpdateWaterValues(waterVal, type);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<User?> fetchAuthenticateUpdateWaterValues(String waterVal, String type) async {
    String? token = await uUtils.getToken();
    print("TYPE$type");

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/update_user_statistics/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'fieldName': getFieldName(type),
        'value': waterVal,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> responseData = jsonDecode(response.body);

      Map<String, dynamic> properties = responseData['properties'];

      print(properties);

      User user = User.fromJson(properties);
      print(user.role);
      print(user.toString());

      userUtils().addUser(user);
      // Extract cookie from response headers
      return user;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print("ERRO NO ELETRICITY: ${response.statusCode}");
      return null;
    }
  }

  Future<User?> updateFoodValues(String foodVal, String type) {
    try {
      return fetchAuthenticateUpdateFoodValues(foodVal, type);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<User?> fetchAuthenticateUpdateFoodValues(String foodVal, String type) async {
    String? token = await uUtils.getToken();
    print("TYPE$type");

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/update_user_food/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'fieldName': getFoodFieldName(type),
        'value': foodVal,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> responseData = jsonDecode(response.body);

      Map<String, dynamic> properties = responseData['properties'];

      print(properties);

      User user = User.fromJson(properties);
      print(user.role);
      print(user.toString());

      userUtils().addUser(user);
      // Extract cookie from response headers
      return user;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print("ERRO NO ELETRICITY: ${response.statusCode}");
      return null;
    }
  }

  Future<User?> updateFuelValue(String fuelVal) {
    try {
      return fetchAuthenticateUpdateFuelValues(fuelVal);
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }


  Future<User?> fetchAuthenticateUpdateFuelValues(String fuelVal) async {
    String? token = await uUtils.getToken();
    print("TYPE$fuelVal");

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/update_user_statistics/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
        'fieldName': FUEL_TYPE,
        'value': fuelVal.toLowerCase(),
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> responseData = jsonDecode(response.body);

      Map<String, dynamic> properties = responseData['properties'];

      print(properties);

      User user = User.fromJson(properties);
      print(user.role);
      print(user.toString());

      userUtils().addUser(user);
      // Extract cookie from response headers
      return user;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {
      print("ERRO NO FUEL UPDATE: ${response.statusCode}");
      return null;
    }
  }



  String getFieldName(String type) {
    switch (type) {
      case 'Plastic bottles':
        return BOTTLE_CONSUMPTION;
      case 'Tap':
        return TAP_CONSUMPTION;
      default:
        throw Exception('Tipo de consumo de água não reconhecido');
    }
  }

  String getFoodFieldName(String type) {
    switch (type) {
      case 'Red Meat':
        return 'red_meat';
      case 'White Meat':
        return 'white_meat';
      case 'Fish':
        return 'fish';
      case 'Dairy':
        return 'dairy';
      case 'Carbs':
        return 'carbohydrates';
      case 'Vegetables':
        return 'vegetables';
      case 'Fruit':
        return 'fruit';
      default:
        throw Exception('Tipo de consumo de água não reconhecido');
    }
  }



}