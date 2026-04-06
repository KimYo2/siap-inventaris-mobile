import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/notifikasi_model.dart';

class NotifikasiRemoteDataSource {
  final Dio _dio;
  const NotifikasiRemoteDataSource(this._dio);

  Future<List<NotifikasiModel>> getNotifikasi({int page = 1}) async {
    final response = await _dio.get(
      ApiEndpoints.notifikasi,
      queryParameters: {'page': page},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => NotifikasiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(int id) async {
    await _dio.post(ApiEndpoints.notifikasiRead(id));
  }
}
