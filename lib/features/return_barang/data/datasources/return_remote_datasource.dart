import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';

class ReturnRemoteDataSource {
  final Dio _dio;
  const ReturnRemoteDataSource(this._dio);

  Future<String> submitReturn({
    required String nomorBmn,
    bool isDamaged = false,
    String? jenisKerusakan, // 'ringan' | 'berat'
    String? deskripsi,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.returnBarang,
      data: {
        'nomor_bmn': nomorBmn,
        'is_damaged': isDamaged,
        if (isDamaged && jenisKerusakan != null)
          'jenis_kerusakan': jenisKerusakan,
        if (isDamaged && deskripsi != null && deskripsi.isNotEmpty)
          'deskripsi': deskripsi,
      },
    );
    return response.data['message'] as String? ?? 'Berhasil dikembalikan';
  }
}
