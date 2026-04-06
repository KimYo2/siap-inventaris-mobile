class HistoriPeminjamanModel {
  final int id;
  final String kodeBarang;
  final String nup;
  final String nipPeminjam;
  final String namaPeminjam;
  final String kondisiAwal;
  final String? waktuPengajuan;
  final String? waktuPinjam;
  final String? waktuKembali;
  final String status;
  final String? kondisiKembali;
  final String? catatanKondisi;
  final String? tanggalJatuhTempo;
  final String? perpanjanganStatus;
  final int? perpanjanganHari;
  final String? perpanjanganAlasan;
  final String? perpanjanganRejectReason;
  // joined from barang
  final String? brand;
  final String? tipe;
  final String? namaBarang;

  const HistoriPeminjamanModel({
    required this.id,
    required this.kodeBarang,
    required this.nup,
    required this.nipPeminjam,
    required this.namaPeminjam,
    required this.kondisiAwal,
    required this.status,
    this.waktuPengajuan,
    this.waktuPinjam,
    this.waktuKembali,
    this.kondisiKembali,
    this.catatanKondisi,
    this.tanggalJatuhTempo,
    this.perpanjanganStatus,
    this.perpanjanganHari,
    this.perpanjanganAlasan,
    this.perpanjanganRejectReason,
    this.brand,
    this.tipe,
    this.namaBarang,
  });

  factory HistoriPeminjamanModel.fromJson(Map<String, dynamic> json) =>
      HistoriPeminjamanModel(
        id: json['id'] as int,
        kodeBarang: json['kode_barang'] as String,
        nup: json['nup'] as String,
        nipPeminjam: json['nip_peminjam'] as String,
        namaPeminjam: json['nama_peminjam'] as String,
        kondisiAwal: json['kondisi_awal'] as String,
        status: json['status'] as String,
        waktuPengajuan: json['waktu_pengajuan'] as String?,
        waktuPinjam: json['waktu_pinjam'] as String?,
        waktuKembali: json['waktu_kembali'] as String?,
        kondisiKembali: json['kondisi_kembali'] as String?,
        catatanKondisi: json['catatan_kondisi'] as String?,
        tanggalJatuhTempo: json['tanggal_jatuh_tempo'] as String?,
        perpanjanganStatus: json['perpanjangan_status'] as String?,
        perpanjanganHari: json['perpanjangan_hari'] as int?,
        perpanjanganAlasan: json['perpanjangan_alasan'] as String?,
        perpanjanganRejectReason: json['perpanjangan_reject_reason'] as String?,
        brand: json['brand'] as String?,
        tipe: json['tipe'] as String?,
        namaBarang: json['nama_barang'] as String?,
      );

  String get statusLabel {
    const map = {
      'menunggu': 'Menunggu Persetujuan',
      'dipinjam': 'Sedang Dipinjam',
      'ditolak': 'Ditolak',
      'dikembalikan': 'Dikembalikan',
    };
    return map[status] ?? 'Selesai';
  }

  String get namaBarangDisplay =>
      namaBarang ??
      (brand != null && tipe != null ? '$brand $tipe' : kodeBarang);
}
