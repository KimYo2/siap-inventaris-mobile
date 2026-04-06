class DashboardSummary {
  final int activeLoans;
  final int totalLoans;
  final int overdueLoans;
  final HistoriSingkat? currentActiveLoan;
  final HistoriSingkat? nextDueLoan;
  final List<HistoriSingkat> recentLoans;

  const DashboardSummary({
    required this.activeLoans,
    required this.totalLoans,
    required this.overdueLoans,
    this.currentActiveLoan,
    this.nextDueLoan,
    required this.recentLoans,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      DashboardSummary(
        activeLoans: json['active_loans'] as int,
        totalLoans: json['total_loans'] as int,
        overdueLoans: json['overdue_loans'] as int,
        currentActiveLoan: json['current_active_loan'] != null
            ? HistoriSingkat.fromJson(
                json['current_active_loan'] as Map<String, dynamic>,
              )
            : null,
        nextDueLoan: json['next_due_loan'] != null
            ? HistoriSingkat.fromJson(
                json['next_due_loan'] as Map<String, dynamic>,
              )
            : null,
        recentLoans: (json['recent_loans'] as List<dynamic>? ?? [])
            .map((e) => HistoriSingkat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class HistoriSingkat {
  final int id;
  final String kodeBarang;
  final String nup;
  final String? brand;
  final String? tipe;
  final String? namaBarang;
  final String status;
  final String? tanggalJatuhTempo;
  final String? waktuPinjam;

  const HistoriSingkat({
    required this.id,
    required this.kodeBarang,
    required this.nup,
    required this.status,
    this.brand,
    this.tipe,
    this.namaBarang,
    this.tanggalJatuhTempo,
    this.waktuPinjam,
  });

  factory HistoriSingkat.fromJson(Map<String, dynamic> json) => HistoriSingkat(
    id: json['id'] as int,
    kodeBarang: json['kode_barang'] as String,
    nup: json['nup'].toString(),
    status: json['status'] as String,
    brand: json['brand'] as String?,
    tipe: json['tipe'] as String?,
    namaBarang: json['nama_barang'] as String?,
    tanggalJatuhTempo: json['tanggal_jatuh_tempo'] as String?,
    waktuPinjam: json['waktu_pinjam'] as String?,
  );

  String get namaDisplay =>
      namaBarang ??
      (brand != null && tipe != null ? '$brand $tipe' : kodeBarang);
}
