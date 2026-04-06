import 'package:flutter/material.dart';

class NotifikasiModel {
  final int id;
  final int userId;
  final String judul;
  final String pesan;
  final String type; // approval | waitlist | overdue | info
  final bool isRead;
  final String? relatedModel;
  final int? relatedId;
  final DateTime createdAt;

  const NotifikasiModel({
    required this.id,
    required this.userId,
    required this.judul,
    required this.pesan,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedModel,
    this.relatedId,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) =>
      NotifikasiModel(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        judul: json['judul'] as String,
        pesan: json['pesan'] as String,
        type: json['type'] as String? ?? 'info',
        isRead: json['is_read'] as bool? ?? false,
        relatedModel: json['related_model'] as String?,
        relatedId: json['related_id'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  String get typeLabel => switch (type) {
    'approval' => 'Persetujuan',
    'waitlist' => 'Antrean',
    'overdue' => 'Keterlambatan',
    _ => 'Informasi',
  };

  Color get typeColor => switch (type) {
    'approval' => Colors.blue,
    'waitlist' => Colors.purple,
    'overdue' => Colors.red,
    _ => Colors.grey,
  };

  IconData get typeIcon => switch (type) {
    'approval' => Icons.check_circle_outline,
    'waitlist' => Icons.queue,
    'overdue' => Icons.warning_amber_outlined,
    _ => Icons.info_outline,
  };
}
