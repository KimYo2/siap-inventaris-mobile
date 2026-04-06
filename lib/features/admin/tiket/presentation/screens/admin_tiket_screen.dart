import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/widgets/admin_scaffold.dart';
import '../../data/models/tiket_model.dart';
import '../providers/admin_tiket_provider.dart';

class AdminTiketScreen extends ConsumerWidget {
  const AdminTiketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiketAsync = ref.watch(adminTiketProvider);

    return AdminScaffold(
      title: 'Tiket Kerusakan',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(adminTiketProvider.notifier).refresh(),
        ),
      ],
      body: tiketAsync.when(
        data: (state) => Column(
          children: [
            _FilterBar(
              current: state.statusFilter,
              onSelect: (s) =>
                  ref.read(adminTiketProvider.notifier).setFilter(s),
            ),
            Expanded(
              child: state.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada tiket.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(adminTiketProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.items.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _TiketCard(
                          item: state.items[i],
                          onUpdateStatus: () =>
                              _showUpdateSheet(ctx, ref, state.items[i]),
                          onResolve: state.items[i].status != 'selesai'
                              ? () =>
                                    _showResolveDialog(ctx, ref, state.items[i])
                              : null,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(adminTiketProvider.notifier).refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateSheet(
    BuildContext context,
    WidgetRef ref,
    TiketModel item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    String selectedStatus = item.status;
    String selectedPriority = item.priority;
    final assignedCtrl = TextEditingController(text: item.assignedTo ?? '');
    final notesCtrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Tiket #${item.id}',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const Text('Status'),
              Wrap(
                spacing: 8,
                children: ['open', 'diproses', 'selesai'].map((s) {
                  return ChoiceChip(
                    label: Text(s),
                    selected: selectedStatus == s,
                    onSelected: (_) => setState(() => selectedStatus = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text('Prioritas'),
              Wrap(
                spacing: 8,
                children: ['low', 'medium', 'high'].map((p) {
                  return ChoiceChip(
                    label: Text(p),
                    selected: selectedPriority == p,
                    onSelected: (_) => setState(() => selectedPriority = p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: assignedCtrl,
                decoration: const InputDecoration(
                  labelText: 'Assigned To',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Admin Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(adminTiketProvider.notifier)
          .updateStatus(
            id: item.id,
            status: selectedStatus,
            priority: selectedPriority,
            assignedTo: assignedCtrl.text.trim().isEmpty
                ? null
                : assignedCtrl.text.trim(),
            adminNotes: notesCtrl.text.trim().isEmpty
                ? null
                : notesCtrl.text.trim(),
          );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Status diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showResolveDialog(
    BuildContext context,
    WidgetRef ref,
    TiketModel item,
  ) async {
    final resolusiCtrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Selesaikan Tiket #${item.id}'),
        content: TextField(
          controller: resolusiCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Resolusi *',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
    if (confirmed != true || resolusiCtrl.text.trim().isEmpty) return;

    try {
      await ref
          .read(adminTiketProvider.notifier)
          .resolve(id: item.id, resolusi: resolusiCtrl.text.trim());
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tiket diselesaikan.'),
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

class _FilterBar extends StatelessWidget {
  final String? current;
  final void Function(String?) onSelect;

  static const _statusOptions = [null, 'open', 'diproses', 'selesai'];
  static const _statusLabels = ['Semua', 'Open', 'Diproses', 'Selesai'];

  const _FilterBar({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _statusOptions.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) => FilterChip(
          label: Text(_statusLabels[i]),
          selected: current == _statusOptions[i],
          onSelected: (_) => onSelect(_statusOptions[i]),
        ),
      ),
    );
  }
}

class _TiketCard extends StatelessWidget {
  final TiketModel item;
  final VoidCallback onUpdateStatus;
  final VoidCallback? onResolve;

  const _TiketCard({
    required this.item,
    required this.onUpdateStatus,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.jenisKerusakan,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.priorityColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: item.priorityColor),
                  ),
                  child: Text(
                    item.priorityLabel,
                    style: TextStyle(
                      color: item.priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: item.statusColor),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: TextStyle(
                      color: item.statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'BMN: ${item.nomorBmn} · Pelapor: ${item.pelapor}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Tanggal: ${item.tanggalLapor}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.deskripsi!,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (item.resolusi != null && item.resolusi!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Resolusi: ${item.resolusi}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('Update'),
                  onPressed: onUpdateStatus,
                ),
                if (onResolve != null) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Selesai'),
                    onPressed: onResolve,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
