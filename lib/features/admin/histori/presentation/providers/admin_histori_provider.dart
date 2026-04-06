import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_histori_datasource.dart';
import '../../../../histori/data/models/histori_peminjaman_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class AdminHistoriState {
  final List<HistoriPeminjamanModel> items;
  final String
  statusFilter; // '' | menunggu | dipinjam | dikembalikan | ditolak
  final String search;
  final bool isLoadingMore;

  const AdminHistoriState({
    this.items = const [],
    this.statusFilter = 'menunggu',
    this.search = '',
    this.isLoadingMore = false,
  });

  AdminHistoriState copyWith({
    List<HistoriPeminjamanModel>? items,
    String? statusFilter,
    String? search,
    bool? isLoadingMore,
  }) => AdminHistoriState(
    items: items ?? this.items,
    statusFilter: statusFilter ?? this.statusFilter,
    search: search ?? this.search,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

final adminHistoriProvider =
    AsyncNotifierProvider<AdminHistoriNotifier, AdminHistoriState>(
      AdminHistoriNotifier.new,
    );

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class AdminHistoriNotifier extends AsyncNotifier<AdminHistoriState> {
  @override
  Future<AdminHistoriState> build() async {
    const initial = AdminHistoriState();
    final items = await _ds.getHistori(page: 1, status: initial.statusFilter);
    return initial.copyWith(items: items);
  }

  AdminHistoriRemoteDataSource get _ds =>
      AdminHistoriRemoteDataSource(ref.read(dioClientProvider).dio);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = state.valueOrNull ?? const AdminHistoriState();
      final items = await _ds.getHistori(
        page: 1,
        status: current.statusFilter,
        search: current.search,
      );
      return current.copyWith(items: items);
    });
  }

  Future<void> setFilter(String statusFilter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final items = await _ds.getHistori(
        page: 1,
        status: statusFilter,
        search: state.valueOrNull?.search ?? '',
      );
      return AdminHistoriState(statusFilter: statusFilter, items: items);
    });
  }

  Future<void> approve(int id) async {
    await _ds.approve(id);
    await refresh();
  }

  Future<void> reject(int id, {String? reason}) async {
    await _ds.reject(id, reason: reason);
    await refresh();
  }

  Future<void> approveExtend(int id) async {
    await _ds.approveExtend(id);
    await refresh();
  }

  Future<void> rejectExtend(int id, {String? reason}) async {
    await _ds.rejectExtend(id, reason: reason);
    await refresh();
  }
}
