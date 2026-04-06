import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(height: 8),
                  Text(
                    user?.name ?? '-',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    user?.role ?? '-',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Barang'),
              onTap: () => context.go('/admin/barang'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histori'),
              onTap: () => context.go('/admin/histori'),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Stock Opname'),
              onTap: () => context.go('/admin/opname'),
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Tiket Kerusakan'),
              onTap: () => context.go('/admin/tiket'),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () => context.go('/admin/users'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kategori'),
              onTap: () => context.go('/admin/kategori'),
            ),
            ListTile(
              leading: const Icon(Icons.room),
              title: const Text('Ruangan'),
              onTap: () => context.go('/admin/ruangan'),
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Admin Dashboard — Coming Soon')),
    );
  }
}
