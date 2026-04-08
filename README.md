# SIAP Inventaris Mobile

Aplikasi manajemen inventaris barang berbasis Flutter untuk platform Android dan iOS. Aplikasi ini mendukung dua peran pengguna: **Admin** dan **User (Pegawai)**.

## Fitur

### User (Pegawai)
- **Dashboard** — Ringkasan status peminjaman dan barang yang sedang dipinjam
- **Scan QR** — Memindai kode QR pada barang untuk melihat detail atau melakukan peminjaman
- **Detail Barang** — Informasi lengkap barang berdasarkan nomor BMN
- **Histori** — Riwayat peminjaman dan pengembalian barang
- **Return Barang** — Proses pengembalian barang yang sedang dipinjam
- **Waitlist** — Daftar antrian peminjaman barang
- **Notifikasi** — Pemberitahuan terkait aktivitas peminjaman
- **Profil** — Manajemen data dan foto profil pengguna

### Admin
- **Dashboard** — Statistik dan ringkasan data inventaris
- **Barang** — Kelola data barang inventaris
- **Kategori** — Kelola kategori barang
- **Ruangan** — Kelola data ruangan
- **Opname** — Stock opname inventaris
- **Tiket** — Kelola tiket permintaan peminjaman
- **Histori** — Riwayat seluruh transaksi
- **Pengguna** — Manajemen akun pengguna

## Teknologi

| Kategori | Library |
|---|---|
| State Management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) + riverpod_annotation |
| Navigasi | [go_router](https://pub.dev/packages/go_router) |
| HTTP Client | [dio](https://pub.dev/packages/dio) + pretty_dio_logger |
| Penyimpanan Aman | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| Scanner QR | [mobile_scanner](https://pub.dev/packages/mobile_scanner) |
| Generator QR | [qr_flutter](https://pub.dev/packages/qr_flutter) |
| Image Picker | [image_picker](https://pub.dev/packages/image_picker) |
| Local Storage | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| Gambar Cache | [cached_network_image](https://pub.dev/packages/cached_network_image) |
| UI Helpers | shimmer, intl |
| Code Gen | build_runner, freezed, json_serializable |

## Persyaratan

- Flutter SDK `^3.11.4`
- Dart SDK `^3.11.4`

## Instalasi

1. Clone repositori ini
   ```bash
   git clone <repository-url>
   cd siap_inventaris_mobile
   ```

2. Install dependensi
   ```bash
   flutter pub get
   ```

3. Jalankan code generation
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Jalankan aplikasi
   ```bash
   flutter run
   ```

## Struktur Proyek

```
lib/
├── main.dart
├── app/
│   ├── app.dart          # Root widget & tema aplikasi
│   └── router/           # Konfigurasi navigasi (GoRouter)
├── core/
│   ├── constants/        # Konstanta aplikasi
│   ├── errors/           # Penanganan error
│   ├── network/          # Konfigurasi HTTP client
│   ├── storage/          # Penyimpanan lokal
│   └── widgets/          # Widget umum
└── features/
    ├── auth/             # Login & autentikasi
    ├── dashboard/        # Dashboard user
    ├── barang/           # Detail barang
    ├── scan/             # Scanner QR
    ├── histori/          # Riwayat transaksi
    ├── return_barang/    # Pengembalian barang
    ├── waitlist/         # Antrian peminjaman
    ├── notifikasi/       # Notifikasi
    ├── profile/          # Profil pengguna
    └── admin/            # Fitur khusus admin
        ├── dashboard/
        ├── barang/
        ├── kategori/
        ├── ruangan/
        ├── opname/
        ├── tiket/
        ├── histori/
        └── users/
```

## Versi

`1.0.0+1`
