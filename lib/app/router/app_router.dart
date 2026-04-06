import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

// User screens
import '../../features/dashboard/presentation/screens/user_dashboard_screen.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/histori/presentation/screens/histori_screen.dart';
import '../../features/notifikasi/presentation/screens/notifikasi_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/return_barang/presentation/screens/return_screen.dart';
import '../../features/barang/presentation/screens/barang_detail_screen.dart';
import '../../features/waitlist/presentation/screens/waitlist_screen.dart';

// Admin screens
import '../../features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/barang/presentation/screens/admin_barang_screen.dart';
import '../../features/admin/histori/presentation/screens/admin_histori_screen.dart';
import '../../features/admin/opname/presentation/screens/admin_opname_screen.dart';
import '../../features/admin/tiket/presentation/screens/admin_tiket_screen.dart';
import '../../features/admin/users/presentation/screens/admin_user_screen.dart';
import '../../features/admin/kategori/presentation/screens/admin_kategori_screen.dart';
import '../../features/admin/ruangan/presentation/screens/admin_ruangan_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = authNotifier.valueOrNull;
      final isLoading = authNotifier.isLoading;

      if (isLoading) return null;

      final isLoggedIn = auth?.isAuthenticated ?? false;
      final isLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) {
        return (auth!.isAdmin) ? '/admin/dashboard' : '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),

      // ── USER ROUTES ──────────────────────────────────────────────────────
      GoRoute(
        path: '/dashboard',
        builder: (_, _) => const UserDashboardScreen(),
      ),
      GoRoute(path: '/scan', builder: (_, _) => const ScanScreen()),
      GoRoute(path: '/histori', builder: (_, _) => const HistoriScreen()),
      GoRoute(
        path: '/notifikasi',
        builder: (_, _) => const NotifikasiScreen(),
      ),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/return', builder: (_, _) => const ReturnScreen()),
      GoRoute(path: '/waitlist', builder: (_, _) => const WaitlistScreen()),
      GoRoute(
        path: '/barang/:nomor_bmn',
        builder: (_, state) =>
            BarangDetailScreen(nomorBmn: state.pathParameters['nomor_bmn']!),
      ),

      // ── ADMIN ROUTES ─────────────────────────────────────────────────────
      GoRoute(
        path: '/admin/dashboard',
        builder: (_, _) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/barang',
        builder: (_, _) => const AdminBarangScreen(),
      ),
      GoRoute(
        path: '/admin/histori',
        builder: (_, _) => const AdminHistoriScreen(),
      ),
      GoRoute(
        path: '/admin/opname',
        builder: (_, _) => const AdminOpnameScreen(),
      ),
      GoRoute(
        path: '/admin/tiket',
        builder: (_, _) => const AdminTiketScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (_, _) => const AdminUserScreen(),
      ),
      GoRoute(
        path: '/admin/kategori',
        builder: (_, _) => const AdminKategoriScreen(),
      ),
      GoRoute(
        path: '/admin/ruangan',
        builder: (_, _) => const AdminRuanganScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
    ),
  );
});
