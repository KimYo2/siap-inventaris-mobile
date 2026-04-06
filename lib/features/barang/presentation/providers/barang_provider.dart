import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/barang_remote_datasource.dart';
import '../../data/models/barang_model.dart';
import '../../../../core/network/dio_client.dart';

// ---------------------------------------------------------------------------
// Provider: detail barang by nomor_bmn
// ---------------------------------------------------------------------------
final barangDetailProvider =
    AsyncNotifierProviderFamily<BarangDetailNotifier, BarangModel, String>(
      BarangDetailNotifier.new,
    );

class BarangDetailNotifier extends FamilyAsyncNotifier<BarangModel, String> {
  @override
  Future<BarangModel> build(String nomorBmn) => _fetch(nomorBmn);

  Future<BarangModel> _fetch(String nomorBmn) {
    final dio = ref.read(dioClientProvider).dio;
    return BarangRemoteDataSource(dio).getBarangDetail(nomorBmn);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  Future<void> borrow() async {
    final dio = ref.read(dioClientProvider).dio;
    await BarangRemoteDataSource(dio).borrowBarang(nomorBmn: arg);
    await refresh();
  }

  Future<void> joinWaitlist() async {
    final dio = ref.read(dioClientProvider).dio;
    await BarangRemoteDataSource(dio).joinWaitlist(arg);
    await refresh();
  }

  Future<void> cancelWaitlist(int waitlistId) async {
    final dio = ref.read(dioClientProvider).dio;
    await BarangRemoteDataSource(dio).cancelWaitlist(waitlistId);
    await refresh();
  }
}
