import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/widgets/admin_scaffold.dart';
import '../../../../barang/data/models/barang_model.dart';
import '../providers/admin_barang_provider.dart';

class AdminBarangScreen extends ConsumerStatefulWidget {
  const AdminBarangScreen({super.key});

  @override
  ConsumerState<AdminBarangScreen> createState() => _AdminBarangScreenState();
}

class _AdminBarangScreenState extends ConsumerState<AdminBarangScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String v) {
    ref.read(adminBarangAdminProvider.notifier).setFilter(search: v);
  }

  @override
  Widget build(BuildContext context) {
    final barangAsync = ref.watch(adminBarangAdminProvider);

    return AdminScaffold(
      title: 'Manajemen Barang',
      appBarBottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            decoration: const InputDecoration(
              hintText: 'Cari barang...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              ref.read(adminBarangAdminProvider.notifier).refresh(),
        ),
      ],
      body: barangAsync.when(
        data: (state) => Column(
          children: [
            _FilterBar(
              current: state.ketersediaanFilter,
              onSelect: (k) => ref
                  .read(adminBarangAdminProvider.notifier)
                  .setFilter(ketersediaan: k),
            ),
            Expanded(
              child: state.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada barang.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(adminBarangAdminProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.items.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _BarangAdminCard(
                          item: state.items[i],
                          onUpdateStatus: () =>
                              _showUpdateStatusSheet(ctx, ref, state.items[i]),
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
                    ref.read(adminBarangAdminProvider.notifier).refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateStatusSheet(
    BuildContext context,
    WidgetRef ref,
    BarangModel item,
  ) async {
    const kondisiOptions = ['baik', 'rusak_ringan', 'rusak_berat'];
    const kondisiLabels = ['Baik', 'Rusak Ringan', 'Rusak Berat'];
    String selectedKondisi = item.kondisiTerakhir ?? 'baik';
    final catatanCtrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

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
                'Update Status: ${item.namaBarang ?? item.kodeBarang}',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const Text('Kondisi'),
              Wrap(
                spacing: 8,
                children: List.generate(kondisiOptions.length, (i) {
                  return ChoiceChip(
                    label: Text(kondisiLabels[i]),
                    selected: selectedKondisi == kondisiOptions[i],
                    onSelected: (_) =>
                        setState(() => selectedKondisi = kondisiOptions[i]),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catatanCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
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
          .read(adminBarangAdminProvider.notifier)
          .updateStatus(
            id: item.id,
            kondisi: selectedKondisi,
            catatan: catatanCtrl.text.trim().isEmpty
                ? null
                : catatanCtrl.text.trim(),
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
}

class _FilterBar extends StatelessWidget {
  final String? current;
  final void Function(Object?) onSelect;

  static const _options = [null, 'tersedia', 'dipinjam'];
  static const _labels = ['Semua', 'Tersedia', 'Dipinjam'];

  const _FilterBar({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _options.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) => FilterChip(
          label: Text(_labels[i]),
          selected: current == _options[i],
          onSelected: (_) => onSelect(_options[i]),
        ),
      ),
    );
  }
}

class _BarangAdminCard extends StatelessWidget {
  final BarangModel item;
  final VoidCallback onUpdateStatus;

  const _BarangAdminCard({required this.item, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTersedia = item.ketersediaan == 'tersedia';

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaBarang ?? item.kodeBarang,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.kodeBarang} · NUP: ${item.nup}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (item.kategoriNama != null || item.ruanganNama != null)
                    Text(
                      [
                        if (item.kategoriNama != null) item.kategoriNama!,
                        if (item.ruanganNama != null) item.ruanganNama!,
                      ].join(' · '),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isTersedia ? Colors.green : Colors.blue)
                              .withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isTersedia ? Colors.green : Colors.blue,
                          ),
                        ),
                        child: Text(
                          isTersedia ? 'Tersedia' : 'Dipinjam',
                          style: TextStyle(
                            fontSize: 10,
                            color: isTersedia ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.kondisiTerakhir != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.kondisiTerakhir!,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.build_outlined),
              onPressed: onUpdateStatus,
              tooltip: 'Update Status',
            ),
          ],
        ),
      ),
    );
  }
}
