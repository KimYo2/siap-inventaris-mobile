import 'package:dio/dio.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../barang/data/models/barang_model.dart';

class AdminBarangDatasource {
  final Dio _dio;
  const AdminBarangDatasource(this._dio);

  Future<List<BarangModel>> getAll({
    String? ketersediaan,
    int? kategoriId,
    int? ruanganId,
    String? search,
    int page = 1,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.adminBarang,
      queryParameters: {
        'page': page,
        if (ketersediaan != null) 'ketersediaan': ketersediaan,
        if (kategoriId != null) 'kategori_id': kategoriId,
        if (ruanganId != null) 'ruangan_id': ruanganId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => BarangModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BarangModel> updateStatus({
    required int id,
    required String kondisi,
    String? catatan,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminBarangStatus(id),
      data: {'kondisi_terakhir': kondisi, 'catatan': catatan},
    );
    return BarangModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
