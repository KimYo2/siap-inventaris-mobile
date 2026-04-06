import 'package:dio/dio.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../models/user_admin_model.dart';

class AdminUsersDatasource {
  final Dio _dio;
  const AdminUsersDatasource(this._dio);

  Future<List<UserAdminModel>> getAll({String? search}) async {
    final response = await _dio.get(
      ApiEndpoints.adminUsers,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => UserAdminModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserAdminModel> store({
    required String nip,
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminUsers,
      data: {
        'nip': nip,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
    );
    return UserAdminModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<UserAdminModel> updateUser({
    required int id,
    required String nip,
    required String name,
    required String email,
    String? password,
    String role = 'user',
  }) async {
    final response = await _dio.put(
      ApiEndpoints.adminUsersItem(id),
      data: {
        'nip': nip,
        'name': name,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
        'role': role,
      },
    );
    return UserAdminModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
