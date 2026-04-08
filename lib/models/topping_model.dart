class ToppingModel {
  String? id;
  String namaTopping;
  String kategori; // Kering, Frozen, Minuman (Pastikan ini sesuai dengan isi Database)
  int harga;
  int stok;
  String? imageUrl;

  ToppingModel({
    this.id,
    required this.namaTopping,
    required this.kategori,
    required this.harga,
    required this.stok,
    this.imageUrl,
  });

  // Mengubah JSON dari Supabase menjadi Object Dart
  factory ToppingModel.fromJson(Map<String, dynamic> json) {
    return ToppingModel(
      id: json['id'],
      // Gunakan null check (??) agar aplikasi tidak crash kalau data di DB ada yang kosong
      namaTopping: json['nama_topping'] ?? 'Tanpa Nama',
      // PENTING: Sesuaikan key 'category' dengan nama kolom di tabel Supabase kamu
      kategori: json['kategori'] ?? 'Lainnya', 
      harga: json['harga'] ?? 0,
      stok: json['stok'] ?? 0,
      imageUrl: json['image_url'],
    );
  }

  // Mengubah Object Dart menjadi JSON untuk Create/Update
  Map<String, dynamic> toJson() {
    return {
      'nama_topping': namaTopping,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'image_url': imageUrl,
    };
  }
}