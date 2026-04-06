import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<({String token, UserModel user})> login({
    required String nip,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'nip': nip, 'password': password},
      );
      return (
        token: response.data['token'] as String,
        user: UserModel.fromJson(response.data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Terjadi kesalahan server.',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<void> logout(Dio dio) async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
      // fire and forget
    }
  }
}
