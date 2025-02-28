import '../../Utils/constants.dart' as constants;
class User {
  final bool activationState;
  final String age;
  final DateTime creationTime;
  final String email;
  final String energyConsumption;
  final String fuelType;
  final String name;
  final String password;
  final String role;
  final String userGroups;
  final String username;
  final String bottleConsumption;
  final String energyCo2;
  final String bottleCo2;
  final String tapConsumption;
  final String tapCo2;
  final String fuelCo2;
  final String averageCo2;
  final String foodCo2;
  final String energyHistory;
  final String energyPoints;
  final String foodHistory;
  final String foodPoints;
  final String fuelHistory;
  final String fuelPoints;
  final String waterHistory;
  final String waterPoints;
  final String averagePoints;


  const User({
    required this.activationState,
    required this.age,
    required this.creationTime,
    required this.email,
    required this.energyConsumption,
    required this.fuelType,
    required this.name,
    required this.password,
    required this.role,
    required this.userGroups,
    required this.username,
    required this.bottleConsumption,
    required this.energyCo2,
    required this.bottleCo2,
    required this.tapCo2,
    required this.tapConsumption,
    required this.fuelCo2,
    required this.averageCo2,
    required this.foodCo2,
    required this.energyHistory,
    required this.energyPoints,
    required this.foodHistory,
    required this.foodPoints,
    required this.fuelHistory,
    required this.fuelPoints,
    required this.waterHistory,
    required this.waterPoints,
    required this.averagePoints,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      activationState: json['activation_state']['value'].toString() == 'true',
      age: json['age']['value'] as String,
      creationTime: DateTime.fromMillisecondsSinceEpoch(
        (json['creation_time']['value']['seconds'] as int) * 1000 +
            (json['creation_time']['value']['nanos'] as int) ~/ 1000000,
      ),
      email: json['email']['value'] as String,
      energyConsumption: (json['energy_consumption']['value'] as double?)?.toStringAsFixed(2) ?? '',
      fuelType: json['fuel_type']['value'] as String,
      name: json['name']['value'] as String,
      password: json['password']['value'] as String,
      role: json['role']['value'] as String,
      userGroups: json['user_groups']['value'] as String,
      username: json['username']['value'] as String,
      bottleConsumption: (json['bottle_consumption']['value'] as double?)?.toStringAsFixed(2) ?? '',
      energyCo2: (json['electricity_co2']['value'] as double?)?.toStringAsFixed(2) ?? '',
      bottleCo2: (json['bottle_co2']['value'] as double?)?.toStringAsFixed(2) ?? '',
      tapConsumption: (json['tap_consumption']['value'] as double?)?.toStringAsFixed(2) ?? '',
      tapCo2: (json['tap_co2']['value'] as double?)?.toStringAsFixed(2) ?? '',
      fuelCo2: (json['fuel_co2']['value'] as double?)?.toStringAsFixed(2) ?? '',
      averageCo2: (json['average_co2']['value'] as double?)?.toStringAsFixed(2) ?? '',
      foodCo2: (json['food_co2']['value'] as double?)?.toStringAsFixed(2) ?? '',
      energyPoints: (json['electricity_points']['value'] as double?)?.toString() ?? '',
      foodPoints: (json['food_points']['value'] as double?)?.toString() ?? '',
      fuelPoints: (json['fuel_points']['value'] as double?)?.toString() ?? '',
      waterPoints: (json['water_points']['value'] as double?)?.toString() ?? '',
      averagePoints: (json['average_points']['value'] as double?)?.toString() ?? '',
      energyHistory: json['electricity_history']['value'] as String,
      foodHistory: json['food_history']['value'] as String,
      fuelHistory: json['fuel_history']['value'] as String,
      waterHistory: json['water_history']['value'] as String,
    );
  }

