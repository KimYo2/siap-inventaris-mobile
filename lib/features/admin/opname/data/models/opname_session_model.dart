class OpnameSessionModel {
  final int id;
  final String nama;
  final String status; // berjalan | selesai
  final String? notes;
  final String? startedAt;
  final String? finishedAt;
  final int totalItems;
  final int foundItems;

  const OpnameSessionModel({
    required this.id,
    required this.nama,
    required this.status,
    required this.totalItems,
    required this.foundItems,
    this.notes,
    this.startedAt,
    this.finishedAt,
  });

  factory OpnameSessionModel.fromJson(Map<String, dynamic> json) =>
      OpnameSessionModel(
        id: json['id'] as int,
        nama: json['nama'] as String,
        status: json['status'] as String? ?? 'berjalan',
        notes: json['notes'] as String?,
        startedAt: json['started_at'] as String?,
        finishedAt: json['finished_at'] as String?,
        totalItems: (json['total_items'] as num? ?? 0).toInt(),
        foundItems: (json['found_items'] as num? ?? 0).toInt(),
      );

  bool get isBerjalan => status == 'berjalan';

  double get progressPercent => totalItems == 0 ? 0 : foundItems / totalItems;
}
