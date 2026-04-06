import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/barang_model.dart';

class BarangRemoteDataSource {
  final Dio _dio;

  BarangRemoteDataSource(this._dio);

  Future<BarangModel> getBarangDetail(String nomorBmn) async {
    try {
      final response = await _dio.get(ApiEndpoints.barangDetail(nomorBmn));
      return BarangModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Barang tidak ditemukan.',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<void> borrowBarang({required String nomorBmn}) async {
    try {
      await _dio.post(ApiEndpoints.borrowBarang, data: {'nomor_bmn': nomorBmn});
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Gagal mengajukan peminjaman.',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<void> joinWaitlist(String nomorBmn) async {
    try {
      await _dio.post(ApiEndpoints.barangWaitlist(nomorBmn));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Gagal bergabung waitlist.',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<void> cancelWaitlist(int id) async {
    try {
      await _dio.delete(ApiEndpoints.waitlistCancel(id));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Gagal membatalkan waitlist.',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}
