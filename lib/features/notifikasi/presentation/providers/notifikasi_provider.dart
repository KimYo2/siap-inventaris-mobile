import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/notifikasi_remote_datasource.dart';
import '../../data/models/notifikasi_model.dart';

final notifikasiProvider =
    AsyncNotifierProvider<NotifikasiNotifier, List<NotifikasiModel>>(
      NotifikasiNotifier.new,
    );

class NotifikasiNotifier extends AsyncNotifier<List<NotifikasiModel>> {
  @override
  Future<List<NotifikasiModel>> build() => _fetch();

  NotifikasiRemoteDataSource get _ds =>
      NotifikasiRemoteDataSource(ref.read(dioClientProvider).dio);

  Future<List<NotifikasiModel>> _fetch() => _ds.getNotifikasi();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> markRead(int id) async {
    await _ds.markRead(id);
    // Update local state optimistically
    state = state.whenData(
      (list) => list
          .map(
            (n) => n.id == id
                ? NotifikasiModel(
                    id: n.id,
                    userId: n.userId,
                    judul: n.judul,
                    pesan: n.pesan,
                    type: n.type,
                    isRead: true,
                    relatedModel: n.relatedModel,
                    relatedId: n.relatedId,
                    createdAt: n.createdAt,
                  )
                : n,
          )
          .toList(),
    );
  }
}
