import 'dart:convert';
import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import 'package:http/http.dart' as http;

import '../../exceptions/invalid_token.dart';
import '../../login/domain/Group.dart';
import '../../login/domain/User.dart';
import '../../profile/application/auth.dart';




class AuthenticationTopGroups {
  
  Future<List<EnvironmentalData>?> getTopGroups() async {
    try {
      return await fetchAuthenticateGetTopGroups();
    } on TokenInvalidoException catch (e) {
      print('Erro de token inválido: $e');
      throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<List<EnvironmentalData>?> fetchAuthenticateGetTopGroups() async {
    String? token = await userUtils().getToken();

    final response = await http.post(
      Uri.parse('https://projeto-adc-423314.ew.r.appspot.com/rest/get_top_groups/v1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'cookie': token!,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);

      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      return parsed.map<EnvironmentalData>((json) => EnvironmentalData.fromJson(json)).toList();

      //return true;
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');
    } else {

      return null;
    }
  }
}

class EnvironmentalData {
  final String averageBottleWater;
  final String averageCo2;
  final String averageElectricity;
  final String averageFood;
  final String averageFuel;
  final String averageTapWater;
  final String bottleCo2;
  final String colorCode;
  final String electricityCo2;
  final String foodCo2;
  final String fuelCo2;
  final String groupName;
  final String tapCo2;

  const EnvironmentalData({
    required this.averageBottleWater,
    required this.averageCo2,
    required this.averageElectricity,
    required this.averageFood,
    required this.averageFuel,
    required this.averageTapWater,
    required this.bottleCo2,
    required this.colorCode,
    required this.electricityCo2,
    required this.foodCo2,
    required this.fuelCo2,
    required this.groupName,
    required this.tapCo2,
  });

  Map<String, dynamic> toMap() {
    return {
      'averageBottleWater': averageBottleWater,
      'averageCo2': averageCo2,
      'averageElectricity': averageElectricity,
      'averageFood': averageFood,
      'averageFuel': averageFuel,
      'averageTapWater': averageTapWater,
      'bottleCo2': bottleCo2,
      'colorCode': colorCode,
      'electricityCo2': electricityCo2,
      'foodCo2': foodCo2,
      'fuelCo2': fuelCo2,
      'groupName': groupName,
      'tapCo2': tapCo2,
    };
  }

  factory EnvironmentalData.fromJson(Map<String, dynamic> json) {
    return EnvironmentalData(
      averageBottleWater: json['properties']['average_bottle_water']['value'].toString(),
      averageCo2: json['properties']['average_co2']['value'].toString(),
      averageElectricity: json['properties']['average_electricity']['value'].toString(),
      averageFood: json['properties']['average_food']['value'].toString(),
      averageFuel: json['properties']['average_fuel']['value'].toString(),
      averageTapWater: json['properties']['average_tap_water']['value'].toString(),
      bottleCo2: json['properties']['bottle_co2']['value'].toString(),
      colorCode: json['properties']['color_code']['value'],
      electricityCo2: json['properties']['electricity_co2']['value'].toString(),
      foodCo2: json['properties']['food_co2']['value'].toString(),
      fuelCo2: json['properties']['fuel_co2']['value'].toString(),
      groupName: json['properties']['group_name']['value'],
      tapCo2: json['properties']['tap_co2']['value'].toString(),
    );
  }

  factory EnvironmentalData.fromMap(Map<String, dynamic> map) {
    return EnvironmentalData(
      averageBottleWater: map['averageBottleWater'],
      averageCo2: map['averageCo2'],
      averageElectricity: map['averageElectricity'],
      averageFood: map['averageFood'],
      averageFuel: map['averageFuel'],
      averageTapWater: map['averageTapWater'],
      bottleCo2: map['bottleCo2'],
      colorCode: map['colorCode'],
      electricityCo2: map['electricityCo2'],
      foodCo2: map['foodCo2'],
      fuelCo2: map['fuelCo2'],
      groupName: map['groupName'],
      tapCo2: map['tapCo2'],
    );
  }

  @override
  String toString() {
    return 'EnvironmentalData{'
        'averageBottleWater: $averageBottleWater, '
        'averageCo2: $averageCo2, '
        'averageElectricity: $averageElectricity, '
        'averageFood: $averageFood, '
        'averageFuel: $averageFuel, '
        'averageTapWater: $averageTapWater, '
        'bottleCo2: $bottleCo2, '
        'colorCode: $colorCode, '
        'electricityCo2: $electricityCo2, '
        'foodCo2: $foodCo2, '
        'fuelCo2: $fuelCo2, '
        'groupName: $groupName, '
        'tapCo2: $tapCo2'
        '}';
  }
}

