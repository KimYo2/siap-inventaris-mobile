import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/datasources/return_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';

class ReturnScreen extends ConsumerStatefulWidget {
  const ReturnScreen({super.key});

  @override
  ConsumerState<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends ConsumerState<ReturnScreen> {
  final MobileScannerController _scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final rawValue = barcode!.rawValue!;
    setState(() => _isProcessing = true);
    _scanController.stop();
    _showReturnForm(rawValue);
  }

  Future<void> _showReturnForm(String nomorBmn) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReturnFormSheet(nomorBmn: nomorBmn),
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result == true) {
      // Restart scanner after successful return
      _scanController.start();
    } else {
      // User cancelled — resume scanning
      _scanController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kembalikan Barang'),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'Torch',
            onPressed: () {
              _scanController.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _scanController, onDetect: _onDetect),
          // Scan overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Bottom hint
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Scan QR/Barcode nomor BMN barang yang akan dikembalikan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Return form bottom sheet
// ---------------------------------------------------------------------------
class _ReturnFormSheet extends ConsumerStatefulWidget {
  final String nomorBmn;
  const _ReturnFormSheet({required this.nomorBmn});

  @override
  ConsumerState<_ReturnFormSheet> createState() => _ReturnFormSheetState();
}

class _ReturnFormSheetState extends ConsumerState<_ReturnFormSheet> {
  bool _isDamaged = false;
  String _jenisKerusakan = 'ringan';
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final ds = ReturnRemoteDataSource(ref.read(dioClientProvider).dio);
      final message = await ds.submitReturn(
        nomorBmn: widget.nomorBmn,
        isDamaged: _isDamaged,
        jenisKerusakan: _isDamaged ? _jenisKerusakan : null,
        deskripsi: _isDamaged ? _descController.text.trim() : null,
      );
      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Konfirmasi Pengembalian',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Nomor BMN: ${widget.nomorBmn}',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Damage toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Barang mengalami kerusakan?'),
            value: _isDamaged,
            onChanged: (v) => setState(() => _isDamaged = v),
          ),

          // Damage form
          if (_isDamaged) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Jenis Kerusakan: '),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Ringan'),
                  selected: _jenisKerusakan == 'ringan',
                  onSelected: (_) => setState(() => _jenisKerusakan = 'ringan'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Berat'),
                  selected: _jenisKerusakan == 'berat',
                  onSelected: (_) => setState(() => _jenisKerusakan = 'berat'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi kerusakan',
                border: OutlineInputBorder(),
                hintText: 'Jelaskan kondisi kerusakan...',
              ),
            ),
          ],

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kembalikan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
