import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull?.user;
    final colorScheme = Theme.of(context).colorScheme;
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.onPrimary,
                  child: Icon(Icons.person, color: colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.name ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.role ?? '-',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: '/admin/dashboard',
            currentLocation: currentLocation,
          ),
          _DrawerItem(
            icon: Icons.history,
            label: 'Histori Peminjaman',
            route: '/admin/histori',
            currentLocation: currentLocation,
          ),
          _DrawerItem(
            icon: Icons.qr_code_scanner,
            label: 'Stock Opname',
            route: '/admin/opname',
            currentLocation: currentLocation,
          ),
          _DrawerItem(
            icon: Icons.inventory_2_outlined,
            label: 'Barang',
            route: '/admin/barang',
            currentLocation: currentLocation,
          ),
          _DrawerItem(
            icon: Icons.build_outlined,
            label: 'Tiket Kerusakan',
            route: '/admin/tiket',
            currentLocation: currentLocation,
          ),
          _DrawerItem(
            icon: Icons.people_outlined,
            label: 'Users',
            route: '/admin/users',
            currentLocation: currentLocation,
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.category_outlined,
            label: 'Kategori',
            route: '/admin/kategori',
            currentLocation: currentLocation,
          ),
          _DrawerItem(
            icon: Icons.room_outlined,
            label: 'Ruangan',
            route: '/admin/ruangan',
            currentLocation: currentLocation,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentLocation;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentLocation == route;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: isSelected,
      onTap: () {
        Navigator.of(context).pop(); // tutup drawer
        if (!isSelected) context.go(route);
      },
    );
  }
}
