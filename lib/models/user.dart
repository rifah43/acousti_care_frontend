class User {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final double bmi;
  final String email;

  User({
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    name: json['name'] ?? '',
    age: _parseInt(json['age']),
    gender: json['gender'] ?? '',
    height: json['height']?.toDouble() ?? 0.0,
    weight: json['weight']?.toDouble() ?? 0.0,
    bmi: json['bmi']?.toDouble() ?? 0.0,
    email: json['email'] ?? '',
  );
}

static int _parseInt(dynamic value) {
  if (value == null) return 0;
  try {
    return int.parse(value.toString());
  } catch (e) {
    return 0; // Default value in case of an error
  }
}


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'email': email,
    };
  }
}

