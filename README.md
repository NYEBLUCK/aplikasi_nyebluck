<img width="1376" height="680" alt="Gemini_Generated_Image_9gdg9j9gdg9j9gdg" src="https://github.com/user-attachments/assets/08d5b7c1-0a5c-48e2-92b5-7112baaa0c68" />

# Nyebluck

## Deskripsi Aplikasi
Nyebluck adalah aplikasi kasir berbasis mobile yang dikembangkan untuk membantu operasional toko seblak Nyebluck dalam mengelola transaksi penjualan, pencatatan stok, dan data keuangan secara digital. Aplikasi ini hadir sebagai solusi dari proses manual yang sering menimbulkan kesalahan pencatatan dan data yang tidak terstruktur, dengan memanfaatkan Flutter dan Supabase sebagai teknologi utama.

## Latar Belakang
Permasalahan utama yang dihadapi oleh [nama organisasi/mitra] adalah [isi masalah]. Berdasarkan permasalahan tersebut, kami mengusulkan sebuah aplikasi mobile yang dapat membantu proses [isi tujuan aplikasi].

## Solusi yang Ditawarkan
Solusi yang kami tawarkan adalah aplikasi mobile yang memungkinkan pengguna untuk [jelaskan fungsi utama aplikasi]. Dengan aplikasi ini, proses [aktivitas utama] menjadi lebih mudah, cepat, dan efisien.

## Fitur Aplikasi
### Fitur Utama
- Login
- Register / CRUD User
- CRUD [nama data utama]

### Fitur Tambahan
- [Fitur tambahan 1]
- [Fitur tambahan 2]

## Widget yang Digunakan
Beberapa widget Flutter yang digunakan dalam aplikasi ini:
- Scaffold
- AppBar
- Column
- Row
- ListView
- Card
- TextField
- ElevatedButton
- Form
- Snackbar
- BottomNavigationBar

## State Management
State management yang digunakan pada aplikasi ini adalah [setState / Provider / Bloc / Riverpod]. State management ini digunakan untuk mengelola perubahan data pada halaman [contoh].

## Navigation
Navigasi dalam aplikasi ini menggunakan [Navigator / Named Route / GoRouter], untuk perpindahan antar halaman seperti login, register, dashboard, dan halaman CRUD.

## Integrasi Supabase
Aplikasi ini menggunakan Supabase untuk:
- Authentication (Login dan Register)
- Database (Menyimpan data CRUD)
- Storage (jika digunakan)

## Package yang Digunakan
| Package | Kegunaan |
|--------|----------|
| flutter_dotenv | Menyimpan konfigurasi sensitif dari file .env |
| supabase_flutter | Integrasi Flutter dengan Supabase |
| [package_tambahan] | [jelaskan kegunaan] |

## Nilai Tambah
Aplikasi ini menggunakan package tambahan yaitu [nama package] untuk [fungsi], sehingga memberikan nilai tambah pada pengembangan aplikasi.

## Konfigurasi Environment

Aplikasi ini menggunakan file `.env` untuk menyimpan konfigurasi sensitif seperti Supabase URL dan API Key.

### Contoh isi file `.env`:
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

## 🚀 Cara Menjalankan Projek Menggunakan Source Code

📌 Prasyarat

Flutter SDK yang kompatibel dengan batas sdk di pubspec.yaml.

Proyek Supabase dengan skema dan kebijakan akses (RLS) yang selaras dengan aplikasi.

Perintah flutter dan dart tersedia di terminal.


⚙️ Langkah Langkah
1. Buka terminal pada root folder proyek (folder yang berisi pubspec.yaml).

2. Sambungkan ke Supabase (hanya di komputer pengembang)

   * Duplikat berkas .env.example dan simpan sebagai .env di folder yang sama.

    * Isi URL proyek dan anon key dari dashboard Supabase (Settings → API).

     Berkas .env hanya dipakai secara lokal. Jangan ikut mengunggahnya ke repositori publik (pastikan terdaftar di .gitignore).


3. Pasang dependensi:

      flutter pub get


4. Jalankan Aplikasi

      flutter run


🌐 Menjalankan di Web (Alternatif tanpa .env)

 Gunakan --dart-define:

    flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY



 5 Membangun APK release


    flutter build apk --release


 build yang lebih dioptimalkan (obfuscate, simbol terpisah, tree-shake ikon):



    flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/debug-info --tree-shake-icons


 Output umum: build/app/outputs/flutter-apk/. Salin ke folder release/ jika ingin dilampirkan pada repo atau rilis.






## Screenshot Aplikasi

## Struktur Folder


/
├── android/              ← konfigurasi & build Android
├── ios/                  ← konfigurasi & build iOS
├── linux/                ← build Linux
├── macos/                ← build macOS
├── windows/              ← build Windows
├── web/                  ← build Web

├── assets/
│   └── images/           ← gambar & resource aplikasi

├── lib/                  ← source code utama Flutter
│   ├── main.dart         ← entry point aplikasi
│   ├── config/           ← konfigurasi (tema, Supabase, dll.)
│   ├── core/             ← utilitas umum (helper, service, dll.)
│   ├── data/
│   │   ├── models/       ← model data
│   │   └── sources/      ← akses API / Supabase
│   ├── features/         ← fitur utama (auth, dashboard, dll.)
│   └── widgets/          ← komponen UI reusable

├── .gitignore
├── .metadata
├── README.md
├── analysis_options.yaml ← aturan linting
├── pubspec.yaml          ← konfigurasi project Flutter
├── pubspec.lock
