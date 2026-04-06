import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/widgets/admin_scaffold.dart';
import '../../data/models/ruangan_model.dart';
import '../providers/admin_ruangan_provider.dart';

class AdminRuanganScreen extends ConsumerWidget {
  const AdminRuanganScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruanganAsync = ref.watch(adminRuanganProvider);

    return AdminScaffold(
      title: 'Ruangan',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(adminRuanganProvider.notifier).refresh(),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showDialog(context, ref, null),
      ),
      body: ruanganAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada ruangan.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(adminRuanganProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _RuanganCard(
                item: list[i],
                onEdit: () => _showDialog(ctx, ref, list[i]),
                onDelete: () => _delete(ctx, ref, list[i]),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(adminRuanganProvider.notifier).refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDialog(
    BuildContext context,
    WidgetRef ref,
    RuanganModel? item,
  ) async {
    final kodeCtrl = TextEditingController(text: item?.kodeRuangan ?? '');
    final namaCtrl = TextEditingController(text: item?.namaRuangan ?? '');
    final lantaiCtrl = TextEditingController(text: item?.lantai ?? '');
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Tambah Ruangan' : 'Edit Ruangan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kodeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kode Ruangan *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Ruangan *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lantaiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lantai',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (kodeCtrl.text.trim().isEmpty || namaCtrl.text.trim().isEmpty) return;

    try {
      final lantai = lantaiCtrl.text.trim().isEmpty
          ? null
          : lantaiCtrl.text.trim();
      if (item == null) {
        await ref
            .read(adminRuanganProvider.notifier)
            .store(
              kodeRuangan: kodeCtrl.text.trim(),
              namaRuangan: namaCtrl.text.trim(),
              lantai: lantai,
            );
      } else {
        await ref
            .read(adminRuanganProvider.notifier)
            .updateItem(
              id: item.id,
              kodeRuangan: kodeCtrl.text.trim(),
              namaRuangan: namaCtrl.text.trim(),
              lantai: lantai,
            );
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Berhasil disimpan.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    RuanganModel item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Ruangan'),
        content: Text('Hapus "${item.namaRuangan}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminRuanganProvider.notifier).destroy(item.id);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Ruangan dihapus.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}

class _RuanganCard extends StatelessWidget {
  final RuanganModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _RuanganCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(
            Icons.room_outlined,
            color: colorScheme.onSecondaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          item.namaRuangan,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Kode: ${item.kodeRuangan}'
          '${item.lantai != null ? ' · Lantai ${item.lantai}' : ''}'
          '${item.barangCount != null ? ' · ${item.barangCount} barang' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Hapus',
            ),
          ],
        ),
      ),
    );
  }
}
