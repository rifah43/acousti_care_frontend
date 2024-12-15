class User {
  final String? id;
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final double bmi;
  final String email;
  final String? password;  // Optional for responses
  final bool isActive;

  User({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.email,
    this.password,
    this.isActive = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      age: _parseInt(json['age']),
      gender: json['gender'] ?? '',
      height: _parseDouble(json['height']),
      weight: _parseDouble(json['weight']),
      bmi: _parseDouble(json['bmi']),
      email: json['email'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return 0;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    try {
      return double.parse(value.toString());
    } catch (e) {
      return 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'email': email,
      'isActive': isActive,
    };

    if (id != null) map['_id'] = id as String;
    if (password != null) map['password'] = password as String;

    return map;
  }

  // Create registration data (includes password)
  Map<String, dynamic> toRegistrationJson() {
    if (password == null) {
      throw Exception('Password is required for registration');
    }
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'email': email,
      'password': password,
    };
  }

  // Create a copy of the user with some fields modified
  User copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? bmi,
    String? email,
    String? password,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      email: email ?? this.email,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
    );
  }
}