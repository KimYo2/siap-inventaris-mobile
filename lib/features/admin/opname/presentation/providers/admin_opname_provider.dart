import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_opname_datasource.dart';
import '../../data/models/opname_session_model.dart';

final adminOpnameProvider =
    AsyncNotifierProvider<AdminOpnameNotifier, List<OpnameSessionModel>>(
      AdminOpnameNotifier.new,
    );

class AdminOpnameNotifier extends AsyncNotifier<List<OpnameSessionModel>> {
  @override
  Future<List<OpnameSessionModel>> build() => _fetch();

  AdminOpnameRemoteDataSource get _ds =>
      AdminOpnameRemoteDataSource(ref.read(dioClientProvider).dio);

  Future<List<OpnameSessionModel>> _fetch() => _ds.getSessions();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<OpnameSessionModel> startSession({
    required String nama,
    String? notes,
  }) async {
    final session = await _ds.startSession(nama: nama, notes: notes);
    state = state.whenData((list) => [session, ...list]);
    return session;
  }

  Future<Map<String, dynamic>> scanItem({
    required int sessionId,
    required String nomorBmn,
  }) => _ds.scanItem(sessionId: sessionId, nomorBmn: nomorBmn);

  Future<void> finishSession(int sessionId) async {
    await _ds.finishSession(sessionId);
    await refresh();
  }
}
