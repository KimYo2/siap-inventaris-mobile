class BarangModel {
  final int id;
  final String kodeBarang;
  final String nup;
  final String? brand;
  final String? tipe;
  final String? namaBarang;
  final String? kondisiTerakhir;
  final String? keterangan;
  final String? fotoPath;
  final String? fotoUrl;
  final String ketersediaan; // 'tersedia' | 'dipinjam'
  final String? statusBarang;
  final String? catatanStatus;
  final String? peminjamTerakhir;
  final int? kategoriId;
  final int? ruanganId;
  final String? kategoriNama;
  final String? ruanganNama;
  // context dari API (per user)
  final bool isBorrowing;
  final int queueCount;
  final int? waitlistPosition;
  final int? userWaitlistId;

  const BarangModel({
    required this.id,
    required this.kodeBarang,
    required this.nup,
    required this.ketersediaan,
    this.brand,
    this.tipe,
    this.namaBarang,
    this.kondisiTerakhir,
    this.keterangan,
    this.fotoPath,
    this.fotoUrl,
    this.statusBarang,
    this.catatanStatus,
    this.peminjamTerakhir,
    this.kategoriId,
    this.ruanganId,
    this.kategoriNama,
    this.ruanganNama,
    this.isBorrowing = false,
    this.queueCount = 0,
    this.waitlistPosition,
    this.userWaitlistId,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) => BarangModel(
    id: json['id'] as int,
    kodeBarang: json['kode_barang'] as String,
    nup: json['nup'] as String,
    ketersediaan: json['ketersediaan'] as String,
    brand: json['brand'] as String?,
    tipe: json['tipe'] as String?,
    namaBarang: json['nama_barang'] as String?,
    kondisiTerakhir: json['kondisi_terakhir'] as String?,
    keterangan: json['keterangan'] as String?,
    fotoPath: json['foto_path'] as String?,
    fotoUrl: json['foto_url'] as String?,
    statusBarang: json['status_barang'] as String?,
    catatanStatus: json['catatan_status'] as String?,
    peminjamTerakhir: json['peminjam_terakhir'] as String?,
    kategoriId: json['kategori_id'] as int?,
    ruanganId: json['ruangan_id'] as int?,
    kategoriNama: json['kategori_nama'] as String?,
    ruanganNama: json['ruangan_nama'] as String?,
    isBorrowing: json['is_borrowing'] as bool? ?? false,
    queueCount: json['queue_count'] as int? ?? 0,
    waitlistPosition: json['waitlist_position'] as int?,
    userWaitlistId: json['user_waitlist_id'] as int?,
  );

  String get namaDisplay =>
      namaBarang ??
      (brand != null && tipe != null ? '$brand $tipe' : kodeBarang);

  String get nomorBmn => '$kodeBarang-$nup';

  bool get tersedia => ketersediaan == 'tersedia';
}
