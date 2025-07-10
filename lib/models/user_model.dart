// lib/models/user_model.dart
class User {
  final int? id;
  final String name;
  final String email;
  final String? profilePicture;
  final int height; // in cm
  final double weight; // in kg
  final int age;
  final String gender;

  User({
    this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      height: json['height'],
      weight: json['weight'],
      age: json['age'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? profilePicture,
    int? height,
    double? weight,
    int? age,
    String? gender,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }
}
