class ToppingModel {
  String? id;
  String namaTopping;
  String kategori;
  int harga;
  int stok;
  bool takTerbatas; // BARU: Tambahan kolom tak terbatas
  String? imageUrl;

  ToppingModel({
    this.id,
    required this.namaTopping,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.takTerbatas, // BARU
    this.imageUrl,
  });

  factory ToppingModel.fromJson(Map<String, dynamic> json) {
    return ToppingModel(
      id: json['id'],
      namaTopping: json['nama_topping'] ?? 'Tanpa Nama',
      kategori: json['kategori'] ?? 'Lainnya', 
      harga: json['harga'] ?? 0,
      stok: json['stok'] ?? 0,
      takTerbatas: json['tak_terbatas'] ?? false, // BARU
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_topping': namaTopping,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'tak_terbatas': takTerbatas, // BARU
      'image_url': imageUrl,
    };
  }
}