import 'package:dio/dio.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../models/tiket_model.dart';

class AdminTiketDatasource {
  final Dio _dio;
  const AdminTiketDatasource(this._dio);

  Future<List<TiketModel>> getAll({String? status}) async {
    final response = await _dio.get(
      ApiEndpoints.adminTiket,
      queryParameters: {if (status != null) 'status': status},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => TiketModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TiketModel> updateStatus({
    required int id,
    required String status,
    String? priority,
    String? assignedTo,
    String? adminNotes,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.adminTiketItem(id),
      data: {
        'status': status,
        'priority': priority,
        'assigned_to': assignedTo,
        'admin_notes': adminNotes,
      },
    );
    return TiketModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<TiketModel> resolve({
    required int id,
    required String resolusi,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminTiketResolve(id),
      data: {'resolusi': resolusi},
    );
    return TiketModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
