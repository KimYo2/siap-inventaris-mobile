class ApiEndpoints {
  // Auth
  static const login = '/login';
  static const logout = '/logout';
  static const me = '/me';

  // User
  static const dashboard = '/dashboard';
  static const histori = '/histori';
  static const returnBarang = '/return';
  static const notifikasi = '/notifikasi';
  static const waitlistList = '/waitlist';
  static const profile = '/profile';

  static String barangDetail(String nomorBmn) => '/barang/$nomorBmn';
  static const borrowBarang = '/barang/borrow';
  static String barangWaitlist(String nomorBmn) => '/barang/$nomorBmn/waitlist';
  static String historiExtend(int id) => '/histori/$id/extend';
  static String waitlistCancel(int id) => '/waitlist/$id';
  static String notifikasiRead(int id) => '/notifikasi/$id/read';

  // Admin
  static const adminDashboard = '/admin/dashboard';
  static const adminBarang = '/admin/barang';
  static const adminHistori = '/admin/histori';
  static const adminOpname = '/admin/opname';
  static const adminTiket = '/admin/tiket';
  static const adminUsers = '/admin/users';
  static const adminKategori = '/admin/kategori';
  static const adminRuangan = '/admin/ruangan';

  static String adminHistoriApprove(int id) => '/admin/histori/$id/approve';
  static String adminHistoriReject(int id) => '/admin/histori/$id/reject';
  static String adminExtendApprove(int id) =>
      '/admin/histori/$id/extend/approve';
  static String adminExtendReject(int id) => '/admin/histori/$id/extend/reject';
  static String adminOpnameScan(int id) => '/admin/opname/$id/scan';
  static String adminOpnameFinish(int id) => '/admin/opname/$id/finish';
  static String adminBarangItem(int id) => '/admin/barang/$id';
  static String adminBarangStatus(int id) => '/admin/barang/$id/update-status';
  static const adminBarangImport = '/admin/barang/import';
  static String adminTiketItem(int id) => '/admin/tiket/$id';
  static String adminTiketResolve(int id) => '/admin/tiket/$id/resolve';
  static String adminKategoriItem(int id) => '/admin/kategori/$id';
  static String adminRuanganItem(int id) => '/admin/ruangan/$id';
  static String adminUsersItem(int id) => '/admin/users/$id';
}
