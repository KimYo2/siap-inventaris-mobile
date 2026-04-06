import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/dio_client.dart';
import '../../data/datasources/admin_users_datasource.dart';
import '../../data/models/user_admin_model.dart';

final adminUsersProvider =
    AsyncNotifierProvider<AdminUsersNotifier, List<UserAdminModel>>(
      AdminUsersNotifier.new,
    );

class AdminUsersNotifier extends AsyncNotifier<List<UserAdminModel>> {
  @override
  Future<List<UserAdminModel>> build() => _fetch();

  AdminUsersDatasource get _ds =>
      AdminUsersDatasource(ref.read(dioClientProvider).dio);

  Future<List<UserAdminModel>> _fetch() => _ds.getAll();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> store({
    required String nip,
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final item = await _ds.store(
      nip: nip,
      name: name,
      email: email,
      password: password,
      role: role,
    );
    state = state.whenData((list) => [...list, item]);
  }

  Future<void> updateItem({
    required int id,
    required String nip,
    required String name,
    required String email,
    String? password,
    String role = 'user',
  }) async {
    final item = await _ds.updateUser(
      id: id,
      nip: nip,
      name: name,
      email: email,
      password: password,
      role: role,
    );
    state = state.whenData(
      (list) => list.map((u) => u.id == id ? item : u).toList(),
    );
  }
}
