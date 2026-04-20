<img width="1376" height="680" alt="Gemini_Generated_Image_9gdg9j9gdg9j9gdg" src="https://github.com/user-attachments/assets/08d5b7c1-0a5c-48e2-92b5-7112baaa0c68" />

# Nyebluck ──★ ˙🍲 ̟ !!

Nyebluck adalah aplikasi kasir berbasis mobile yang dirancang untuk membantu operasional toko seblak Nyebluck dalam mengelola transaksi penjualan, pencatatan stok, serta laporan keuangan secara digital.

Aplikasi ini dikembangkan menggunakan **Flutter** sebagai framework utama dan **Supabase** sebagai backend service untuk autentikasi dan database. Dengan sistem digital ini, kasir dapat melakukan transaksi dengan lebih cepat dan akurat, sementara admin dapat memantau stok, data penjualan, serta laporan keuangan secara terpusat.

---

## ↳ Latar Belakang
Permasalahan utama yang dihadapi oleh Toko Seblak Nyebluck adalah proses pencatatan transaksi dan stok yang masih dilakukan secara manual. Hal ini sering menimbulkan kesalahan perhitungan, kehilangan data, serta kesulitan dalam memantau laporan penjualan harian.

Selain itu, proses pencatatan manual juga memerlukan waktu yang lebih lama dan tidak efisien, terutama saat jumlah pelanggan meningkat.

Berdasarkan permasalahan tersebut, kami mengusulkan sebuah aplikasi mobile yang dapat membantu proses pengelolaan transaksi, stok barang, dan laporan keuangan secara otomatis dan terintegrasi.

---

## ↳ Solusi yang Ditawarkan
Solusi yang kami tawarkan adalah aplikasi mobile Nyebluck yang memungkinkan pengguna untuk:

- Melakukan transaksi penjualan secara digital
  
- Mengelola data topping/menu dan stok

- Mencatat laporan penjualan otomatis

- Menyimpan data secara terpusat dalam database

- Mengurangi kesalahan pencatatan manual

Dengan aplikasi ini, proses penjualan dan pengelolaan data menjadi lebih:

- Cepat

- Akurat

- Efisien

- Terstruktur

---

## ↳ Fitur Aplikasi

Aplikasi **Nyebluck** memiliki beberapa fitur utama yang dibedakan berdasarkan peran pengguna dalam sistem, yaitu **Admin** dan **Kasir**. 

Setiap peran memiliki hak akses yang berbeda guna menjaga keamanan data serta memastikan proses operasional aplikasi berjalan secara efektif, terstruktur, dan terkendali.

---

### 1. Autentikasi & Manajemen User
- Login untuk Admin dan Kasir  
- Manajemen akun user (CRUD) oleh Admin:
  - Tambah akun kasir  
  - Edit data kasir  
  - Nonaktifkan akun kasir  
- Mengganti password:
  - Admin dapat mengganti password sendiri dan password kasir
 
---

### 2. Fitur Admin

Admin merupakan pengguna yang memiliki kontrol penuh terhadap sistem kasir **Nyebluck**. 

Admin bertanggung jawab dalam mengelola data menu, mengatur pengguna (kasir), serta memantau seluruh aktivitas transaksi penjualan yang terjadi dalam sistem.

#### Manajemen Topping/Menu (CRUD)
- Menambahkan topping/menu  
- Mengedit data topping  
- Menghapus topping  
- Mengatur stok (termasuk stok tak terbatas)  
- Mengelola gambar topping

#### Manajemen Staff (Kasir)
- Menambahkan staff baru  
- Mengedit data staff  
- Menonaktifkan akun kasir

Fitur ini berfungsi untuk mengelola akun pengguna dalam sistem, khususnya kasir. 
Admin memiliki kewenangan untuk menambahkan, memperbarui, serta menonaktifkan akun, sekaligus menentukan peran (role) pengguna sesuai kebutuhan operasional.

#### Laporan Penjualan & Data Transaksi
- Melihat seluruh data transaksi penjualan  
- Menampilkan total pendapatan dan jumlah transaksi  
- Menampilkan detail transaksi:
  - Total harga transaksi  
  - Nama pembeli  
  - Waktu transaksi  
  - Jumlah item  
  - Kasir yang melakukan transaksi  
- Visualisasi data dalam bentuk grafik  
- Export / cetak laporan dalam bentuk **PDF**  

Fitur ini digunakan untuk memantau aktivitas penjualan secara menyeluruh serta membantu admin dalam menganalisis performa penjualan pada periode tertentu. 
Melalui fitur ini, admin dapat memperoleh informasi seperti total transaksi, total pendapatan, dan jumlah item yang terjual secara lebih terstruktur dan mudah dipahami.

---

### 3. Fitur Kasir

Kasir berfokus pada proses transaksi penjualan kepada pelanggan, mulai dari pemilihan menu hingga pencatatan transaksi.

#### Melihat Daftar Topping/Menu
- Melihat daftar menu atau topping yang tersedia  
- Menampilkan informasi:
  - Nama topping  
  - Harga  
  - Stok  
  - Gambar  

Fitur ini digunakan untuk membantu kasir dalam memilih menu yang akan dipesan oleh pelanggan.

#### Transaksi Penjualan
- Membuat transaksi baru  
- Memilih topping/menu  
- Menentukan jumlah item  
- Menentukan level pedas  
- Menghitung total harga secara otomatis  
- Mengelola pembayaran dan kembalian  
- Menyimpan data transaksi  

