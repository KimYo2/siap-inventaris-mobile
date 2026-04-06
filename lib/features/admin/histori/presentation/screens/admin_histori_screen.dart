import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/widgets/admin_scaffold.dart';
import '../../../../histori/data/models/histori_peminjaman_model.dart';
import '../providers/admin_histori_provider.dart';

class AdminHistoriScreen extends ConsumerWidget {
  const AdminHistoriScreen({super.key});

  static const _filters = [
    ('menunggu', 'Menunggu'),
    ('dipinjam', 'Dipinjam'),
    ('dikembalikan', 'Dikembalikan'),
    ('ditolak', 'Ditolak'),
    ('', 'Semua'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historiAsync = ref.watch(adminHistoriProvider);
    final currentFilter = historiAsync.valueOrNull?.statusFilter ?? 'menunggu';

    return AdminScaffold(
      title: 'Histori Peminjaman',
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _filters
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f.$2),
                        selected: currentFilter == f.$1,
                        onSelected: (_) => ref
                            .read(adminHistoriProvider.notifier)
                            .setFilter(f.$1),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: historiAsync.when(
              data: (state) {
                final items = state.items;
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada data.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminHistoriProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _HistoriAdminCard(item: items[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(e.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.read(adminHistoriProvider.notifier).refresh(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoriAdminCard extends ConsumerWidget {
  final HistoriPeminjamanModel item;
  const _HistoriAdminCard({required this.item});

  Color _statusColor(String status) => switch (status) {
    'menunggu' => Colors.orange,
    'dipinjam' => Colors.blue,
    'dikembalikan' => Colors.green,
    'ditolak' => Colors.red,
    _ => Colors.grey,
  };

  String _statusLabel(String status) => switch (status) {
    'menunggu' => 'Menunggu',
    'dipinjam' => 'Dipinjam',
    'dikembalikan' => 'Dikembalikan',
    'ditolak' => 'Ditolak',
    _ => status,
  };

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Setujui Peminjaman'),
        content: Text(
          'Setujui peminjaman ${item.kodeBarang}-${item.nup} oleh ${item.namaPeminjam}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminHistoriProvider.notifier).approve(item.id);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Peminjaman disetujui.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tolak Peminjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tolak peminjaman ${item.kodeBarang}-${item.nup} oleh ${item.namaPeminjam}?',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan penolakan (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(adminHistoriProvider.notifier)
          .reject(
            item.id,
            reason: reasonController.text.trim().isEmpty
                ? null
                : reasonController.text.trim(),
          );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Peminjaman ditolak.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _approveExtend(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Setujui Perpanjangan'),
        content: Text(
          'Setujui perpanjangan ${item.perpanjanganHari ?? 0} hari untuk ${item.namaPeminjam}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminHistoriProvider.notifier).approveExtend(item.id);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Perpanjangan disetujui.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(item.status);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.kodeBarang}-${item.nup}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 0.8),
                  ),
                  child: Text(
                    _statusLabel(item.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (item.namaBarang != null ||
                (item.brand != null && item.tipe != null))
              Text(
                item.namaBarang ?? '${item.brand} ${item.tipe}',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${item.namaPeminjam} (${item.nipPeminjam})',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            if (item.waktuPengajuan != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Diajukan: ${item.waktuPengajuan!.substring(0, 16)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
            if (item.tanggalJatuhTempo != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.event, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Jatuh tempo: ${item.tanggalJatuhTempo!.substring(0, 10)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
            if (item.perpanjanganStatus == 'menunggu') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.more_time, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Perpanjangan ${item.perpanjanganHari ?? 0} hari'
                        '${item.perpanjanganAlasan != null ? ': ${item.perpanjanganAlasan}' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (item.status == 'menunggu') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _reject(context, ref),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _approve(context, ref),
                      child: const Text('Setujui'),
                    ),
                  ),
                ],
              ),
            ] else if (item.perpanjanganStatus == 'menunggu') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _approveExtend(context, ref),
                      child: const Text('Tolak Perpanjangan'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _approveExtend(context, ref),
                      child: const Text('Setujui Perpanjangan'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
