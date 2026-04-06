import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/models/dashboard_summary_model.dart';
import '../../../../core/network/dio_client.dart';

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardSummary>(
      DashboardNotifier.new,
    );

class DashboardNotifier extends AsyncNotifier<DashboardSummary> {
  @override
  Future<DashboardSummary> build() => _fetch();

  Future<DashboardSummary> _fetch() {
    final dio = ref.read(dioClientProvider).dio;
    return DashboardRemoteDataSource(dio).getDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}
