import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_kategori_datasource.dart';
import '../../data/models/kategori_model.dart';

final adminKategoriProvider =
    AsyncNotifierProvider<AdminKategoriNotifier, List<KategoriModel>>(
      AdminKategoriNotifier.new,
    );

class AdminKategoriNotifier extends AsyncNotifier<List<KategoriModel>> {
  @override
  Future<List<KategoriModel>> build() => _fetch();

  AdminKategoriDatasource get _ds =>
      AdminKategoriDatasource(ref.read(dioClientProvider).dio);

  Future<List<KategoriModel>> _fetch() => _ds.getKategori();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> store({
    required String namaKategori,
    String? keterangan,
    int durasiPinjamDefault = 7,
  }) async {
    final item = await _ds.store(
      namaKategori: namaKategori,
      keterangan: keterangan,
      durasiPinjamDefault: durasiPinjamDefault,
    );
    state = state.whenData((list) => [...list, item]);
  }

  Future<void> updateItem({
    required int id,
    required String namaKategori,
    String? keterangan,
    int durasiPinjamDefault = 7,
  }) async {
    final item = await _ds.update(
      id: id,
      namaKategori: namaKategori,
      keterangan: keterangan,
      durasiPinjamDefault: durasiPinjamDefault,
    );
    state = state.whenData(
      (list) => list.map((k) => k.id == id ? item : k).toList(),
    );
  }

  Future<void> destroy(int id) async {
    await _ds.destroy(id);
    state = state.whenData((list) => list.where((k) => k.id != id).toList());
  }
}
