import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/histori_peminjaman_model.dart';
import '../providers/histori_provider.dart';

class HistoriScreen extends ConsumerStatefulWidget {
  const HistoriScreen({super.key});

  @override
  ConsumerState<HistoriScreen> createState() => _HistoriScreenState();
}

class _HistoriScreenState extends ConsumerState<HistoriScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(historiProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historiAsync = ref.watch(historiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Peminjaman')),
      body: historiAsync.when(
        data: (state) => RefreshIndicator(
          onRefresh: () => ref.read(historiProvider.notifier).refresh(),
          child: state.items.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada riwayat peminjaman.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return _HistoriCard(
                      item: state.items[index],
                      onExtend: () =>
                          _showExtendDialog(context, state.items[index]),
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(e.toString()),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(historiProvider.notifier).refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExtendDialog(
    BuildContext context,
    HistoriPeminjamanModel item,
  ) async {
    int selectedHari = 7;
    final alasanCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Ajukan Perpanjangan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barang: ${item.namaBarangDisplay}'),
              const SizedBox(height: 16),
              const Text('Perpanjangan (hari):'),
              Row(
                children: [7, 14, 30].map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$h hari'),
                      selected: selectedHari == h,
                      onSelected: (_) => setSt(() => selectedHari = h),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alasanCtrl,
                decoration: const InputDecoration(
                  labelText: 'Alasan (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ajukan'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref
            .read(historiProvider.notifier)
            .extendLoan(
              id: item.id,
              hari: selectedHari,
              alasan: alasanCtrl.text.trim().isEmpty
                  ? null
                  : alasanCtrl.text.trim(),
            );
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Perpanjangan berhasil diajukan.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ── Histori Card ──────────────────────────────────────────────────────────────

class _HistoriCard extends StatelessWidget {
  final HistoriPeminjamanModel item;
  final VoidCallback onExtend;

  const _HistoriCard({required this.item, required this.onExtend});

  Color _statusColor(String status) => switch (status) {
    'dipinjam' => Colors.amber,
    'menunggu' => Colors.blue,
    'ditolak' => Colors.red,
    'dikembalikan' => Colors.green,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    final fmt = DateFormat('dd MMM yyyy', 'id');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.namaBarangDisplay,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: item.status, color: color),
              ],
            ),
            const SizedBox(height: 8),

            // Info rows
            _InfoRow(
              icon: Icons.qr_code,
              text: '${item.kodeBarang} — NUP: ${item.nup}',
            ),
            if (item.waktuPinjam != null)
              _InfoRow(
                icon: Icons.calendar_today,
                text: 'Dipinjam: ${_formatDate(item.waktuPinjam!, fmt)}',
              ),
            if (item.tanggalJatuhTempo != null)
              _InfoRow(
                icon: Icons.event_busy,
                text:
                    'Jatuh Tempo: ${_formatDate(item.tanggalJatuhTempo!, fmt)}',
                color: _isOverdue(item.tanggalJatuhTempo!, item.status)
                    ? Colors.red
                    : null,
              ),
            if (item.waktuKembali != null)
              _InfoRow(
                icon: Icons.assignment_turned_in_outlined,
                text: 'Dikembalikan: ${_formatDate(item.waktuKembali!, fmt)}',
              ),

            // Perpanjangan status
            if (item.perpanjanganStatus != null &&
                item.perpanjanganStatus != '') ...[
              const Divider(height: 16),
              _InfoRow(
                icon: Icons.update,
                text:
                    'Perpanjangan: ${_perpanjanganLabel(item.perpanjanganStatus!)}',
                color: _perpanjanganColor(item.perpanjanganStatus!),
              ),
            ],

            // Extend button (only for active loans)
            if (item.status == 'dipinjam' &&
                item.perpanjanganStatus != 'menunggu') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onExtend,
                  icon: const Icon(Icons.more_time, size: 16),
                  label: const Text('Ajukan Perpanjangan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw, DateFormat fmt) {
    try {
      return fmt.format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  bool _isOverdue(String deadline, String status) {
    if (status != 'dipinjam') return false;
    try {
      return DateTime.parse(deadline).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _perpanjanganLabel(String s) => switch (s) {
    'menunggu' => 'Menunggu Persetujuan',
    'disetujui' => 'Disetujui',
    'ditolak' => 'Ditolak',
    _ => s,
  };

  Color _perpanjanganColor(String s) => switch (s) {
    'menunggu' => Colors.orange,
    'disetujui' => Colors.green,
    'ditolak' => Colors.red,
    _ => Colors.grey,
  };
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  String get label => switch (status) {
    'dipinjam' => 'Dipinjam',
    'menunggu' => 'Menunggu',
    'ditolak' => 'Ditolak',
    'dikembalikan' => 'Dikembalikan',
    _ => status,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: color)),
          ),
        ],
      ),
    );
  }
}
