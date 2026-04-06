import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/kategori_model.dart';
import '../providers/admin_kategori_provider.dart';

class AdminKategoriScreen extends ConsumerWidget {
  const AdminKategoriScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kategoriAsync = ref.watch(adminKategoriProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminKategoriProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showDialog(context, ref, null),
      ),
      body: kategoriAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada kategori.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(adminKategoriProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _KategoriCard(
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
                    ref.read(adminKategoriProvider.notifier).refresh(),
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
    KategoriModel? item,
  ) async {
    final namaCtrl = TextEditingController(text: item?.namaKategori ?? '');
    final keteranganCtrl = TextEditingController(text: item?.keterangan ?? '');
    final durasiCtrl = TextEditingController(
      text: '${item?.durasiPinjamDefault ?? 7}',
    );
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: keteranganCtrl,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durasiCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Durasi Pinjam Default (hari)',
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
    if (namaCtrl.text.trim().isEmpty) return;

    try {
      final durasi = int.tryParse(durasiCtrl.text.trim()) ?? 7;
      if (item == null) {
        await ref
            .read(adminKategoriProvider.notifier)
            .store(
              namaKategori: namaCtrl.text.trim(),
              keterangan: keteranganCtrl.text.trim().isEmpty
                  ? null
                  : keteranganCtrl.text.trim(),
              durasiPinjamDefault: durasi,
            );
      } else {
        await ref
            .read(adminKategoriProvider.notifier)
            .updateItem(
              id: item.id,
              namaKategori: namaCtrl.text.trim(),
              keterangan: keteranganCtrl.text.trim().isEmpty
                  ? null
                  : keteranganCtrl.text.trim(),
              durasiPinjamDefault: durasi,
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
    KategoriModel item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Hapus "${item.namaKategori}"?'),
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
      await ref.read(adminKategoriProvider.notifier).destroy(item.id);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Kategori dihapus.'),
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

class _KategoriCard extends StatelessWidget {
  final KategoriModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _KategoriCard({
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
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.category_outlined,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          item.namaKategori,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Durasi: ${item.durasiPinjamDefault} hari'
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
