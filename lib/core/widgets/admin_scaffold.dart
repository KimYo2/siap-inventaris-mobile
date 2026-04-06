import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'double_back_to_exit.dart';

class AdminScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final PreferredSizeWidget? appBarBottom;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.appBarBottom,
    this.floatingActionButton,
  });

  static final _navItems = [
    (
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
      route: '/admin/dashboard',
    ),
    (icon: Icons.history, label: 'Histori', route: '/admin/histori'),
    (icon: Icons.qr_code_scanner, label: 'Opname', route: '/admin/opname'),
    (icon: Icons.inventory_2_outlined, label: 'Barang', route: '/admin/barang'),
    (icon: Icons.build_outlined, label: 'Tiket', route: '/admin/tiket'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final idx = _navItems.indexWhere((e) => e.route == currentLocation);

    return DoubleBackToExit(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.people_outlined),
            tooltip: 'Users',
            onPressed: () => context.go('/admin/users'),
          ),
          title: Text(title),
          bottom: appBarBottom,
          actions: [
            ...actions,
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'kategori':
                    context.go('/admin/kategori');
                  case 'ruangan':
                    context.go('/admin/ruangan');
                  case 'logout':
                    ref.read(authProvider.notifier).logout();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'kategori',
                  child: Row(
                    children: [
                      Icon(Icons.category_outlined),
                      SizedBox(width: 12),
                      Text('Kategori'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'ruangan',
                  child: Row(
                    children: [
                      Icon(Icons.room_outlined),
                      SizedBox(width: 12),
                      Text('Ruangan'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 12),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx < 0 ? 0 : idx,
          onDestinationSelected: (i) => context.go(_navItems[i].route),
          destinations: _navItems
              .map(
                (e) =>
                    NavigationDestination(icon: Icon(e.icon), label: e.label),
              )
              .toList(),
        ),
      ),
    );
  }
}
