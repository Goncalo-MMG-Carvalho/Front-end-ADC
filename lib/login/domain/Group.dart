class Group {
  final String groupName, groupOwner, adminNames, members, color;
  final String? averageElectricity, fuelValues, tapCo2, foodValues, tapValues, averageBottleWater, electricityValues, averageFuel, averageFood, electricityCo2, bottleCo2, fuelCo2, foodCo2, averageCo2, averageTapWater, bottleValues;
  final bool access, type;

  Group({
    required this.bottleCo2,
    required this.fuelCo2,
    required this.foodCo2,
    required this.electricityCo2,
    required this.averageElectricity,
    required this.averageBottleWater,
    required this.averageFuel,
    required this.averageFood,
    required this.groupOwner,
    required this.groupName,
    required this.adminNames,
    required this.access,
    required this.type,
    required this.members,
    required this.color,
    required this.averageCo2,
    required this.averageTapWater,
    required this.electricityValues,
    required this.foodValues,
    required this.fuelValues,
    required this.bottleValues,
    required this.tapCo2,
    required this.tapValues,

  });


  Map<String, dynamic> toMap() {
    return {
      'bottleCo2': bottleCo2,
      'fuelCo2': fuelCo2,
      'foodCo2': foodCo2,
      'electricityCo2': electricityCo2,
      'averageElectricity': averageElectricity,
      'averageBottleWater': averageBottleWater,
      'averageFuel': averageFuel,
      'averageFood': averageFood,
      'groupName': groupName,
      'groupOwner': groupOwner,
      'adminNames': adminNames,
      'access': access ? 1 : 0,
      'type': type ? 1 : 0,
      'members': members,
      'color': color,
      'averageCo2': averageCo2,
      'averageTapWater': averageTapWater,
      'electricityValues': electricityValues,
      'foodValues': foodValues,
      'fuelValues': fuelValues,
      'bottleValues': bottleValues,
      'tapCo2': tapCo2,
      'tapValues': tapValues,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      bottleCo2: map['bottleCo2'] ?? '',
      fuelCo2: map['fuelCo2'] ?? '',
      foodCo2: map['foodCo2'] ?? '',
      electricityCo2: map['electricityCo2'] ?? '',
      averageElectricity: map['averageElectricity'] ?? '',
      averageBottleWater: map['averageBottleWater'] ?? '',
      averageFuel: map['averageFuel'] ?? '',
      averageFood: map['averageFood'] ?? '',
      groupOwner: map['groupOwner'] ?? '',
      groupName: map['groupName'] ?? '',
      adminNames: map['adminNames'] ?? '',
      access: map['access'] == 1,
      type: map['type'] == 1,
      members: map['members'] ?? '',
      color: map['color'] ?? '',
      averageCo2: map['averageCo2'] ?? '',
      averageTapWater: map['averageTapWater'] ?? '',
      electricityValues: map['electricityValues'] ?? '',
      foodValues: map['foodValues'] ?? '',
      fuelValues: map['fuelValues'] ?? '',
      bottleValues: map['bottleValues'] ?? '',
      tapCo2: map['tapCo2'] ?? '',
      tapValues: map['tapValues'] ?? '',
    );
  }

  factory Group.fromJson2(Map<String, dynamic> json) {
    return Group(
      bottleCo2: json['bottle_co2']['value'].toString() ?? '',
      fuelCo2: json['fuel_co2']['value'].toString() ?? '',
      foodCo2: json['food_co2']['value'].toString() ?? '',
      electricityCo2: json['electricity_co2']['value'].toString() ?? '',
      averageElectricity: json['average_electricity']['value'].toString() ?? '',
      averageBottleWater: json['average_bottle_water']['value'].toString() ?? '',
      averageFuel: json['average_fuel']['value'].toString() ?? '',
      averageFood: json['average_food']['value'].toString() ?? '',
      groupOwner: json['group_owner']['value'] ?? '',
      groupName: json['group_name']['value'] ?? '',
      adminNames: json['admin_names']['value'] ?? '',
      access: json['group_access']['value'].toString() == 'true',
      type: json['group_type']['value'].toString() == 'true',
      members: json['group_members']['value'] ?? '',
      color: json['color_code']['value'] ?? '',
      averageCo2: json['average_co2']['value'].toString() ?? '',
      averageTapWater: json['average_tap_water']['value'].toString() ?? '',
      electricityValues: json['electricity_values']['value'].toString() ?? '',
      foodValues: json['food_values']['value'].toString() ?? '',
      fuelValues: json['fuel_values']['value'].toString() ?? '',
      bottleValues: json['bottle_values']['value'].toString() ?? '',
      tapCo2: json['tap_co2']['value'].toString() ?? '',
      tapValues: json['tap_values']['value'].toString() ?? '',
    );
  }

  factory Group.fromJson(Map<String, String> json) {
    return Group(
      bottleCo2: json['bottle_co2'].toString() ?? '',
      fuelCo2: json['fuel_co2'].toString() ?? '',
      foodCo2: json['food_co2'].toString() ?? '',
      electricityCo2: json['electricity_co2'].toString() ?? '',
      averageElectricity: json['average_electricity'].toString() ?? '',
      averageBottleWater: json['average_bottle_water'].toString() ?? '',
      averageFuel: json['average_fuel'].toString() ?? '',
      averageFood: json['average_food'].toString() ?? '',
      groupOwner: json['group_owner'] ?? '',
      groupName: json['group_name'] ?? '',
      adminNames: json['admin_names'] ?? '',
      access: json['group_access'].toString() == 'true',
      type: json['group_type'].toString() == 'true',
      members: json['group_members'] ?? '',
      color: json['color_code'] ?? '',
      averageCo2: json['average_co2'].toString() ?? '',
      averageTapWater: json['average_tap_water'].toString() ?? '',
      electricityValues: json['electricity_values'].toString() ?? '',
      foodValues: json['food_values'].toString() ?? '',
      fuelValues: json['fuel_values'].toString() ?? '',
      bottleValues: json['bottle_values'].toString() ?? '',
      tapCo2: json['tap_co2'].toString() ?? '',
      tapValues: json['tap_values'].toString() ?? '',
    );
  }

  @override
  @override
  String toString() {
    return 'Group { '
        'groupName: $groupName, '
        'groupOwner: $groupOwner, '
        'adminNames: $adminNames, '
        'members: $members, '
        'access: $access, '
        'type: $type, '
        'color: $color, '
        'averageElectricity: $averageElectricity, '
        'fuelValues: $fuelValues, '
        'tapCo2: $tapCo2, '
        'foodValues: $foodValues, '
        'tapValues: $tapValues, '
        'averageBottleWater: $averageBottleWater, '
        'electricityValues: $electricityValues, '
        'averageFuel: $averageFuel, '
        'averageFood: $averageFood, '
        'electricityCo2: $electricityCo2, '
        'bottleCo2: $bottleCo2, '
        'fuelCo2: $fuelCo2, '
        'foodCo2: $foodCo2, '
        'averageCo2: $averageCo2, '
        'averageTapWater: $averageTapWater, '
        'bottleValues: $bottleValues '
        '}';
  }
}
