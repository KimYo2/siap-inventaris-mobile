import 'package:dio/dio.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../histori/data/models/histori_peminjaman_model.dart';

class AdminHistoriRemoteDataSource {
  final Dio _dio;
  const AdminHistoriRemoteDataSource(this._dio);

  Future<List<HistoriPeminjamanModel>> getHistori({
    int page = 1,
    String? status, // menunggu | dipinjam | dikembalikan | ditolak
    String? search,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminHistori,
      queryParameters: {
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => HistoriPeminjamanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approve(int id) async {
    await _dio.post(ApiEndpoints.adminHistoriApprove(id));
  }

  Future<void> reject(int id, {String? reason}) async {
    await _dio.post(
      ApiEndpoints.adminHistoriReject(id),
      data: {'rejection_reason': reason},
    );
  }

  Future<void> approveExtend(int id) async {
    await _dio.post(ApiEndpoints.adminExtendApprove(id));
  }

  Future<void> rejectExtend(int id, {String? reason}) async {
    await _dio.post(
      ApiEndpoints.adminExtendReject(id),
      data: {'reject_reason': reason},
    );
  }
}
