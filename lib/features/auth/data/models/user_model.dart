import 'dart:convert';

class UserModel {
  final int id;
  final String nip;
  final String name;
  final String email;
  final String role; // 'admin' | 'user'
  final String? fotoPath;

  const UserModel({
    required this.id,
    required this.nip,
    required this.name,
    required this.email,
    required this.role,
    this.fotoPath,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    nip: json['nip'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    fotoPath: json['foto_path'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nip': nip,
    'name': name,
    'email': email,
    'role': role,
    'foto_path': fotoPath,
  };

  String toJsonString() => jsonEncode(toJson());
}
