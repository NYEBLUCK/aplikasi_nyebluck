<img width="1376" height="680" alt="Gemini_Generated_Image_9gdg9j9gdg9j9gdg" src="https://github.com/user-attachments/assets/08d5b7c1-0a5c-48e2-92b5-7112baaa0c68" />

# Nyebluck

## Deskripsi Aplikasi
Nyebluck adalah aplikasi kasir berbasis mobile yang dirancang untuk membantu operasional toko seblak Nyebluck dalam mengelola transaksi penjualan, pencatatan stok, serta laporan keuangan secara digital.

Aplikasi ini dikembangkan menggunakan Flutter sebagai framework utama dan Supabase sebagai backend service untuk autentikasi dan database.

Melalui aplikasi ini, kasir dapat melakukan transaksi dengan lebih cepat dan akurat, sementara admin dapat memantau stok, data penjualan, serta laporan keuangan secara terpusat. Dengan sistem digital ini, kesalahan pencatatan manual dapat diminimalkan dan operasional toko menjadi lebih efisien.

## Latar Belakang
Permasalahan utama yang dihadapi oleh Toko Seblak Nyebluck adalah proses pencatatan transaksi dan stok yang masih dilakukan secara manual. Hal ini sering menimbulkan kesalahan perhitungan, kehilangan data, serta kesulitan dalam memantau laporan penjualan harian.

Selain itu, proses pencatatan manual juga memerlukan waktu yang lebih lama dan tidak efisien, terutama saat jumlah pelanggan meningkat.

Berdasarkan permasalahan tersebut, kami mengusulkan sebuah aplikasi mobile yang dapat membantu proses pengelolaan transaksi, stok barang, dan laporan keuangan secara otomatis dan terintegrasi.

## Solusi yang Ditawarkan
Solusi yang kami tawarkan adalah aplikasi mobile Nyebluck yang memungkinkan pengguna untuk:

- Melakukan transaksi penjualan secara digital
  
- Mengelola data menu dan stok

- Mencatat laporan penjualan otomatis

- Menyimpan data secara terpusat dalam database

- Mengurangi kesalahan pencatatan manual

Dengan aplikasi ini, proses penjualan dan pengelolaan data menjadi lebih:

- Cepat

- Akurat

- Efisien

- Terstruktur

## 📊 Struktur Database Aplikasi Nyebluck

Database pada aplikasi Nyebluck digunakan untuk menyimpan data pengguna, menu/topping, serta transaksi penjualan.
Database ini terdiri dari empat tabel utama, yaitu:

toppings
transactions
transaction_items
profiles

Setiap tabel saling terhubung untuk mendukung proses transaksi pada sistem kasir.

**1. 🗄️ Tabel toppings**

Tabel toppings digunakan untuk menyimpan data menu atau topping yang tersedia pada aplikasi Nyebluck.

Tabel ini berfungsi untuk:

- Menyimpan data topping atau menu
- Menyimpan harga topping
- Menyimpan jumlah stok topping
- Menyimpan gambar topping
- Menyimpan status ketersediaan topping

Struktur Tabel toppings

| Field        | Tipe Data   | Keterangan                          |
| ------------ | ----------- | ----------------------------------- |
| id           | uuid        | Primary key untuk identitas topping |
| nama_topping | text        | Nama topping atau menu              |
| kategori     | text        | Kategori topping                    |
| harga        | int4        | Harga topping                       |
| stok         | int4        | Jumlah stok topping                 |
| image_url    | text        | URL gambar topping                  |
| created_at   | timestamptz | Waktu data dibuat                   |
| tak_terbatas | bool        | Status stok tidak terbatas          |

**2. 🧾 Tabel transactions**
   
Tabel transactions digunakan untuk menyimpan data utama transaksi penjualan pada aplikasi Nyebluck.

Tabel ini berfungsi untuk:

- Menyimpan data transaksi penjualan
- Menyimpan total harga transaksi
- Menyimpan data kasir
- Menyimpan jumlah pembayaran
- Menyimpan kembalian
- Menyimpan level pedas pesanan

  Struktur Table Transaction

| Field          | Tipe Data   | Keterangan                        |
| -------------- | ----------- | --------------------------------- |
| id             | uuid        | Primary key transaksi             |
| cashier_id     | uuid        | ID kasir yang melakukan transaksi |
| total_harga    | int4        | Total harga transaksi             |
| level_pedas    | int4        | Level pedas pesanan               |
| created_at     | timestamptz | Waktu transaksi dibuat            |
| nama_pembeli   | text        | Nama pembeli                      |
| total_quantity | int4        | Total jumlah item                 |
| bayar          | int4        | Jumlah uang yang dibayarkan       |
| kembalian      | int4        | Jumlah uang kembalian             |


**3. 📦 Tabel transaction_items**

Tabel transaction_items digunakan untuk menyimpan detail item dari setiap transaksi.

Tabel ini berfungsi untuk:

- Menyimpan daftar topping dalam transaksi
- Menyimpan jumlah topping yang dibeli
- Menyimpan harga topping
- Menghubungkan transaksi dengan topping

 Struktur Table transaction_items

| Field          | Tipe Data   | Keterangan                 |
| -------------- | ----------- | -------------------------- |
| id             | uuid        | Primary key item transaksi |
| transaction_id | uuid        | ID transaksi               |
| topping_name   | text        | Nama topping               |
| quantity       | int4        | Jumlah topping             |
| price          | int4        | Harga topping              |
| created_at     | timestamptz | Waktu data dibuat          |


**4. 👤 Tabel profiles**

