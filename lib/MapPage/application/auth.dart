import 'dart:convert';

import 'package:adc_handson_session/Utils/userUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../exceptions/invalid_token.dart';
import '../../login/data/users_local_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
import '../../Utils/constants.dart' as constants;
import '../../login/domain/User.dart';
import '../../profile/application/auth.dart';

const String localDatabaseName = constants.LOCAL_DATABASE_NAME;

class AuthenticationMap {

  userUtils uUtils = userUtils();
  final Dio dio = Dio();


  Future<String?> getUserFuelType() async {
    User user = await uUtils.getUser();
    return user.fuelType;
  }

  void sendRouteInfo(double routeEmissions, double transitDistance) {
    try{
      fetchAuthenticationSendRouteInfo(routeEmissions, transitDistance);
    } on TokenInvalidoException catch (e) {
    print('Erro de token inválido: $e');
    throw Exception('Erro de token inválido ao tentar obter grupos: $e');
    }
  }

  Future<void> fetchAuthenticationSendRouteInfo(double routeEmissions, double transitDistance) async {
    String? token = await uUtils.getToken();
    dio.options.headers['content-type'] = 'application/json';

    var response = await dio.post(
        'https://projeto-adc-423314.ew.r.appspot.com/rest/update_user_mobility/v1',
      data: {
          'cookie': token,
          'fuelConsumption': routeEmissions, // in liters
          'distance': transitDistance   // in km
      }
    );

    if (response.statusCode == 200) {

      print(response.data);
      Map<String, dynamic> responseData = jsonDecode(response.data);

      Map<String, dynamic> properties = responseData['properties'];

      print(properties);

      User user = User.fromJson(properties);
      print(user.role);
      print(user);

      userUtils().addUser(user);
    }else if(response.statusCode == 403){
      await AuthenticationProfile().removeToken();
      throw TokenInvalidoException('O token de autenticação é inválido.');

    }else{
      if(kDebugMode) {
        print('Error sending route data to database');
        print('Response data: ${response.data}');
      }
    }
    }

}