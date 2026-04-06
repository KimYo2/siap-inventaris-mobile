import 'package:flutter/material.dart';

class BarangDetailScreen extends StatelessWidget {
  final String nomorBmn;

  const BarangDetailScreen({super.key, required this.nomorBmn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barang: $nomorBmn')),
      body: Center(child: Text('Detail Barang $nomorBmn — Coming Soon')),
    );
  }
}
