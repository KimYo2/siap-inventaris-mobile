import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bungkus halaman root dengan widget ini supaya tombol back HP
/// minta konfirmasi dua kali sebelum keluar aplikasi.
class DoubleBackToExit extends StatefulWidget {
  final Widget child;
  const DoubleBackToExit({super.key, required this.child});

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit>
    with WidgetsBindingObserver {
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    // Jika GoRouter masih punya riwayat, biarkan GoRouter yang handle
    if (GoRouter.of(context).canPop()) return false;

    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tekan sekali lagi untuk keluar'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true; // sudah ditangani, jangan keluar
    }
    return false; // tekan kedua kali — biarkan sistem keluar
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
