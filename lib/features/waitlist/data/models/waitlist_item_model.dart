class WaitlistItemModel {
  final int id;
  final String kodeBarang;
  final String nup;
  final String nipPeminjam;
  final String status; // aktif | notified | fulfilled | cancelled
  final String? namaBarang;
  final String? brand;
  final String? tipe;
  final int? position;
  final DateTime requestedAt;

  const WaitlistItemModel({
    required this.id,
    required this.kodeBarang,
    required this.nup,
    required this.nipPeminjam,
    required this.status,
    required this.requestedAt,
    this.namaBarang,
    this.brand,
    this.tipe,
    this.position,
  });

  factory WaitlistItemModel.fromJson(Map<String, dynamic> json) =>
      WaitlistItemModel(
        id: json['id'] as int,
        kodeBarang: json['kode_barang'] as String,
        nup: json['nup'] as String,
        nipPeminjam: json['nip_peminjam'] as String,
        status: json['status'] as String? ?? 'aktif',
        namaBarang: json['nama_barang'] as String?,
        brand: json['brand'] as String?,
        tipe: json['tipe'] as String?,
        position: json['position'] as int?,
        requestedAt: json['requested_at'] != null
            ? DateTime.parse(json['requested_at'] as String)
            : DateTime.now(),
      );

  String get namaDisplay =>
      namaBarang ??
      (brand != null && tipe != null ? '$brand $tipe' : '$kodeBarang-$nup');

  String get nomorBmn => '$kodeBarang-$nup';
}
