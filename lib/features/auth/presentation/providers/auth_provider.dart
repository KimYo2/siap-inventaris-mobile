import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.role == 'admin';

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) => AuthState(
    user: clearUser ? null : (user ?? this.user),
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(secureStorageProvider);
    final userJson = await storage.getUser();
    final token = await storage.getToken();

    if (userJson != null && token != null) {
      final user = UserModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      return AuthState(user: user);
    }
    return const AuthState();
  }

  Future<void> login(String nip, String password) async {
    state = const AsyncValue.loading();

    final storage = ref.read(secureStorageProvider);
    final dioClient = ref.read(dioClientProvider);
    final dataSource = AuthRemoteDataSource(dioClient.dio);

    state = await AsyncValue.guard(() async {
      final result = await dataSource.login(nip: nip, password: password);
      await storage.saveToken(result.token);
      await storage.saveUser(result.user.toJsonString());
      return AuthState(user: result.user);
    });
  }

  Future<void> logout() async {
    final dioClient = ref.read(dioClientProvider);
    final dataSource = AuthRemoteDataSource(dioClient.dio);
    await dataSource.logout(dioClient.dio);

    await ref.read(secureStorageProvider).clear();
    state = const AsyncValue.data(AuthState());
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
