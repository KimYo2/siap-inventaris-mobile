class RuanganModel {
  final int id;
  final String kodeRuangan;
  final String namaRuangan;
  final String? lantai;
  final int? barangCount;

  const RuanganModel({
    required this.id,
    required this.kodeRuangan,
    required this.namaRuangan,
    this.lantai,
    this.barangCount,
  });

  factory RuanganModel.fromJson(Map<String, dynamic> json) => RuanganModel(
    id: json['id'] as int,
    kodeRuangan: json['kode_ruangan'] as String,
    namaRuangan: json['nama_ruangan'] as String,
    lantai: json['lantai']?.toString(),
    barangCount: (json['barang_count'] as num?)?.toInt(),
  );
}
