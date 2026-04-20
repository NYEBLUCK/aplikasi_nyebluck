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

1. 🗄️ Tabel toppings

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

2. 🧾 Tabel transactions
   
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


3. 📦 Tabel transaction_items

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


4. 👤 Tabel profiles

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

## Keamanan Database (RLS)

1. Tabel profiles

- Admin memiliki akses penuh (create, read, update, delete) terhadap data pengguna
- User hanya dapat melihat data miliknya sendiri
- User hanya dapat mengupdate data miliknya sendiri
- Admin dapat melihat seluruh data pengguna
- Admin dapat mengelola (update) data pengguna jika diperlukan
- Sistem membatasi akses hanya untuk user yang terautentikasi (tidak dapat diakses oleh public tanpa login)

2. Tabel toppings

- Admin memiliki akses penuh (create, read, update, delete) terhadap data topping
- Semua user yang terautentikasi dapat melihat data topping
- Kasir dapat menggunakan data topping untuk melakukan transaksi
- Public (tanpa login) tidak dapat mengakses data topping
- Data topping hanya dapat diubah oleh admin

3. Tabel transactions

- Kasir hanya dapat membuat transaksi menggunakan akunnya sendiri
- Kasir hanya dapat melihat transaksi yang dibuat olehnya sendiri
= Admin dapat melihat seluruh transaksi
- Admin dapat menghapus transaksi jika diperlukan
- Sistem mencatat waktu transaksi secara otomatis
= Sistem membatasi akses hanya untuk user yang terautentikasi (tidak dapat diakses oleh public tanpa login)

4. Tabel transaction_items

- Kasir hanya dapat menambahkan item transaksi miliknya sendiri
- Admin juga dapat menambahkan item transaksi
- Kasir hanya dapat melihat item transaksi miliknya sendiri
- Admin dapat melihat seluruh item transaksi
- Hanya admin yang dapat mengupdate atau menghapus data item transaksi
- Data item transaksi hanya dapat ditambahkan saat proses transaksi berlangsung


## 🧩 Fitur Aplikasi
### Fitur Utama
- Login
- Register / CRUD User
- CRUD [nama data utama]

### Fitur Tambahan
- Fitur Admin

  *  Login dan Logout
 
  *  Kelola Data dan Stok
    
  *  Lihat Pengeluaran dan Print

  *  Kelola Akun Admin
        
  *  Kelola Akun Kasir

  
- Fitur Kasir

   *  Login dan Logout
 
  *  Transaksi
    
  *  Lihat Data

  *  Cetak/Simpan Struk

  

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
