import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/barang_provider.dart';
import '../../data/models/barang_model.dart';

class BarangDetailScreen extends ConsumerWidget {
  final String nomorBmn;
  const BarangDetailScreen({super.key, required this.nomorBmn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barangAsync = ref.watch(barangDetailProvider(nomorBmn));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(barangDetailProvider(nomorBmn).notifier).refresh(),
          ),
        ],
      ),
      body: barangAsync.when(
        data: (barang) => RefreshIndicator(
          onRefresh: () =>
              ref.read(barangDetailProvider(nomorBmn).notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: _BarangDetailBody(barang: barang, nomorBmn: nomorBmn),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref
                      .read(barangDetailProvider(nomorBmn).notifier)
                      .refresh(),
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

class _BarangDetailBody extends ConsumerWidget {
  final BarangModel barang;
  final String nomorBmn;
  const _BarangDetailBody({required this.barang, required this.nomorBmn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---------- Foto ----------
        _FotoSection(fotoUrl: barang.fotoUrl),

        // ---------- Info utama ----------
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      barang.namaDisplay,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _KetersediaanBadge(tersedia: barang.tersedia),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                barang.nomorBmn,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              // ---------- Info rows ----------
              _InfoRow(
                icon: Icons.info_outline,
                label: 'Kondisi',
                value: barang.kondisiTerakhir ?? '-',
              ),
              _InfoRow(
                icon: Icons.category_outlined,
                label: 'Kategori',
                value: barang.kategoriNama ?? '-',
              ),
              _InfoRow(
                icon: Icons.room_outlined,
                label: 'Ruangan',
                value: barang.ruanganNama ?? '-',
              ),
              if (barang.brand != null)
                _InfoRow(
                  icon: Icons.branding_watermark_outlined,
                  label: 'Brand / Tipe',
                  value:
                      '${barang.brand}'
                      '${barang.tipe != null ? ' · ${barang.tipe}' : ''}',
                ),
              if (barang.keterangan != null && barang.keterangan!.isNotEmpty)
                _InfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Keterangan',
                  value: barang.keterangan!,
                ),

              const SizedBox(height: 24),

              // ---------- Action section ----------
              _ActionSection(barang: barang, nomorBmn: nomorBmn),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Foto
// ---------------------------------------------------------------------------
class _FotoSection extends StatelessWidget {
  final String? fotoUrl;
  const _FotoSection({this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (fotoUrl != null && fotoUrl!.isNotEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          fotoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) =>
              _PlaceholderFoto(colorScheme: colorScheme),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _PlaceholderFoto(colorScheme: colorScheme),
    );
  }
}

class _PlaceholderFoto extends StatelessWidget {
  final ColorScheme colorScheme;
  const _PlaceholderFoto({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.inventory_2_outlined,
        size: 64,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ketersediaan badge
// ---------------------------------------------------------------------------
class _KetersediaanBadge extends StatelessWidget {
  final bool tersedia;
  const _KetersediaanBadge({required this.tersedia});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tersedia
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tersedia ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tersedia ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 14,
            color: tersedia ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            tersedia ? 'Tersedia' : 'Dipinjam',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tersedia ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row
// ---------------------------------------------------------------------------
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action section
// ---------------------------------------------------------------------------
class _ActionSection extends ConsumerWidget {
  final BarangModel barang;
  final String nomorBmn;
  const _ActionSection({required this.barang, required this.nomorBmn});

  Future<void> _borrow(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajukan Peminjaman'),
        content: Text('Kamu akan meminjam "${barang.namaDisplay}". Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Pinjam'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(barangDetailProvider(nomorBmn).notifier).borrow();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Peminjaman diajukan, menunggu konfirmasi admin.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _joinWaitlist(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Masuk Waitlist'),
        content: Text(
          'Barang ini sedang dipinjam. Kamu akan masuk antrian '
          '(saat ini ${barang.queueCount} orang). Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Masuk Antrian'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(barangDetailProvider(nomorBmn).notifier).joinWaitlist();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Berhasil masuk waitlist.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cancelWaitlist(
    BuildContext context,
    WidgetRef ref,
    int waitlistId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Waitlist'),
        content: const Text('Kamu akan keluar dari antrian. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(barangDetailProvider(nomorBmn).notifier)
          .cancelWaitlist(waitlistId);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Waitlist dibatalkan.'),
          backgroundColor: Colors.orange,
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

    // Case 1: Current user is borrowing this item
    if (barang.isBorrowing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Kamu sedang meminjam barang ini.',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Case 2: User is in waitlist
    if (barang.userWaitlistId != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.queue, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    barang.waitlistPosition != null
                        ? 'Kamu ada di antrian ke-${barang.waitlistPosition}'
                        : 'Kamu ada di dalam waitlist.',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Batalkan Waitlist'),
            onPressed: () =>
                _cancelWaitlist(context, ref, barang.userWaitlistId!),
          ),
        ],
      );
    }

    // Case 3: Available — show borrow button
    if (barang.tersedia) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Icon(Icons.handshake_outlined),
        label: const Text('Ajukan Peminjaman'),
        onPressed: () => _borrow(context, ref),
      );
    }

    // Case 4: Dipinjam, user not in waitlist
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (barang.queueCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${barang.queueCount} orang dalam waitlist',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.add_alert_outlined),
          label: const Text('Masuk Waitlist'),
          onPressed: () => _joinWaitlist(context, ref),
        ),
      ],
    );
  }
}
