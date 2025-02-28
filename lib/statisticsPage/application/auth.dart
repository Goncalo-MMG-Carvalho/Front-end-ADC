import 'dart:convert';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:http/http.dart' as http;

import '../../login/domain/User.dart';


const String localDatabaseName = "app.db";

const String ENERGY_CONSUMPTION = "energy_consumption";
const String BOTTLE_CONSUMPTION = "bottle_consumption";
const String TAP_CONSUMPTION = "tap_consumption";


class Authentication {

  userUtils uUtils = userUtils();


  Future<User?> updateElectricityValues(String electricityVal) {
    return fetchAuthenticateUpdateElectricityValues(electricityVal);
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
    } else {
      print("ERRO NO ELETRICITY: ${response.statusCode}");
      return null;
    }
  }


  Future<User?> updateWaterValues(String waterVal, String type) {
    return fetchAuthenticateUpdateWaterValues(waterVal, type);
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
    } else {
      print("ERRO NO ELETRICITY: ${response.statusCode}");
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


}