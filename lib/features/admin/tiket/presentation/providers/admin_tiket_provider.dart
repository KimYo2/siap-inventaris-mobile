import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_tiket_datasource.dart';
import '../../data/models/tiket_model.dart';

class AdminTiketState {
  final List<TiketModel> items;
  final String? statusFilter;

  const AdminTiketState({required this.items, this.statusFilter});

  AdminTiketState copyWith({
    List<TiketModel>? items,
    Object? statusFilter = _sentinel,
  }) {
    return AdminTiketState(
      items: items ?? this.items,
      statusFilter: statusFilter == _sentinel
          ? this.statusFilter
          : statusFilter as String?,
    );
  }
}

const _sentinel = Object();

final adminTiketProvider =
    AsyncNotifierProvider<AdminTiketNotifier, AdminTiketState>(
      AdminTiketNotifier.new,
    );

class AdminTiketNotifier extends AsyncNotifier<AdminTiketState> {
  @override
  Future<AdminTiketState> build() async {
    final items = await _ds.getAll();
    return AdminTiketState(items: items);
  }

  AdminTiketDatasource get _ds =>
      AdminTiketDatasource(ref.read(dioClientProvider).dio);

  Future<void> setFilter(String? status) async {
    final current = state.valueOrNull;
    state = AsyncValue.data(
      AdminTiketState(items: current?.items ?? [], statusFilter: status),
    );
    final items = await _ds.getAll(status: status);
    state = state.whenData((s) => s.copyWith(items: items));
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    state = const AsyncValue.loading();
    try {
      final items = await _ds.getAll(status: current?.statusFilter);
      state = AsyncValue.data(
        AdminTiketState(items: items, statusFilter: current?.statusFilter),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus({
    required int id,
    required String status,
    String? priority,
    String? assignedTo,
    String? adminNotes,
  }) async {
    final item = await _ds.updateStatus(
      id: id,
      status: status,
      priority: priority,
      assignedTo: assignedTo,
      adminNotes: adminNotes,
    );
    state = state.whenData(
      (s) =>
          s.copyWith(items: s.items.map((t) => t.id == id ? item : t).toList()),
    );
  }

  Future<void> resolve({required int id, required String resolusi}) async {
    final item = await _ds.resolve(id: id, resolusi: resolusi);
    state = state.whenData(
      (s) =>
          s.copyWith(items: s.items.map((t) => t.id == id ? item : t).toList()),
    );
  }
}
