class UserAdminModel {
  final int id;
  final String nip;
  final String name;
  final String email;
  final String role;
  final String? fotoPath;

  const UserAdminModel({
    required this.id,
    required this.nip,
    required this.name,
    required this.email,
    required this.role,
    this.fotoPath,
  });

  factory UserAdminModel.fromJson(Map<String, dynamic> json) => UserAdminModel(
    id: json['id'] as int,
    nip: json['nip'] as String? ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? 'user',
    fotoPath: json['foto_path'] as String?,
  );

  bool get isAdmin => role == 'admin';
}
