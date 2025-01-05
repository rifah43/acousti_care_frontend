class User {
  final String? id;
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final double bmi;
  final String email;
  final String? password;
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
    print('Parsing JSON: $json'); // Debug print
    return User(
      id: (json['_id'] ?? json['id'])?.toString(), // Handle both _id and id
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
      if (value is int) return value;
      return int.parse(value.toString());
    } catch (e) {
      print('Error parsing int: $value'); // Debug print
      return 0;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.parse(value.toString());
    } catch (e) {
      print('Error parsing double: $value'); // Debug print
      return 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'email': email,
      'isActive': isActive,
    };
  }

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
  
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, isActive: $isActive)';
  }
}