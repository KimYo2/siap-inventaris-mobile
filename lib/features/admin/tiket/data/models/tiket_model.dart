import 'package:flutter/material.dart';

class TiketModel {
  final int id;
  final String nomorBmn;
  final String pelapor;
  final String jenisKerusakan;
  final String? deskripsi;
  final String status; // open | diproses | selesai
  final String priority; // low | medium | high
  final String? resolusi;
  final String? assignedTo;
  final String tanggalLapor;

  const TiketModel({
    required this.id,
    required this.nomorBmn,
    required this.pelapor,
    required this.jenisKerusakan,
    required this.status,
    required this.priority,
    required this.tanggalLapor,
    this.deskripsi,
    this.resolusi,
    this.assignedTo,
  });

  factory TiketModel.fromJson(Map<String, dynamic> json) => TiketModel(
    id: json['id'] as int,
    nomorBmn: json['nomor_bmn'] as String,
    pelapor: json['pelapor'] as String? ?? '',
    jenisKerusakan: json['jenis_kerusakan'] as String? ?? '',
    deskripsi: json['deskripsi'] as String?,
    status: json['status'] as String? ?? 'open',
    priority: json['priority'] as String? ?? 'low',
    resolusi: json['resolusi'] as String?,
    assignedTo: json['assigned_to'] as String?,
    tanggalLapor: json['tanggal_lapor'] as String? ?? '',
  );

  Color get priorityColor {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'diproses':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'diproses':
        return 'Diproses';
      default:
        return 'Open';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      default:
        return 'Rendah';
    }
  }
}
