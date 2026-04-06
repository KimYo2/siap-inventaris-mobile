import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/histori_remote_datasource.dart';
import '../../data/models/histori_peminjaman_model.dart';
import '../../../../core/network/dio_client.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class HistoriState {
  final List<HistoriPeminjamanModel> items;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  const HistoriState({
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  HistoriState copyWith({
    List<HistoriPeminjamanModel>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) => HistoriState(
    items: items ?? this.items,
    currentPage: currentPage ?? this.currentPage,
    lastPage: lastPage ?? this.lastPage,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class HistoriNotifier extends AsyncNotifier<HistoriState> {
  @override
  Future<HistoriState> build() => _fetch(page: 1);

  Future<HistoriState> _fetch({required int page}) async {
    final dio = ref.read(dioClientProvider).dio;
    final result = await HistoriRemoteDataSource(dio).getHistori(page: page);
    return HistoriState(
      items: result.data,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(page: 1));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    final dio = ref.read(dioClientProvider).dio;
    try {
      final result = await HistoriRemoteDataSource(
        dio,
      ).getHistori(page: current.currentPage + 1);
      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...result.data],
          currentPage: result.currentPage,
          lastPage: result.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> extendLoan({
    required int id,
    required int hari,
    String? alasan,
  }) async {
    final dio = ref.read(dioClientProvider).dio;
    await HistoriRemoteDataSource(
      dio,
    ).extendLoan(id: id, hari: hari, alasan: alasan);
    refresh();
  }
}

final historiProvider = AsyncNotifierProvider<HistoriNotifier, HistoriState>(
  HistoriNotifier.new,
);
