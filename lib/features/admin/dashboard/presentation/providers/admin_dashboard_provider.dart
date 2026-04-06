import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_dashboard_datasource.dart';
import '../../data/models/admin_dashboard_model.dart';

final adminDashboardProvider =
    AsyncNotifierProvider<AdminDashboardNotifier, AdminDashboardModel>(
      AdminDashboardNotifier.new,
    );

class AdminDashboardNotifier extends AsyncNotifier<AdminDashboardModel> {
  @override
  Future<AdminDashboardModel> build() => _fetch();

  AdminDashboardRemoteDataSource get _ds =>
      AdminDashboardRemoteDataSource(ref.read(dioClientProvider).dio);

  Future<AdminDashboardModel> _fetch() => _ds.getDashboard();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}
