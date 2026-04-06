class OverdueItemModel {
  final int id;
  final String kodeBarang;
  final String nup;
  final String namaPeminjam;
  final String? tanggalJatuhTempo;

  const OverdueItemModel({
    required this.id,
    required this.kodeBarang,
    required this.nup,
    required this.namaPeminjam,
    this.tanggalJatuhTempo,
  });

  factory OverdueItemModel.fromJson(Map<String, dynamic> json) =>
      OverdueItemModel(
        id: json['id'] as int,
        kodeBarang: json['kode_barang'] as String,
        nup: json['nup'] as String,
        namaPeminjam: json['nama_peminjam'] as String? ?? '-',
        tanggalJatuhTempo: json['tanggal_jatuh_tempo'] as String?,
      );
}

class TopItemModel {
  final String kodeBarang;
  final String nup;
  final String? brand;
  final String? tipe;
  final int total;

  const TopItemModel({
    required this.kodeBarang,
    required this.nup,
    required this.total,
    this.brand,
    this.tipe,
  });

  factory TopItemModel.fromJson(Map<String, dynamic> json) => TopItemModel(
    kodeBarang: json['kode_barang'] as String,
    nup: json['nup'] as String,
    brand: json['brand'] as String?,
    tipe: json['tipe'] as String?,
    total: (json['total'] as num).toInt(),
  );

  String get namaDisplay =>
      brand != null && tipe != null ? '$brand $tipe' : '$kodeBarang-$nup';
}

class TopBorrowerModel {
  final String nipPeminjam;
  final String namaPeminjam;
  final int total;

  const TopBorrowerModel({
    required this.nipPeminjam,
    required this.namaPeminjam,
    required this.total,
  });

  factory TopBorrowerModel.fromJson(Map<String, dynamic> json) =>
      TopBorrowerModel(
        nipPeminjam: json['nip_peminjam'] as String,
        namaPeminjam: json['nama_peminjam'] as String,
        total: (json['total'] as num).toInt(),
      );
}

class AdminDashboardModel {
  final int totalBarang;
  final int tersedia;
  final int dipinjam;
  final int activeLoans;
  final int overdueCount;
  final List<OverdueItemModel> overdueList;
  final List<TopItemModel> topItems;
  final List<TopBorrowerModel> topBorrowers;
  final double? avgBorrowHours;

  const AdminDashboardModel({
    required this.totalBarang,
    required this.tersedia,
    required this.dipinjam,
    required this.activeLoans,
    required this.overdueCount,
    required this.overdueList,
    required this.topItems,
    required this.topBorrowers,
    this.avgBorrowHours,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) =>
      AdminDashboardModel(
        totalBarang: (json['total_barang'] as num? ?? 0).toInt(),
        tersedia: (json['tersedia'] as num? ?? 0).toInt(),
        dipinjam: (json['dipinjam'] as num? ?? 0).toInt(),
        activeLoans: (json['active_loans'] as num? ?? 0).toInt(),
        overdueCount: (json['overdue_count'] as num? ?? 0).toInt(),
        overdueList: (json['overdue_list'] as List<dynamic>? ?? [])
            .map((e) => OverdueItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        topItems: (json['top_items'] as List<dynamic>? ?? [])
            .map((e) => TopItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        topBorrowers: (json['top_borrowers'] as List<dynamic>? ?? [])
            .map((e) => TopBorrowerModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        avgBorrowHours: (json['avg_borrow_hours'] as num?)?.toDouble(),
      );
}
