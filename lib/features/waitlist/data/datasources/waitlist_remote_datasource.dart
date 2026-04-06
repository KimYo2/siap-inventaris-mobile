import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/waitlist_item_model.dart';

class WaitlistRemoteDataSource {
  final Dio _dio;
  const WaitlistRemoteDataSource(this._dio);

  Future<List<WaitlistItemModel>> getMyWaitlist() async {
    final response = await _dio.get(ApiEndpoints.waitlistList);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => WaitlistItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelWaitlist(int id) async {
    await _dio.post(ApiEndpoints.waitlistCancel(id));
  }
}
