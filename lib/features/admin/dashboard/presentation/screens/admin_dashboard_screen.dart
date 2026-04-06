import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/admin_dashboard_model.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull?.user;
    final dashAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(adminDashboardProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      drawer: _AdminDrawer(user: user),
      body: dashAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(adminDashboardProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsGrid(data: data),
                const SizedBox(height: 24),
                if (data.overdueCount > 0) ...[
                  _OverdueSection(data: data),
                  const SizedBox(height: 24),
                ],
                _TopItemsSection(items: data.topItems),
                const SizedBox(height: 24),
                _TopBorrowersSection(borrowers: data.topBorrowers),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(e.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.read(adminDashboardProvider.notifier).refresh(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drawer
// ---------------------------------------------------------------------------
class _AdminDrawer extends StatelessWidget {
  final dynamic user;
  const _AdminDrawer({this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => context.go('/admin/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histori Peminjaman'),
            onTap: () => context.go('/admin/histori'),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Stock Opname'),
            onTap: () => context.go('/admin/opname'),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Barang'),
            onTap: () => context.go('/admin/barang'),
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: const Text('Tiket Kerusakan'),
            onTap: () => context.go('/admin/tiket'),
          ),
          ListTile(
            leading: const Icon(Icons.people_outlined),
            title: const Text('Users'),
            onTap: () => context.go('/admin/users'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Kategori'),
            onTap: () => context.go('/admin/kategori'),
          ),
          ListTile(
            leading: const Icon(Icons.room_outlined),
            title: const Text('Ruangan'),
            onTap: () => context.go('/admin/ruangan'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats grid
// ---------------------------------------------------------------------------
class _StatsGrid extends StatelessWidget {
  final AdminDashboardModel data;
  const _StatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          label: 'Total Barang',
          value: '${data.totalBarang}',
          icon: Icons.inventory_2_outlined,
          color: Colors.blue,
        ),
        _StatCard(
          label: 'Tersedia',
          value: '${data.tersedia}',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        _StatCard(
          label: 'Dipinjam',
          value: '${data.dipinjam}',
          icon: Icons.handshake_outlined,
          color: Colors.orange,
        ),
        _StatCard(
          label: 'Overdue',
          value: '${data.overdueCount}',
          icon: Icons.warning_amber_outlined,
          color: Colors.red,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overdue section
// ---------------------------------------------------------------------------
class _OverdueSection extends StatelessWidget {
  final AdminDashboardModel data;
  const _OverdueSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.red, size: 20),
            const SizedBox(width: 6),
            Text(
              'Overdue (${data.overdueCount})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...data.overdueList.map(
          (item) => Card(
            color: Colors.red.withValues(alpha: 0.06),
            child: ListTile(
              leading: const Icon(Icons.schedule, color: Colors.red),
              title: Text(
                '${item.kodeBarang}-${item.nup}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(item.namaPeminjam),
              trailing: item.tanggalJatuhTempo != null
                  ? Text(
                      item.tanggalJatuhTempo!.substring(0, 10),
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    )
                  : null,
              dense: true,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Top items
// ---------------------------------------------------------------------------
class _TopItemsSection extends StatelessWidget {
  final List<TopItemModel> items;
  const _TopItemsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Barang Paling Sering Dipinjam',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map(
          (e) => ListTile(
            leading: CircleAvatar(
              radius: 16,
              child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12)),
            ),
            title: Text(e.value.namaDisplay),
            subtitle: Text('${e.value.kodeBarang}-${e.value.nup}'),
            trailing: Text(
              '${e.value.total}x',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Top borrowers
// ---------------------------------------------------------------------------
class _TopBorrowersSection extends StatelessWidget {
  final List<TopBorrowerModel> borrowers;
  const _TopBorrowersSection({required this.borrowers});

  @override
  Widget build(BuildContext context) {
    if (borrowers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Peminjam Tertinggi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...borrowers.asMap().entries.map(
          (e) => ListTile(
            leading: CircleAvatar(
              radius: 16,
              child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12)),
            ),
            title: Text(e.value.namaPeminjam),
            subtitle: Text(e.value.nipPeminjam),
            trailing: Text(
              '${e.value.total}x',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