Tabel profiles digunakan untuk menyimpan data pengguna aplikasi Nyebluck.

Tabel ini berfungsi untuk:

- Menyimpan data pengguna
- Menyimpan email pengguna
- Menyimpan nomor telepon
- Menyimpan alamat pengguna
- Menentukan role pengguna
- Menentukan status pengguna

Struktur Tabel profiles

| Field        | Tipe Data   | Keterangan                       |
| ------------ | ----------- | -------------------------------- |
| id           | uuid        | Primary key pengguna             |
| nama_lengkap | text        | Nama lengkap pengguna            |
| email        | text        | Email pengguna                   |
| nomor_telpon | text        | Nomor telepon pengguna           |
| alamat       | text        | Alamat pengguna                  |
| role         | text        | Role pengguna (admin atau kasir) |
| created_at   | timestamptz | Waktu akun dibuat                |
| is_active    | bool        | Status akun aktif                |

## ⚙️ Fitur Program Aplikasi Nyebluck

Aplikasi Nyebluck memiliki beberapa fitur utama yang dibedakan berdasarkan peran pengguna dalam sistem, yaitu Admin dan Kasir.
Setiap peran memiliki hak akses yang berbeda untuk menjaga keamanan data dan memastikan operasional sistem berjalan dengan baik.

### Fitur Utama
- Login
- Register / CRUD User
- CRUD [nama data utama]

**🧑‍💼 1. Fitur untuk Admin**

Admin merupakan pengguna yang memiliki kontrol penuh terhadap sistem kasir Nyebluck.
Admin bertanggung jawab dalam mengelola data menu, pengguna, dan memantau transaksi penjualan.

*1. Login*

Admin dapat masuk ke dalam sistem menggunakan email dan password yang terdaftar.

Penjelasan: Fitur login digunakan untuk memverifikasi identitas admin sebelum mengakses sistem.

*2. Kelola Data Pengguna (CRUD)*

Admin dapat menambahkan, melihat, mengubah, dan menghapus data pengguna dalam sistem.

Penjelasan: Fitur ini digunakan untuk mengatur akun pengguna seperti kasir.
Admin dapat menentukan role pengguna, misalnya admin atau kasir.

*3. Kelola Data Topping / Menu (CRUD)*

Admin dapat mengelola data topping atau menu yang tersedia pada aplikasi.

Fitur ini memungkinkan admin untuk:

- Menambahkan topping baru
- Mengubah harga topping
- Mengubah stok topping
- Menghapus topping
- Menambahkan gambar topping
  
*4. Melihat Data Transaksi*

Admin dapat melihat seluruh transaksi yang dilakukan oleh kasir.

Penjelasan: Fitur ini digunakan untuk memantau aktivitas penjualan dan memastikan transaksi berjalan dengan baik.

Informasi yang dapat dilihat:

- Total harga transaksi
- Nama pembeli
- Waktu transaksi
- Jumlah item
- Kasir yang melakukan transaksi

*5. Melihat Laporan Penjualan*

Admin dapat melihat laporan penjualan berdasarkan data transaksi.

Penjelasan: Fitur ini digunakan untuk mengetahui jumlah penjualan dalam periode tertentu.

Data yang digunakan:

- Total transaksi
- Total pendapatan
- Jumlah item terjual

**🧾 2. Fitur untuk Kasir**

Kasir merupakan pengguna yang bertugas melakukan transaksi penjualan kepada pelanggan.
Kasir memiliki akses terbatas hanya pada fitur yang berkaitan dengan proses transaksi.

*1. Login*

Kasir dapat masuk ke dalam sistem menggunakan akun yang telah dibuat oleh admin.

Penjelasan: Fitur login digunakan untuk memastikan hanya kasir yang terdaftar yang dapat menggunakan aplikasi.

*2. Melihat Daftar Topping / Menu*

Kasir dapat melihat daftar menu atau topping yang tersedia.

Penjelasan: Fitur ini digunakan untuk memilih menu yang akan dipesan oleh pelanggan.

Informasi yang ditampilkan:

- Nama topping
- Harga
- Stok
- Gambar

*3. Membuat Transaksi*

Kasir dapat membuat transaksi baru saat pelanggan melakukan pembelian.

Penjelasan: Fitur ini merupakan fungsi utama aplikasi kasir.

Kasir dapat:

- Memilih topping
- Menentukan jumlah
- Menentukan level pedas
- Menghitung total harga
- Menyimpan transaksi

*4. Melihat Riwayat Transaksidan Cetak*

Kasir dapat melihat transaksi yang telah dibuat olehnya.

Penjelasan: Fitur ini digunakan untuk memantau transaksi yang telah dilakukan oleh kasir.

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
  --dart-define=SUPABASE_URL
  --dart-define=SUPABASE_ANON_KEY



 5 Membangun APK release


    flutter build apk --release


 build yang lebih dioptimalkan (obfuscate, simbol terpisah, tree-shake ikon):



    flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/debug-info --tree-shake-icons


 Output umum: build/app/outputs/flutter-apk/. Salin ke folder release/ jika ingin dilampirkan pada repo atau rilis.






##  📱  Screenshot Aplikasi



## 📁 Struktur Folder

```text
/
├── android/              ← konfigurasi & build Android
├── ios/                  ← konfigurasi & build iOS
├── linux/                ← build Linux
├── macos/                ← build macOS
├── windows/              ← build Windows
├── web/                  ← build Web

├── assets/
│   └── images/           ← gambar & resource aplikasi

├── lib/
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
└── pubspec.lock
```
