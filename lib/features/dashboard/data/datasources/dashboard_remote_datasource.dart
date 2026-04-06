import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/dashboard_summary_model.dart';

class DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSource(this._dio);

  Future<DashboardSummary> getDashboard() async {
    try {
      final response = await _dio.get(ApiEndpoints.dashboard);
      return DashboardSummary.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Gagal memuat dashboard.',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}
