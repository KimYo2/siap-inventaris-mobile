import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'double_back_to_exit.dart';

class UserScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final PreferredSizeWidget? appBarBottom;
  final Widget? floatingActionButton;

  const UserScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.appBarBottom,
    this.floatingActionButton,
  });

  static final _navItems = [
    (icon: Icons.home_outlined, label: 'Home', route: '/dashboard'),
    (icon: Icons.qr_code_scanner, label: 'Scan', route: '/scan'),
    (icon: Icons.history, label: 'Histori', route: '/histori'),
    (icon: Icons.person_outlined, label: 'Profil', route: '/profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final idx = _navItems.indexWhere((e) => e.route == currentLocation);

    return DoubleBackToExit(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(title),
          bottom: appBarBottom,
          actions: [
            ...actions,
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifikasi',
              onPressed: () => context.push('/notifikasi'),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authProvider.notifier).logout();
                }
              },
              itemBuilder: (_) => [
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
