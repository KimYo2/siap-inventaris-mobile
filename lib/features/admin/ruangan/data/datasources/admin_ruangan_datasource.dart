import 'package:dio/dio.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../models/ruangan_model.dart';

class AdminRuanganDatasource {
  final Dio _dio;
  const AdminRuanganDatasource(this._dio);

  Future<List<RuanganModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.adminRuangan);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => RuanganModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RuanganModel> store({
    required String kodeRuangan,
    required String namaRuangan,
    String? lantai,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminRuangan,
      data: {
        'kode_ruangan': kodeRuangan,
        'nama_ruangan': namaRuangan,
        'lantai': lantai,
      },
    );
    return RuanganModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<RuanganModel> updateRuangan({
    required int id,
    required String kodeRuangan,
    required String namaRuangan,
    String? lantai,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.adminRuanganItem(id),
      data: {
        'kode_ruangan': kodeRuangan,
        'nama_ruangan': namaRuangan,
        'lantai': lantai,
      },
    );
    return RuanganModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> destroy(int id) async {
    await _dio.delete(ApiEndpoints.adminRuanganItem(id));
  }
}
