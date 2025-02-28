import 'dart:convert';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import 'package:http/http.dart' as http;

import '../../exceptions/invalid_token.dart';
import '../../login/domain/Group.dart';
import '../../login/domain/User.dart';
import '../../profile/application/auth.dart';



class AuthenticationCompany {

  Future<Company?> getCompany() async {
    try {
      return await fetchAuthenticateGetCompany();

    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<Company?> fetchAuthenticateGetCompany() async {
    String? token = await userUtils().getToken();

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/get_business_info/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);

      return Company.fromJson(jsonDecode(response.body)['properties']);

      //return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {

      return null;
    }
  }
}


class Company {
  String averageCO2String;
  String electricityCO2String;
  String electricityConsumptionString;
  String totalElectricityString;
  String tapWaterCO2String;
  String tapWaterConsumptionString;
  String totalTapWaterString;
  String bottleWaterCO2String;
  String bottleWaterConsumptionString;
  String totalBottleWaterString;
  String fuelCO2String;
  String foodCO2String;

  Company({
    required this.averageCO2String,
    required this.electricityCO2String,
    required this.electricityConsumptionString,
    required this.totalElectricityString,
    required this.tapWaterCO2String,
    required this.tapWaterConsumptionString,
    required this.totalTapWaterString,
    required this.bottleWaterCO2String,
    required this.bottleWaterConsumptionString,
    required this.totalBottleWaterString,
    required this.fuelCO2String,
    required this.foodCO2String,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      averageCO2String: json['average_co2']['value'].toString() ,
      electricityCO2String: json['electricity_co2']['value'].toString() ,
      electricityConsumptionString: json['energy_consumption']['value'].toString(),
      totalElectricityString: json['total_electricity']['value'].toString(),
      tapWaterCO2String: json['tap_co2']['value'].toString(),
      tapWaterConsumptionString: json['tap_consumption']['value'].toString(),
      totalTapWaterString: json['total_tap_water']['value'].toString(),
      bottleWaterCO2String: json['bottle_co2']['value'].toString(),
      bottleWaterConsumptionString: json['bottle_consumption']['value'].toString(),
      totalBottleWaterString: json['total_bottle_water']['value'].toString(),
      fuelCO2String: json['fuel_co2']['value'].toString(),
      foodCO2String: json['food_co2']['value'].toString(),
    );
  }
}