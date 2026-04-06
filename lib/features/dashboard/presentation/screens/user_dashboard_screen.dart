import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/double_back_to_exit.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/dashboard_summary_model.dart';
import '../providers/dashboard_provider.dart';

class UserDashboardScreen extends ConsumerWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull?.user;
    final dashAsync = ref.watch(dashboardProvider);

    return DoubleBackToExit(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SIAP Inventaris'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifikasi'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => ref.read(authProvider.notifier).logout(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _GreetingHeader(name: user?.name ?? '-'),
              ),
              dashAsync.when(
                data: (data) => SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _StatCards(summary: data),
                      const SizedBox(height: 20),
                      _QuickActions(),
                      const SizedBox(height: 20),
                      if (data.overdueLoans > 0) ...[
                        _OverdueBanner(count: data.overdueLoans),
                        const SizedBox(height: 16),
                      ],
                      _RecentLoansSection(loans: data.recentLoans),
                    ]),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(e.toString()),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              ref.read(dashboardProvider.notifier).refresh(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            NavigationDestination(icon: Icon(Icons.history), label: 'Histori'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
          ],
          onDestinationSelected: (i) {
            switch (i) {
              case 1:
                context.go('/scan');
                break;
              case 2:
                context.go('/histori');
                break;
              case 3:
                context.go('/profile');
                break;
            }
          },
        ),
      ),
    );
  }
}

// ── Greeting ──────────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String name;
  const _GreetingHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $name!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selamat datang di SIAP Inventaris',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ── Stat Cards ────────────────────────────────────────────────────────────────

class _StatCards extends StatelessWidget {
  final DashboardSummary summary;
  const _StatCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Dipinjam',
            value: summary.activeLoans.toString(),
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Total Histori',
            value: summary.totalLoans.toString(),
            icon: Icons.history,
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Jatuh Tempo',
            value: summary.overdueLoans.toString(),
            icon: Icons.warning_amber_rounded,
            color: summary.overdueLoans > 0 ? Colors.red : Colors.green,
          ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Scan Barang',
              onTap: () => context.push('/scan'),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.assignment_return,
              label: 'Kembalikan',
              onTap: () => context.push('/return'),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.list_alt,
              label: 'Histori',
              onTap: () => context.push('/histori'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Overdue Banner ────────────────────────────────────────────────────────────

class _OverdueBanner extends StatelessWidget {
  final int count;
  const _OverdueBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kamu memiliki $count peminjaman yang sudah melewati jatuh tempo!',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Loans ──────────────────────────────────────────────────────────────

class _RecentLoansSection extends StatelessWidget {
  final List<HistoriSingkat> loans;
  const _RecentLoansSection({required this.loans});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peminjaman Terbaru',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (loans.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada riwayat peminjaman.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...loans.map((loan) => _LoanTile(loan: loan)),
      ],
    );
  }
}

class _LoanTile extends StatelessWidget {
  final HistoriSingkat loan;
  const _LoanTile({required this.loan});

  Color _statusColor(String status) => switch (status) {
    'dipinjam' => Colors.amber,
    'menunggu' => Colors.blue,
    'ditolak' => Colors.red,
    'dikembalikan' => Colors.green,
    _ => Colors.grey,
  };

  String _statusLabel(String status) => switch (status) {
    'dipinjam' => 'Dipinjam',
    'menunggu' => 'Menunggu',
    'ditolak' => 'Ditolak',
    'dikembalikan' => 'Dikembalikan',
    _ => status,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(loan.status).withValues(alpha: 0.15),
          child: Icon(
            Icons.inventory_2_outlined,
            color: _statusColor(loan.status),
          ),
        ),
        title: Text(
          loan.namaDisplay,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'NUP: ${loan.nup}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(loan.status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _statusLabel(loan.status),
            style: TextStyle(
              color: _statusColor(loan.status),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