  factory User.fromJsonLocalStorage(Map<String, dynamic> json) {
    return User(
      activationState: json['activation_state'] == true,
      age: json['age'] ?? '',
      averageCo2: json['average_co2']?.toString() ?? '0',
      creationTime: DateTime.tryParse(json['creation_time'].toString()) ?? DateTime.now(),
      email: json['email'] ?? '',
      energyConsumption: json['energy_consumption']?.toString() ?? '0',
      foodCo2: json['food_co2']?.toString() ?? '0',
      fuelType: json['fuel_type'] ?? constants.MAPS_FUEL_TYPE_GASOLINE,
      fuelCo2: json['fuel_co2']?.toString() ?? '0',
      name: json['name'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
      userGroups: json['user_groups'] ?? '',
      username: json['username'] ?? '',
      energyCo2: json['electricity_co2'] ?? '',
      bottleCo2: json['bottle_co2']?.toString() ?? '0',
      bottleConsumption: json['bottle_consumption']?.toString() ?? '0',
      tapCo2: json['tap_co2']?.toString() ?? '0',
      tapConsumption: json['tap_consumption']?.toString() ?? '0',
      energyPoints: json['electricity_points']?.toString() ?? '',
      foodPoints: json['food_points']?.toString() ?? '',
      fuelPoints: json['fuel_points']?.toString() ?? '',
      averagePoints: json['average_points']?.toString() ?? '',
      waterPoints: json['water_points']?.toString() ?? '',
      energyHistory: json['electricity_history'] ?? '',
      foodHistory: json['food_history'] ?? '',
      fuelHistory: json['fuel_history'] ?? '',
      waterHistory: json['water_history'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activation_state': activationState,
      'age': age,
      'creation_time': creationTime.toIso8601String(),
      'email': email,
      'energy_consumption': energyConsumption,
      'fuel_type': fuelType,
      'name': name,
      'password': password,
      'role': role,
      'user_groups': userGroups,
      'username': username,
      'bottle_consumption': bottleConsumption,
      'electricity_co2': energyCo2,
      'bottle_co2': bottleCo2,
      'tap_co2': tapCo2,
      'tap_consumption': tapConsumption,
      'fuel_co2': fuelCo2,
      'average_co2': averageCo2,
      'food_co2': foodCo2,
      'electricity_points': energyPoints,
      'food_points': foodPoints,
      'fuel_points': fuelPoints,
      'water_points': waterPoints,
      'average_points': averagePoints,
      'electricity_history': energyHistory,
      'food_history': foodHistory,
      'fuel_history': fuelHistory,
      'water_history': waterHistory,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      activationState: map['activationState'] == 1,
      age: map['age'] ?? '',
      creationTime: map['creationTime'] != null ? DateTime.parse(map['creationTime']) : DateTime.now(),
      email: map['email'] ?? '',
      energyConsumption: map['energyConsumption'] ?? '',
      fuelType: map['fuelType'] ?? constants.MAPS_FUEL_TYPE_GASOLINE,
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      userGroups: map['userGroups'] ?? '',
      username: map['username'] ?? '',
      bottleConsumption: map['bottleConsumption'] ?? '',
      energyCo2: map['energyCo2'] ?? '',
      bottleCo2: map['bottleCo2'] ?? '',
      tapConsumption: map['tapConsumption'] ?? '',
      tapCo2: map['tapCo2'] ?? '',
      fuelCo2: map['fuelCo2'] ?? '',
      averageCo2: map['averageCo2'] ?? '',
      foodCo2: map['foodCo2'] ?? '',
      energyPoints: map['energyPoints'] ?? '',
      foodPoints: map['foodPoints'] ?? '',
      fuelPoints: map['fuelPoints'] ?? '',
      averagePoints: map['averagePoints'] ?? '',
      waterPoints: map['waterPoints'] ?? '',
      energyHistory: map['energyHistory'] ?? '',
      foodHistory: map['foodHistory'] ?? '',
      fuelHistory: map['fuelHistory'] ?? '',
      waterHistory: map['waterHistory'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activationState': activationState ? 1 : 0,
      'age': age,
      'creationTime': creationTime.toIso8601String(),
      'email': email,
      'energyConsumption': energyConsumption,
      'fuelType': fuelType,
      'name': name,
      'password': password,
      'role': role,
      'userGroups': userGroups,
      'username': username,
      'bottleConsumption': bottleConsumption,
      'energyCo2': energyCo2,
      'bottleCo2': bottleCo2,
      'tapCo2': tapCo2,
      'tapConsumption': tapConsumption,
      'fuelCo2': fuelCo2,
      'averageCo2': averageCo2,
      'foodCo2': foodCo2,
      'energyPoints': energyPoints,
      'foodPoints': foodPoints,
      'fuelPoints': fuelPoints,
      'averagePoints': averagePoints,
      'waterPoints': waterPoints,
      'energyHistory': energyHistory,
      'foodHistory': foodHistory,
      'fuelHistory': fuelHistory,
      'waterHistory': waterHistory,
    };
  }

  @override
  String toString() {
    return 'User{'
        'activationState: $activationState, '
        'averagePoints: $averagePoints, '
        'age: $age, '
        'creationTime: $creationTime, '
        'email: $email, '
        'energyConsumption: $energyConsumption, '
        'fuelType: $fuelType, '
        'name: $name, '
        'password: $password, '
        'role: $role, '
        'userGroups: $userGroups, '
        'username: $username, '
        'bottleConsumption: $bottleConsumption, '
        'energyCo2: $energyCo2, '
        'bottleCo2: $bottleCo2, '
        'tapConsumption: $tapConsumption, '
        'tapCo2: $tapCo2, '
        'fuelCo2: $fuelCo2, '
        'averageCo2: $averageCo2, '
        'foodCo2: $foodCo2, '
        'energyHistory: $energyHistory, '
        'energyPoints: $energyPoints, '
        'foodHistory: $foodHistory, '
        'foodPoints: $foodPoints, '
        'fuelHistory: $fuelHistory, '
        'fuelPoints: $fuelPoints, '
        'waterHistory: $waterHistory, '
        'waterPoints: $waterPoints'
        '}';
  }
}