Fitur ini merupakan fungsi utama aplikasi kasir yang digunakan untuk memproses pembelian pelanggan secara cepat dan akurat.

#### Nota & Riwayat Transaksi
- Melihat nota transaksi  
- Melihat riwayat transaksi harian  
- Preview nota sebelum dicetak  
- Export / cetak nota dalam bentuk **PDF**  

Fitur ini digunakan untuk memantau transaksi yang telah dilakukan serta menyediakan bukti transaksi dalam bentuk nota.

---

## ↳ Struktur Database Aplikasi Nyebluck

Database pada aplikasi Nyebluck digunakan untuk menyimpan data pengguna, menu/topping, serta transaksi penjualan.
Tabel utama yang digunakan:
- `toppings`
- `transactions`
- `transaction_items`
- `profiles`

Setiap tabel saling terhubung untuk mendukung proses transaksi pada sistem kasir.

### 1. Tabel `toppings`

Tabel `toppings` digunakan untuk menyimpan data menu atau topping yang tersedia pada aplikasi Nyebluck. 
Data yang disimpan meliputi informasi nama menu, kategori, harga, stok, gambar, serta status ketersediaan (termasuk stok tak terbatas).

Fungsi utama tabel ini:
- Menyimpan data topping atau menu
- Menyimpan harga topping
- Menyimpan jumlah stok topping
- Menyimpan gambar topping
- Menyimpan status ketersediaan topping

#### Struktur Tabel

| Field        | Tipe Data   | Keterangan                          |
|--------------|------------|-------------------------------------|
| id           | uuid        | Primary key untuk identitas topping |
| nama_topping | text        | Nama topping atau menu              |
| kategori     | text        | Kategori topping                    |
| harga        | int4        | Harga topping                       |
| stok         | int4        | Jumlah stok topping                 |
| image_url    | text        | URL gambar topping                  |
| created_at   | timestamptz | Waktu data dibuat                   |
| tak_terbatas | bool        | Status stok tidak terbatas          |

### 2. Tabel `transactions`

Tabel `transactions` digunakan untuk menyimpan data utama transaksi penjualan pada aplikasi Nyebluck. 
Data yang disimpan meliputi informasi kasir, total harga, detail pesanan, hingga proses pembayaran.

Fungsi utama tabel ini:
- Menyimpan data transaksi penjualan
- Menyimpan total harga transaksi
- Menyimpan data kasir yang melakukan transaksi
- Menyimpan jumlah pembayaran dan kembalian
- Menyimpan informasi pesanan seperti level pedas dan jumlah item

#### Struktur Tabel

| Field          | Tipe Data   | Keterangan                        |
|----------------|------------|----------------------------------|
| id             | uuid        | Primary key transaksi            |
| cashier_id     | uuid        | ID kasir yang melakukan transaksi|
| total_harga    | int4        | Total harga transaksi            |
| level_pedas    | int4        | Level pedas pesanan              |
| created_at     | timestamptz | Waktu transaksi dibuat           |
| nama_pembeli   | text        | Nama pembeli                     |
| total_quantity | int4        | Total jumlah item                |
| bayar          | int4        | Jumlah uang yang dibayarkan      |
| kembalian      | int4        | Jumlah uang kembalian            |


### 3. Tabel `transaction_items`

Tabel `transaction_items` digunakan untuk menyimpan detail item dari setiap transaksi pada aplikasi Nyebluck. 
Tabel ini berfungsi sebagai penghubung antara transaksi dengan data topping/menu yang dipilih.

Fungsi utama tabel ini:
- Menyimpan daftar topping dalam setiap transaksi
- Menyimpan jumlah topping yang dibeli
- Menyimpan harga topping
- Menghubungkan data transaksi dengan item yang dipesan

#### Struktur Tabel

| Field          | Tipe Data   | Keterangan                 |
|----------------|------------|---------------------------|
| id             | uuid        | Primary key item transaksi |
| transaction_id | uuid        | ID transaksi               |
| topping_name   | text        | Nama topping               |
| quantity       | int4        | Jumlah topping             |
| price          | int4        | Harga topping              |
| created_at     | timestamptz | Waktu data dibuat          |

### 4. Tabel `profiles`

Tabel `profiles` digunakan untuk menyimpan data pengguna pada aplikasi Nyebluck, baik admin maupun kasir. 
Data yang disimpan meliputi informasi identitas pengguna, kontak, serta peran (role) dalam sistem.

Fungsi utama tabel ini:
- Menyimpan data pengguna
- Menyimpan email pengguna
- Menyimpan nomor telepon dan alamat
- Menentukan role pengguna (admin atau kasir)
- Menentukan status akun pengguna (aktif/nonaktif)

#### Struktur Tabel

| Field        | Tipe Data   | Keterangan                       |
|--------------|------------|----------------------------------|
| id           | uuid        | Primary key pengguna             |
| nama_lengkap | text        | Nama lengkap pengguna            |
| email        | text        | Email pengguna                   |
| nomor_telpon | text        | Nomor telepon pengguna           |
| alamat       | text        | Alamat pengguna                  |
| role         | text        | Role pengguna (admin atau kasir) |
| created_at   | timestamptz | Waktu akun dibuat                |
| is_active    | bool        | Status akun aktif                |

---

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
