class KategoriModel {
  final int id;
  final String namaKategori;
  final String? keterangan;
  final int durasiPinjamDefault;
  final int? barangCount;

  const KategoriModel({
    required this.id,
    required this.namaKategori,
    required this.durasiPinjamDefault,
    this.keterangan,
    this.barangCount,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) => KategoriModel(
    id: json['id'] as int,
    namaKategori: json['nama_kategori'] as String,
    keterangan: json['keterangan'] as String?,
    durasiPinjamDefault: (json['durasi_pinjam_default'] as num? ?? 7).toInt(),
    barangCount: (json['barang_count'] as num?)?.toInt(),
  );
}
