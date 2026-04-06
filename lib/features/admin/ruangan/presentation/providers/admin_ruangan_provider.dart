import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_ruangan_datasource.dart';
import '../../data/models/ruangan_model.dart';

final adminRuanganProvider =
    AsyncNotifierProvider<AdminRuanganNotifier, List<RuanganModel>>(
      AdminRuanganNotifier.new,
    );

class AdminRuanganNotifier extends AsyncNotifier<List<RuanganModel>> {
  @override
  Future<List<RuanganModel>> build() => _fetch();

  AdminRuanganDatasource get _ds =>
      AdminRuanganDatasource(ref.read(dioClientProvider).dio);

  Future<List<RuanganModel>> _fetch() => _ds.getAll();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> store({
    required String kodeRuangan,
    required String namaRuangan,
    String? lantai,
  }) async {
    final item = await _ds.store(
      kodeRuangan: kodeRuangan,
      namaRuangan: namaRuangan,
      lantai: lantai,
    );
    state = state.whenData((list) => [...list, item]);
  }

  Future<void> updateItem({
    required int id,
    required String kodeRuangan,
    required String namaRuangan,
    String? lantai,
  }) async {
    final item = await _ds.updateRuangan(
      id: id,
      kodeRuangan: kodeRuangan,
      namaRuangan: namaRuangan,
      lantai: lantai,
    );
    state = state.whenData(
      (list) => list.map((r) => r.id == id ? item : r).toList(),
    );
  }

  Future<void> destroy(int id) async {
    await _ds.destroy(id);
    state = state.whenData((list) => list.where((r) => r.id != id).toList());
  }
}
