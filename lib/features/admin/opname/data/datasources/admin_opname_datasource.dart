import 'package:dio/dio.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../models/opname_session_model.dart';

class AdminOpnameRemoteDataSource {
  final Dio _dio;
  const AdminOpnameRemoteDataSource(this._dio);

  Future<List<OpnameSessionModel>> getSessions({int page = 1}) async {
    final response = await _dio.get(
      ApiEndpoints.adminOpname,
      queryParameters: {'page': page},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => OpnameSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OpnameSessionModel> startSession({
    required String nama,
    String? notes,
  }) async {
    final response = await _dio.post(
      '${ApiEndpoints.adminOpname}/start',
      data: {'nama': nama, 'notes': notes},
    );
    return OpnameSessionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> scanItem({
    required int sessionId,
    required String nomorBmn,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminOpnameScan(sessionId),
      data: {'nomor_bmn': nomorBmn},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> finishSession(int sessionId) async {
    await _dio.post(ApiEndpoints.adminOpnameFinish(sessionId));
  }
}
