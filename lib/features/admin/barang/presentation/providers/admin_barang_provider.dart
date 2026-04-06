import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../barang/data/models/barang_model.dart';
import '../../data/datasources/admin_barang_datasource.dart';

class AdminBarangState {
  final List<BarangModel> items;
  final String? ketersediaanFilter;
  final String search;

  const AdminBarangState({
    required this.items,
    this.ketersediaanFilter,
    this.search = '',
  });

  AdminBarangState copyWith({
    List<BarangModel>? items,
    Object? ketersediaanFilter = _sentinel,
    String? search,
  }) {
    return AdminBarangState(
      items: items ?? this.items,
      ketersediaanFilter: ketersediaanFilter == _sentinel
          ? this.ketersediaanFilter
          : ketersediaanFilter as String?,
      search: search ?? this.search,
    );
  }
}

const _sentinel = Object();

final adminBarangAdminProvider =
    AsyncNotifierProvider<AdminBarangNotifier, AdminBarangState>(
      AdminBarangNotifier.new,
    );

class AdminBarangNotifier extends AsyncNotifier<AdminBarangState> {
  @override
  Future<AdminBarangState> build() async {
    final items = await _ds.getAll();
    return AdminBarangState(items: items);
  }

  AdminBarangDatasource get _ds =>
      AdminBarangDatasource(ref.read(dioClientProvider).dio);

  Future<void> setFilter({
    Object? ketersediaan = _sentinel,
    String? search,
  }) async {
    final current = state.valueOrNull;
    final newKetersediaan = ketersediaan == _sentinel
        ? current?.ketersediaanFilter
        : ketersediaan as String?;
    final newSearch = search ?? current?.search ?? '';

    state = AsyncValue.data(
      AdminBarangState(
        items: current?.items ?? [],
        ketersediaanFilter: newKetersediaan,
        search: newSearch,
      ),
    );
    final items = await _ds.getAll(
      ketersediaan: newKetersediaan,
      search: newSearch.isEmpty ? null : newSearch,
    );
    state = state.whenData((s) => s.copyWith(items: items));
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    state = const AsyncValue.loading();
    try {
      final items = await _ds.getAll(
        ketersediaan: current?.ketersediaanFilter,
        search: current?.search.isNotEmpty == true ? current?.search : null,
      );
      state = AsyncValue.data(
        AdminBarangState(
          items: items,
          ketersediaanFilter: current?.ketersediaanFilter,
          search: current?.search ?? '',
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus({
    required int id,
    required String kondisi,
    String? catatan,
  }) async {
    final item = await _ds.updateStatus(
      id: id,
      kondisi: kondisi,
      catatan: catatan,
    );
    state = state.whenData(
      (s) =>
          s.copyWith(items: s.items.map((b) => b.id == id ? item : b).toList()),
    );
  }
}
