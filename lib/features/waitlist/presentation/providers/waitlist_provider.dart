import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/waitlist_remote_datasource.dart';
import '../../data/models/waitlist_item_model.dart';

final waitlistProvider =
    AsyncNotifierProvider<WaitlistNotifier, List<WaitlistItemModel>>(
      WaitlistNotifier.new,
    );

class WaitlistNotifier extends AsyncNotifier<List<WaitlistItemModel>> {
  @override
  Future<List<WaitlistItemModel>> build() => _fetch();

  WaitlistRemoteDataSource get _ds =>
      WaitlistRemoteDataSource(ref.read(dioClientProvider).dio);

  Future<List<WaitlistItemModel>> _fetch() => _ds.getMyWaitlist();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> cancel(int id) async {
    await _ds.cancelWaitlist(id);
    state = state.whenData(
      (list) => list.where((item) => item.id != id).toList(),
    );
  }
}
