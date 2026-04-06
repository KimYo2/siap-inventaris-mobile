import 'package:dio/dio.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../models/kategori_model.dart';

class AdminKategoriDatasource {
  final Dio _dio;
  const AdminKategoriDatasource(this._dio);

  Future<List<KategoriModel>> getKategori({int page = 1}) async {
    final response = await _dio.get(
      ApiEndpoints.adminKategori,
      queryParameters: {'page': page},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => KategoriModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<KategoriModel> store({
    required String namaKategori,
    String? keterangan,
    int durasiPinjamDefault = 7,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminKategori,
      data: {
        'nama_kategori': namaKategori,
        'keterangan': keterangan,
        'durasi_pinjam_default': durasiPinjamDefault,
      },
    );
    return KategoriModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<KategoriModel> update({
    required int id,
    required String namaKategori,
    String? keterangan,
    int durasiPinjamDefault = 7,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.adminKategoriItem(id),
      data: {
        'nama_kategori': namaKategori,
        'keterangan': keterangan,
        'durasi_pinjam_default': durasiPinjamDefault,
      },
    );
    return KategoriModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> destroy(int id) async {
    await _dio.delete(ApiEndpoints.adminKategoriItem(id));
  }
}
