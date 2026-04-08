class StaffModel {
  String? id;
  String namaLengkap;
  String email;
  String nomorTelpon;
  String alamat;
  String role;
  bool isActive; // Tambahkan ini

  StaffModel({
    this.id,
    required this.namaLengkap,
    required this.email,
    required this.nomorTelpon,
    required this.alamat,
    required this.role,
    this.isActive = true, // Default true
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'] ?? '',
      nomorTelpon: json['nomor_telpon'] ?? '',
      alamat: json['alamat'] ?? '',
      role: json['role'] ?? 'kasir',
      isActive: json['is_active'] ?? true, // Ambil dari DB
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_lengkap': namaLengkap,
      'email': email,
      'nomor_telpon': nomorTelpon,
      'alamat': alamat,
      'role': role,
      'is_active': isActive, // Kirim ke DB
    };
  }
}