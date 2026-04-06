import 'package:dio/dio.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../models/admin_dashboard_model.dart';

class AdminDashboardRemoteDataSource {
  final Dio _dio;
  const AdminDashboardRemoteDataSource(this._dio);

  Future<AdminDashboardModel> getDashboard() async {
    final response = await _dio.get(ApiEndpoints.adminDashboard);
    return AdminDashboardModel.fromJson(response.data as Map<String, dynamic>);
  }
}
