import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/histori_peminjaman_model.dart';

class HistoriRemoteDataSource {
  final Dio _dio;

  HistoriRemoteDataSource(this._dio);

  Future<({List<HistoriPeminjamanModel> data, int currentPage, int lastPage})>
  getHistori({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.histori,
        queryParameters: {'page': page},
      );
      final raw = response.data as Map<String, dynamic>;
      final items = (raw['data'] as List<dynamic>)
          .map(
            (e) => HistoriPeminjamanModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      return (
        data: items,
        currentPage: raw['current_page'] as int,
        lastPage: raw['last_page'] as int,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Gagal memuat histori.',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<void> extendLoan({
    required int id,
    required int hari,
    String? alasan,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.historiExtend(id),
        data: {'hari': hari, 'alasan': alasan},
      );
    } on DioException catch (e) {
      throw ServerException(
        message:
            e.response?.data['message'] ?? 'Gagal mengajukan perpanjangan.',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}
